Rails.application.routes.draw do
  root 'home#search'
  post "/", to: "home#search"
  get "/expediente/:fuero/:file", to: "home#file", as: :file
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
