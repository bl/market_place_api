FactoryGirl.define do
  factory :user do
    email { FFaker::Internet.email }
    password "foobar"
    password_confirmation "foobar"

    factory :user_with_products do
      transient do
        products_count 5
      end

      after(:create) do |user, evaluator|
        create_list(:product, evaluator.products_count, user: user)
      end
    end
  end
end
