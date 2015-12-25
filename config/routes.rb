Rails.application.routes.draw do
  # api definition
  namespace :api, defaults:     { format: :json },
                  constriants:  { subdomain: 'api'},
                  path:         '/' do
    # listing resources here
  end
end
