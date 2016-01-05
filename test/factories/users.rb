FactoryGirl.define do
  factory :user do
    email { FFaker::Internet.email }
    password "foobar"
    password_confirmation "foobar"
  end
end
