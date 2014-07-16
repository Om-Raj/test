require 'lib_people'
class CompaniesController < ApplicationController
  def index
    subdomain_name = params[:subdomain_name]
    pipeline_company_id = params[:pipeline_company_id]
    pipeline_secret = params[:pipeline_secret]
    if subdomain_name && pipeline_company_id && pipeline_secret
      people = PipeLineDeals.get_people_associated_company_or_deals(pipeline_company_id,pipeline_secret,'companies')
      return_json_obj(people,subdomain_name)
    else
      error_obj = get_exception_object(I18n.t(:code_400),I18n.t(:api_missing_required),400)
      render :json => error_obj.to_json, :status => 400  and return
    end
  end
end
