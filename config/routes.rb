PipelinedealsZendesk::Application.routes.draw do
  #get "deals/index"
  #
  #get "companies/index"
  #
  #get "people/index"

  match "api/v1/zendeskAuthentication(/:subdomain_name)(/:unique_identifier)(/:secret)" => 'zendesk#zendesk_authorizations' , :as => :zendesk_authorizations, :via => :get
  get "zendesk/get_access_token"

  match "api/v1/PeopleAllTickets(/:subdomain_name)(/:pipeline_user_id)(/:pipeline_secret)" => 'people#index' , :as => :get_all_tickets_for_people, :via => :get
  match "api/v1/CompaniesAllTickets(/:subdomain_name)(/:pipeline_company_id)(/:pipeline_secret)" => 'companies#index' , :as => :get_all_tickets_for_companies, :via => :get
  match "api/v1/DealsAllTickets(/:subdomain_name)(/:pipeline_deals_id)(/:pipeline_secret)" => 'deals#index' , :as => :get_all_tickets_for_deals, :via => :get

  #match "api/v1/AllTicketsUser(/:subdomain_name)(/:pipeline_user_id)(/:pipeline_secret)" => 'pipeline#user' , :as => :get_all_tickets_for_user, :via => :get
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
  # root :to => 'zendesk#api'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
