class Product < ActiveRecord::Base
  belongs_to :user

  validates :title, :user_id, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, presence: true

  scope :recent, -> {
    order(updated_at: :desc)
  }
  scope :filter_by_title, lambda { |keyword| 
    where("lower(title) LIKE ?", "%#{keyword.downcase}%")
  }

  scope :above_or_equal_to_price, lambda { |price|
    where("price >= ?", price)
  }

  scope :below_or_equal_to_price, lambda { |price|
    where("price <= ?", price)
  }

  def Product.search(params = {})
    products = params[:product_ids].present? ? Product.find(params[:product_ids]) : Product.all
    products = products.filter_by_title(params[:keyword]) if params[:keyword].present?
    products = products.above_or_equal_to_price(params[:min_price].to_f) if params[:min_price].present?
    products = products.below_or_equal_to_price(params[:max_price].to_f) if params[:max_price].present?
    products = products.recent() if params[:recent].present?

    products
  end
end
