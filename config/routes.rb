Digilys::Application.routes.draw do
  # Landing page
  get "index/index"

  resources :users, only: [ :index, :edit, :update, :destroy ] do
    collection do
      get :search
    end
    member do
      get :confirm_destroy
    end
  end

  resources :groups do
    collection do
      get :search
    end
    member do
      get    :confirm_destroy
      get    :select_students
      put    :add_students
      get    :move_students
      put    :move_students
      delete :remove_students
      get    :select_users
      put    :add_users
      delete :remove_users
    end
  end

  resources :students do
    collection do
      get :search
    end
    member do
      get    :confirm_destroy
      get    :select_groups
      put    :add_groups
      delete :remove_groups
    end

    resource :visualization, only: [] do
      member do
        get :result_line_chart
      end
    end
  end

  resources :suites do
    collection do
      get  :closed
      post :new_from_template
    end
    member do
      get    :search_participants
      get    :color_table
      put    :save_color_table_state
      delete :clear_color_table_state
      get    :confirm_destroy
      get    :select_users
      put    :add_users
      delete :remove_users
      put    :add_contributors
      delete :remove_contributors
      put    :add_generic_evaluations
      delete :remove_generic_evaluations
      put    :add_student_data
      delete :remove_student_data
    end

    resources :evaluations,  only: :new
    resources :participants, only: :new
    resources :meetings,     only: :new
    resources :students,     only: :show
    resources :table_states, only: :create

    resource :visualization, only: [] do
      member do
        get :color_area_chart
        get :stanine_column_chart
        get :result_line_chart
      end
    end
  end

  resources :participants, only: [ :create, :destroy ] do
    member do
      get :confirm_destroy
    end
  end

  resources :evaluations, except: [ :index, :new ] do
    collection do
      post :new_from_template
    end
    member do
      get    :confirm_destroy
      get    :report
      put    :submit_report
      delete :destroy_report
    end
  end

  resources :meetings, except: [ :index, :new ] do
    member do
      get :confirm_destroy
      get :report
      put :submit_report
    end
  end

  resources :activities, except: [ :index, :new ] do
    member do
      get :confirm_destroy
      get :report
      put :submit_report
    end
  end

  resource :visualization, only: [] do
    member do
      put :filter
    end
  end

  resources :instructions, except: [ :index, :show ] do
    member do
      get :confirm_destroy
    end
  end

  resources :instances, except: [ :destroy ] do
    member do
      post :select
    end
  end

  resources :table_states, only: [:show, :update, :destroy] do
    member do
      get :select
    end
  end

  namespace :template do
    resources :suites, only: [ :index, :new ] do
      get :search, on: :collection
    end
    resources :evaluations, only: [ :index, :new ] do
      get :search, on: :collection
    end
  end
  namespace :generic do
    resources :evaluations, only: [ :index, :new ]
  end

  devise_for :users, path: "authenticate"

  mount RailsAdmin::Engine   => "/radmin", as: "rails_admin"
  mount JasmineRails::Engine => "/specs"   if defined?(JasmineRails)

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "index#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
