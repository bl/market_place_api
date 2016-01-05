require 'test_helper'

class ProductTest < ActiveSupport::TestCase

  def setup
    @product = Product.new(title: "ProductName", price: 9.99,
                           published: false,     user_id: 1)
  end

  test "product is valid" do
    assert @product.valid?
  end

  test "default product values should be clear" do
    @product = Product.new
    assert @product.title.empty?
    assert_equal 0.0, @product.price
    assert_not @product.published
    assert_nil @product.user_id
  end

  test "user_id should be present" do
    @product.user_id = nil
    assert_not @product.valid?
    @product.user_id = ""
    assert_not @product.valid?
  end

  test "title should be present" do
    @product.title = nil
    assert_not @product.valid?
    @product.title = ""
    assert_not @product.valid?
  end

  test "product price should be greater than or equal to 0" do
    @product.price = 0
    assert @product.valid?
    @product.price = -1 
    assert_not @product.valid?
    @product.price = nil
    assert_not @product.valid?
  end

  test "product should belong to a user" do
    assert @product.respond_to?(:user)
  end
end
