FactoryGirl.define do
  factory :product do
    title { FFAker::Product.product_name }
    price { rand() * 100 }
    published false
    user
  end

end
