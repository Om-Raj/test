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

# creating json success object where need to render nothing
  def get_success_object(name,msg,code)
    error_obj = API_SUCCESS
    error_obj[:Success][:Success] = name
    error_obj[:Success][:Message] = msg
    error_obj[:Success][:StatusCode] = code
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

end
