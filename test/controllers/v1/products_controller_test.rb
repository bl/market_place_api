require 'test_helper'

class V1::ProductsControllerTest < ActionController::TestCase

  def setup
    @product = FactoryGirl.create :product
  end

  # GET

  test "show returns the information of a product and associated user id" do
    get :show, id: @product, format: :json
    product_response = json_response[:data]
    assert_not_nil product_response
    assert_equal @product.title, product_response[:attributes][:title]
    product_user = product_response[:relationships][:user][:data]
    assert_equal @product.user.id, product_user[:id].to_i

    assert_response 200
  end

  # INDEX

  test "index returns the information of all products" do
    5.times do
      FactoryGirl.create :product
    end

    get :index, format: :json
    products_response = json_response[:data]
    assert_not_nil products_response
    assert_equal Product.all.count, products_response.count
  end

  test "index of product ids returns information for just those products" do
    user = FactoryGirl.create :user_with_products
    # create additional products
    other_user = FactoryGirl.create :user_with_products
    get :index, { product_ids: user.product_ids }, format: :json
    products_response = json_response[:data]
    assert_not_nil products_response
    assert_equal user.products.count, products_response.count
    products_response.each do |product_response|
      assert user.product_ids.include? product_response[:id].to_i
    end
  end

  # POST
  
  test "create renders json error when not logged in" do
    user = FactoryGirl.create :user
    product_attributes = FactoryGirl.attributes_for :product
    assert_no_difference 'user.products.count' do
      post :create, { user_id: user.id,  product: product_attributes }, format: :json
    end
    product_response  = json_response
    assert_not_nil product_response[:errors]
    product_errors = product_response[:errors]
    assert_match /Not authenticated/, product_errors

    assert_response 401
  end

  test "create renders json error when creating post for non-authenticated user" do
    user = FactoryGirl.create :user
    other_user = FactoryGirl.create :user
    product_attributes = FactoryGirl.attributes_for :product
    log_in_as user
    assert_no_difference 'user.products.count' do
      post :create, { user_id: other_user.id,  product: product_attributes }, format: :json
    end
    product_response  = json_response
    assert_not_nil product_response[:errors]
    product_errors = product_response[:errors]
    assert_match /Incorrect user/, product_errors
  end

  test "renders json representation of product created" do
    user = FactoryGirl.create :user
    product_attributes = FactoryGirl.attributes_for :product
    log_in_as user
    assert_difference 'user.products.count', 1 do
      post :create, { user_id: user.id,  product: product_attributes }, format: :json
    end
    product_response  = json_response[:data]
    assert_not_nil product_response
    assert_equal product_attributes[:title], product_response[:attributes][:title]

    assert_response 201
  end

  test "renders json errors on invalid create product" do
    user = FactoryGirl.create :user
    invalid_product_attributes = { title: "Cereal", price: "5 dollars" }
    log_in_as user
    assert_no_difference 'user.products.count' do
      post :create, { user_id: user.id,  product: invalid_product_attributes }, format: :json
    end
    product_response  = json_response
    assert_not_nil product_response[:errors]
    product_errors = product_response[:errors]
    assert_match /is not a number/, product_errors[:price].to_s

    assert_response 422
  end

  # UPDATE

  test "update renders json error when not logged in" do
    user = FactoryGirl.create :user_with_products, products_count: 1
    product = user.products.first
    product_attributes = { title: "New Product Title", price: 49.99 }
    post :update, { user_id: user.id, id: product, product: product_attributes }, format: :json
    product_response = json_response
    assert_not_nil product_response[:errors]
    product_errors = product_response[:errors]
    assert_match /Not authenticated/, product_errors

    assert_response :unauthorized
  end

  test "renders json error when updating post for non-authenticated user" do
    user = FactoryGirl.create :user_with_products, products_count: 1
    other_user = FactoryGirl.create :user_with_products, products_count: 1
    product = other_user.products.first
    log_in_as user
    product_attributes = { title: "New Product Title", price: 49.99 }
    post :update, { user_id: other_user, id: product, product: product_attributes }, format: :json
    product_response = json_response
    assert_not_nil product_response[:errors]
    product_errors = product_response[:errors]
    assert_match /Incorrect user/, product_errors

    assert_response 403
  end
  
  test "renders the json representation for the updated product" do
    user = FactoryGirl.create :user_with_products, products_count: 1
    product = user.products.first
    log_in_as user
    product_attributes = { title: "New Product Title", price: 49.99 }
    post :update, { user_id: user, id: product, product: product_attributes }, format: :json
    product_response = json_response[:data]
    assert_not_nil product_response
    assert_equal product_attributes[:title], product_response[:attributes][:title]

    assert_response 200
  end


  test "renders json errors for invalid product update attributes" do
    user = FactoryGirl.create :user_with_products, products_count: 1
    product = user.products.first
    log_in_as user
    product_attributes = { title: "New Product Title", price: "forty-nine, ninety-nine" }
    post :update, { user_id: user, id: product, product: product_attributes }, format: :json
    product_response = json_response
    assert_not_nil product_response[:errors]
    product_errors = product_response[:errors]
    assert_match /is not a number/, product_errors[:price].to_s

    assert_response 422
  end

  # DESTROY

  test "destroy renders json error when not logged in" do
    user = FactoryGirl.create :user_with_products, products_count: 1
    product = user.products.first
    assert_no_difference 'user.products.count' do
      post :destroy, { user_id: user, id: product }, format: :json
    end
    product_response = json_response
    assert_not_nil response.body
    product_errors = product_response[:errors]
    assert_match /Not authenticated/, product_errors

    assert_response :unauthorized
  end
  
  test "renders json error when destroy get for non-authenticated user" do
    user = FactoryGirl.create :user_with_products, products_count: 1
    other_user = FactoryGirl.create :user_with_products, products_count: 1
    product = other_user.products.first
    log_in_as user
    assert_no_difference 'user.products.count' do
      post :destroy, { user_id: user, id: product }, format: :json
    end
    product_response = json_response
    assert_not_empty response.body
    product_errors = product_response[:errors]
    assert_match /Incorrect user/, product_errors

    assert_response 403
  end

  test "returns header with empty payload on valid destroy" do
    user = FactoryGirl.create :user_with_products, products_count: 1
    product = user.products.first
    log_in_as user
    assert_difference 'user.products.count', -1 do
      post :destroy, { user_id: user, id: product }, format: :json
    end
    assert_empty response.body

    assert_response 204
  end
end
