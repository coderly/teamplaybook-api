Rails.application.routes.draw do
  devise_for :users, path: "accounts", only: [:sessions, :registrations],
   controllers: { sessions: "tokens", registrations: "accounts" },
   path_names: {
     sign_in: 'tokens'
   }

  get '/me', to: 'me#show'

  resources :teams, only: [:create, :destroy]
  resources :plans, only: :index

  resource :team do
    member do
      post :change_plan
    end
  end

  resources :team_memberships, only: [:index, :show, :create, :update, :destroy], path: '/team-memberships'
  resources :users, only: :index
  resources :pages, only: [:index, :create, :show, :destroy, :update]


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  get 'ping', to: 'ping#index'
end
