class V1::ProductsController < ApplicationController
  respond_to :json

  before_action :logged_in_user,  only: [:create, :update, :destroy]
  before_action :correct_user,    only: [:create, :update, :destroy]
  before_action :correct_product, only: [:update, :destroy]

  def show
    @product = Product.find_by id: params[:id]
    render json: @product
  end

  def index
    @products = Product.all
    render json: @products
  end

  def create
    #@user = User.find params[:user_id]
    @product = @user.products.build(product_params)
    if @product.save
      render json: @product, status: 201
    else
      render json: { errors: @product.errors }, status: 422
    end
  end

  def update
    if @product.update product_params
      render json: @product, status: 200
    else
      render json: { errors: @product.errors }, status: 422
    end
  end

  def destroy
    @product.destroy
    head 204
  end

  private

    def product_params
      params.require(:product).permit(:title, :price, :published)
    end

    def correct_product
      @user ||= User.find_by id: params[:user_id]
      @product ||= @user.products.find_by params[:id]
      render json: { errors: "Incorrect product" }, 
             status: 403 unless !@product.nil? && current_user?(@user)
    end

end
