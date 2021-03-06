require 'lib_people'
class CompaniesController < ApplicationController
  # for all tickets opened by all the people listed on a company page
  def index
    subdomain_name = params[:subdomain_name]
    pipeline_company_id = params[:pipeline_company_id]
    pipeline_secret = params[:pipeline_secret]
    get_company_or_deals(subdomain_name,pipeline_company_id,pipeline_secret,'companies')
  end
end
