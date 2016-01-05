require 'api_constraints.rb'

MarketPlaceApi::Application.routes.draw do
  # Api definition
#  namespace :api, defaults: { format: :json },
#                              constraints: { subdomain: 'api' }, path: '/'  do

  scope module: :v1,
        defaults: { format: :json },
        constraints: ApiConstraints.new(version: 1, default: true) do
    # We are going to list our resources here
    resources :users, :only => [:show, :create, :update, :destroy] do#, constraints: ApiConstraints.new(version: 1, default: true)
      resources :products, :only => [:create, :update]
    end
    resources :sessions, :only => [:create, :destroy]
    resources :products, :only => [:show, :index]
  end

#  end
end
