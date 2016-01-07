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

  # filters

  test "filter product by title" do
    products = []
    products.push FactoryGirl.create :product, title: "A bigscreen TV"
    products.push FactoryGirl.create :product, title: "Fastest Laptop"
    products.push FactoryGirl.create :product, title: "CD Player"
    products.push FactoryGirl.create :product, title: "LCD TV"

    tv_results = Product.filter_by_title("TV")
    assert_equal 2, tv_results.count
    tv_results.each do |tv_result|
      assert products.include? tv_result
    end
  end

  test "filter product by above or equal to price" do
    products = []
    products.push FactoryGirl.create :product, price: 100
    products.push FactoryGirl.create :product, price: 50
    products.push FactoryGirl.create :product, price: 150
    products.push FactoryGirl.create :product, price: 99

    price_results = Product.above_or_equal_to_price(100)
    assert_equal 2, price_results.count
    price_results.each do |price_result|
      assert products.include? price_result
    end
  end

  test "filter product by below or equal to price" do
    products = []
    products.push FactoryGirl.create :product, price: 100
    products.push FactoryGirl.create :product, price: 50
    products.push FactoryGirl.create :product, price: 150
    products.push FactoryGirl.create :product, price: 99

    price_results = Product.below_or_equal_to_price(99)
    assert_equal 2, price_results.count
    price_results.each do |price_result|
      assert products.include? price_result
    end
  end

  test "filter returns the most updated records" do
    products = []
    products.push FactoryGirl.create :product, price: 100
    products.push FactoryGirl.create :product, price: 50
    products.push FactoryGirl.create :product, price: 150
    products.push FactoryGirl.create :product, price: 99

    products[1].touch
    products[2].touch
    
    recent_results = Product.recent
    expected_results = [products[2], products[1], products[3], products[0]]
    expected_results.count.times do |n|
      assert_equal expected_results[n], recent_results[n]
    end
  end


  test "test combination of search parameters" do
    products = []
    products.push FactoryGirl.create :product, price: 100,  title: "A bigscreen TV"
    products.push FactoryGirl.create :product, price: 50,   title: "Fastest Laptop"
    products.push FactoryGirl.create :product, price: 150,  title: "CD Player"
    products.push FactoryGirl.create :product, price: 99,   title: "LCD TV"

    search_hash = { keyword: "laptop", min_price: 100 }
    assert_empty Product.search(search_hash)
    
    search_hash = { keyword: "tv", min_price: 100, max_price: 150 }
    search_results = Product.search(search_hash)
    assert_equal 1, search_results.count
    assert_equal products[0], search_results.first

    assert_equal Product.search({}).count, Product.all.count

    expected_results = [products[0].id, products[1].id]
    search_hash = { product_ids: expected_results }
    search_results = Product.search(search_hash)
    assert_equal 2, search_results.count
    search_results.each do |search_result|
      assert expected_results.include? search_result.id
    end
  end
end
