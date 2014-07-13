require 'lib_people'
class CompaniesController < ApplicationController
  def compeny
    subdomain_name = params[:subdomain_name]
    pipeline_company_id = params[:pipeline_company_id]
    pipeline_secret = params[:pipeline_secret]
    if subdomain_name && pipeline_company_id && pipeline_secret
      company_people = PipeLineDeals.get_people_associated_company(pipeline_company_id,pipeline_secret)
      if company_people
        code = company_people[0]
        data = company_people[1]
        if code == 200
          company_people_tickets(data,subdomain_name)
        else
          error_obj = get_exception_object(code,data,code)
          render :json => error_obj.to_json, :status => code  and return
        end
      end
    else
      error_obj = get_exception_object(I18n.t(:code_400),I18n.t(:api_missing_required),400)
      render :json => error_obj.to_json, :status => 400  and return
    end
  end


  def company_people_tickets(data,subdomain_name)
    subdomain_exists = User.subdomain_exists(subdomain_name)
    if subdomain_exists
      access_token = subdomain_exists[0]['access_token']
      token_type = subdomain_exists[0]['token_type']
      people_pipeline_email_with_zendesk_id_array = PipeLineDeals.get_company_people_zendesk_id(data,subdomain_name,access_token,token_type)
      get_all_company_people_tickets(people_pipeline_email_with_zendesk_id_array,subdomain_name,access_token,token_type)
    end
  end



  def get_all_company_people_tickets(email_with_uid_array,subdomain_name,access_token,token_type)
    data_array = []
    if email_with_uid_array.any?
      email_with_uid_array.each do |data|
        response = Hash.new
        data_hash = data[0]
        pipline_email = data_hash[:email]
        zendesk_user_id = data_hash[:zendesk_id]
        response["email"]= pipline_email
        response["tickets"] =nil
        if zendesk_user_id
          response["tickets"] = zendesk_people_tickets(zendesk_user_id,subdomain_name,access_token,token_type)
        end
        data_array << response
      end
    end
    render :json => data_array.to_json, :status => 200 and return false
  end


end
