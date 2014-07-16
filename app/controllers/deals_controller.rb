require 'lib_people'
class DealsController < ApplicationController
  def index
    subdomain_name = params[:subdomain_name]
    pipeline_deals_id = params[:pipeline_deals_id]
    pipeline_secret = params[:pipeline_secret]
    get_company_or_deals(subdomain_name,pipeline_deals_id,pipeline_secret,'deals')
  end
end
