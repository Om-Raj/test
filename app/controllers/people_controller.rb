require 'lib_people'
class PeopleController < ApplicationController
  def index
    subdomain_name = params[:subdomain_name]
    pipeline_user_id = params[:pipeline_user_id]
    pipeline_secret = params[:pipeline_secret]
    if subdomain_name && pipeline_user_id && pipeline_secret
      people_email = PipeLineDeals.get_people_email(pipeline_user_id,pipeline_secret)
      if people_email
        code = people_email[0]
        data = people_email[1]
        if code == 200
          people_zendesk_id(data,subdomain_name)
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


  def people_zendesk_id(people_email,subdomain_name)
    subdomain_exists = User.subdomain_exists(subdomain_name)
    unless subdomain_exists.blank?
      access_token = subdomain_exists[0]['access_token']
      token_type = subdomain_exists[0]['token_type']
      people_zendesk_id = PipeLineDeals.get_people_zendesk_id(subdomain_name,people_email,access_token,token_type)
      response = Hash.new
      if people_zendesk_id

        response["tickets"] = zendesk_people_tickets(people_zendesk_id,subdomain_name,access_token,token_type)
        render :json => response.to_json, :status => 200 and return false
      else
        error_obj = get_exception_object(302,I18n.t(:people_id_not_found),302)
        render :json => error_obj.to_json, :status => 302  and return
      end

    end
  end


end