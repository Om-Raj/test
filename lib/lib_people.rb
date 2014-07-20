require 'httparty'
require 'json'
require 'open-uri'

module PipeLineDeals
  # getting email address form  pipeline user id
  def self.get_people_email(pipeline_user_id,pipeline_secret)
    request_url =  "https://api.pipelinedeals.com/api/v3/people/#{pipeline_user_id}.json?api_key=#{pipeline_secret}"
    request_str_response = HTTParty.get(request_url)
    response_code = request_str_response.response.code.to_i
    case response_code
      when 200
        data = JSON.parse request_str_response.response.body
        email = data["email"]
        email ? response_return(email,200) : response_return("people email address not found",403)
      when 403
        error = request_str_response.parsed_response["error"]
        response_return(error,403)
      else
        response_return('',response_code)
    end
  end

  #return response data with status code
  def self.response_return(data,code)
    return_data = []
    if data
      get_code = code
      case get_code
        when 200
          return_data << 200
          return_data << data
        when 403
          return_data << 403
          return_data << data
        else
          return_data << get_code
          return_data << data
      end
    end
    return return_data
  end

  # getting user id form zendesk
  def self.get_people_zendesk_id(subdomain_name,email,access_token,token_type)
    req_query_str = "https://#{subdomain_name}.zendesk.com/api/v2/search.json?query=type:user+email:#{email}"
    tickets_response = HTTParty.get(req_query_str, :headers => {"Authorization" => "#{token_type} #{access_token}"})
    if tickets_response.response.code.to_i == 200
      data= JSON.parse tickets_response.response.body
      return data["results"].any? ? data["results"][0]["id"] : nil
    end
  end

  # getting all tickets of associated people
  def self.get_all_tickets_people(subdomain_name,uid,access_token,token_type)
    request_str = "https://#{subdomain_name}.zendesk.com/api/v2/users/#{uid}/tickets/requested.json"
    tickets_response = HTTParty.get(request_str, :headers => {"Authorization" => "#{token_type} #{access_token}"})
    response_code = tickets_response.response.code.to_i
    if tickets_response.response.code.to_i == 200
      return JSON.parse tickets_response.response.body
    end
  end


  # getting email address form  pipeline user id
  def self.get_people_associated_company_or_deals(company_id,pipeline_secret,type)
    request_url = "https://api.pipelinedeals.com/api/v3/#{type}/#{company_id}/people.json?api_key=#{pipeline_secret}"
    request_str_response = HTTParty.get(request_url)
    response_code = request_str_response.response.code.to_i
    case response_code
      when 200
        data = JSON.parse request_str_response.response.body
        company_data = people_data_parse(data)
        company_data ? people_email(company_data) : response_return("people email address associated with #{type} not found",403)
      when 403
        data =JSON.parse request_str_response
        error = data["error"]
        response_return(error,403)
      else
        response_return("",response_code)
    end
  end


  #data parser for user details  entries object
  def self.people_data_parse(json)
    company_data  = nil
    if json
      data = []
      entries = json['entries']
      entries_length = json['entries'].length
      if entries && entries_length >= 0
        entries.each_with_index do |page, index|
          email = page['email']
          if email
            data << email
          end
        end
        company_data = data
      end
    end
    return company_data
  end

  # return people email
  def self.people_email(data)
    return_data = []
    if data
      return_data << 200
      return_data << data
    end
    return return_data
  end

  # return people zendesk id
  def self.people_zendesk_id(data,subdomain_name,access_token,token_type)
    data_emails_array = data
    return_data = []
    if data_emails_array.any?
      data_emails_array.each do |data|
        data_email_and_id = []
        people_email = data
        zendesk_id = get_people_zendesk_id(subdomain_name,people_email,access_token,token_type)
        data_email_and_id << { :email => people_email,
                               :zendesk_id => zendesk_id
        }
        return_data <<  data_email_and_id
      end
    end
    return return_data
  end

end