Rails.application.routes.draw do
  # ==================== DEVISE ====================
  devise_for :users,
           path: "auth",
           controllers: {
             registrations: "users/registrations",
             sessions: "users/customer_sessions"
           },
           path_names: {
             sign_in: "login",
             sign_out: "logout",
             registration: "register"
           }

  devise_scope :user do
    get "users/login", to: "users/sessions#new", as: :staff_login
    post "users/login", to: "users/sessions#create", as: :staff_session
    delete "users/logout", to: "users/sessions#destroy", as: :staff_logout
  end

  # ==================== ROOT ====================
  root "home#index"

  # ==================== NAMESPACES ====================

  # 1. Admin / Owner Area
  namespace :admin do
    get "customers/index"
    get "customers/new"
    get "customers/create"
    get "customers/edit"
    get "customers/update"
    get "customers/destroy"
    get "categories/index"
    get "categories/new"
    get "categories/create"
    get "categories/edit"
    get "categories/update"
    get "categories/destroy"
    get "products/index"
    get "products/new"
    get "products/create"
    get "products/edit"
    get "products/update"
    get "products/destroy"
    get "dashboard/index"
    root "dashboard#index"
    
    resources :categories
    resources :suppliers
    resources :products do
      resources :product_variants
    end
    
    resources :customers
    resources :orders
    resources :stock_movements
    resources :users
    resources :roles
    
    # Laporan & Analisa
    get 'reports/sales'
    get 'reports/inventory'
    get 'reports/profit'
  end

  # 1b. Owner Area
  namespace :owner do
    root "dashboard#index"

    get "reports/sales", to: "reports#sales"
    get "reports/stock", to: "reports#stock"

    resources :customers, only: [:index]
    resources :suppliers, only: [:index]
  end

  # 2. POS Area (Point of Sale)
  namespace :pos do
    get "dashboard/index"
    get "cart/add_item"
    get "cart/remove_item"
    get "cart/checkout"
    get "transactions/index"
    get "transactions/create"
    get "transactions/show"
    root "dashboard#index"
    
    resources :transactions, only: [:index, :new, :create, :show] do
      member do
        get :receipt
      end
    end

    resources :orders, only: [:index, :show, :update] do
      member do
        get :shipping_slip
      end
    end
    
    resources :cart, only: [:index, :create, :destroy] do
      collection do
        post :add_item
        delete :remove_item
        post :checkout
      end
    end
    
    get 'search_products', to: 'transactions#search_products'
  end

  # 2b. Courier Area
  namespace :courier do
    root "deliveries#index"

    resources :deliveries, only: [:index, :show] do
      member do
        patch :pickup
      end
    end

    resources :completed, only: [:index, :show] do
      member do
        patch :finish
      end
    end
  end

  # 3. Customer / Online Store Area
  namespace :store do
    root "products#index"

    resources :products, only: [:index, :show]
    resources :wishlists, only: [:index, :destroy] do
      collection do
        post :toggle
      end
    end

    resource :cart, only: [:show] do
      post :add_item
      patch :update_item
      delete :remove_item
    end
    
    resources :orders, only: [:index, :create, :show] do
      member do
        get :track
      end
    end
    
    resource :customer, only: [:edit, :update] # profil customer
  end

  # ==================== API (untuk future mobile app) ====================
  namespace :api do
    namespace :v1 do
      resources :products, only: [:index, :show]
      resources :orders, only: [:create, :index]
      post 'pos/checkout', to: 'pos#checkout'
    end
  end

  # ==================== MISC ====================
  get 'dashboard', to: 'dashboard#index'
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA Routes - Native Rails
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end