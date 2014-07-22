class ApplicationController < ActionController::Base
  protect_from_forgery

  API_EXCEPTION = {
   :Exception => {
    :Message => "",
    :Errors => "",
    :StatusCode => ""
   }
  }

  API_SUCCESS = {
   :Success => {
    :Message => "",
    :Success => "",
    :StatusCode => ""
   }
  }

# creating json error(exception)object
  def get_exception_object(name,msg,code)
    error_obj = API_EXCEPTION
    error_obj[:Exception][:Errors] = name
    error_obj[:Exception][:Message] = msg
    error_obj[:Exception][:StatusCode] = code
    return error_obj
  end

  def zendesk_people_tickets(people_zendesk_id,subdomain_name,access_token,token_type)
    return data_parse_for_tickets(PipeLineDeals.get_all_tickets_people(subdomain_name,people_zendesk_id,access_token,token_type))
  end

  def data_parse_for_tickets(json)
    ticket_lists  = []
    unless json.blank?
      if !json['tickets'].blank? and json['tickets'].length >= 0
        json['tickets'].each_with_index do |page, index|
          ticket_lists << { :subject => page['subject'],
                            :description => page['description'],
                            :request_date => DateTime.strptime(page['created_at'],'%Y-%m-%dT%H:%M:%S%z') ,
                            :status => page['status'],
                            :close_date => DateTime.strptime(page['updated_at'],'%Y-%m-%dT%H:%M:%S%z'),
                            :assignee_id => page['assignee_id'],
                            :rating_score => page['satisfaction_rating']["score"]
          }
        end
      end
    end
    return ticket_lists
  end

  def company_or_deals_people_tickets(data,subdomain_name)
    subdomain_exists = User.subdomain_exists(subdomain_name)
    if subdomain_exists.any?
      access_token = subdomain_exists[0]['access_token']
      token_type = subdomain_exists[0]['token_type']
      unless access_token.blank?
      people_pipeline_email_with_zendesk_id_array = PipeLineDeals.people_zendesk_id(data,subdomain_name,access_token,token_type)
      get_all_company_or_deals_people_tickets(people_pipeline_email_with_zendesk_id_array,subdomain_name,access_token,token_type)
    else
        error_obj = get_exception_object(302,I18n.t(:app_access_token_blank),302)
        render :json => error_obj.to_json, :status => 302  and return
      end

    else
      api_missing_required(I18n.t(:app_not_authorize_with_zendesk))
    end
  end



  def get_all_company_or_deals_people_tickets(email_with_uid_array,subdomain_name,access_token,token_type)
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

  def return_json_obj(people,subdomain_name,type)
    if people
      code = people[0]
      data = people[1]
      if code == 200
        get_type = type
        case get_type
          when "company_or_deals"
        company_or_deals_people_tickets(data,subdomain_name)
      else
          people_zendesk_id(data,subdomain_name)
        end 
      else
        error_obj = get_exception_object(code,data,code)
        render :json => error_obj.to_json, :status => code  and return
      end
    end
  end

  def get_company_or_deals(subdomain_name,pipeline_company_id,pipeline_secret,type)
    if subdomain_name && pipeline_company_id && pipeline_secret
      people = PipeLineDeals.get_people_associated_company_or_deals(pipeline_company_id,pipeline_secret,type)
      return_json_obj(people,subdomain_name,"company_or_deals")
    else
      api_missing_required(I18n.t(:api_missing_required))
    end
  end

  def api_missing_required(mess)
    error_obj = get_exception_object(I18n.t(:code_400),mess,400)
      render :json => error_obj.to_json, :status => 400  and return
    end

  def people_zendesk_id(people_email,subdomain_name)
    subdomain_exists = User.subdomain_exists(subdomain_name)
    unless subdomain_exists.blank?
      access_token = subdomain_exists[0]['access_token']
      token_type = subdomain_exists[0]['token_type']
      unless access_token.blank?
      people_zendesk_id = PipeLineDeals.get_people_zendesk_id(subdomain_name,people_email,access_token,token_type)
      response = Hash.new
      if people_zendesk_id 
        response["tickets"] = zendesk_people_tickets(people_zendesk_id,subdomain_name,access_token,token_type)
        render :json => response.to_json, :status => 200 and return false
      else
        error_obj = get_exception_object(302,I18n.t(:people_id_not_found),302)
        render :json => error_obj.to_json, :status => 302  and return
      end
      else
        error_obj = get_exception_object(302,I18n.t(:app_access_token_blank),302)
        render :json => error_obj.to_json, :status => 302  and return
      end
    end
  end

  def zendesk_request_token_url(subdomain,code,unique_identifier,secret,zendesk_get_access_token_url)
    return ZendeskAuth.request_token_url(subdomain,code,unique_identifier,secret,zendesk_get_access_token_url)
  end

  def save_access_token(zendesk_response,subdomain)
   return ZendeskAuth.get_and_save_access_token(zendesk_response,subdomain)
  end

end
