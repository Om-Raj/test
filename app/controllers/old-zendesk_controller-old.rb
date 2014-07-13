require 'httparty'
require 'json'
require 'open-uri'

class ZendeskController < ApplicationController
#  API_EXCEPTION = {
#   :Exception => {
#    :Message => "",
#    :Errors => "",
#    :StatusCode => ""
#   }
#  }
#
##method for exceptions handle
#  def get_exception_object(name,msg,code)
#    error_obj = API_EXCEPTION
#    error_obj[:Exception][:Errors] = name
#    error_obj[:Exception][:Message] = msg
#    error_obj[:Exception][:StatusCode] = code
#    return error_obj
#  end


  def zendesk_authorizations

  end



  # method for authorization for subdomain
  def oauth_authorizations
    if !params[:subdomain_name].blank? and !params[:unique_identifier].blank? and !params[:secret].blank?

    request_link = 'https://'"#{subdomain_name}"'.zendesk.com/oauth/authorizations/new?'
    required_parameters = 'response_type=code&redirect_uri='"#{host_url}"'/zendesk/authorization_zendesk&client_id='+ unique_identifier+'&scope=read write'
    encode_url = CGI.escape(required_parameters)
    redirect_to request_link + encode_url

    else
      error_obj = get_exception_object("Required parameters missing.","Bad Request",400)
      render :json => error_obj.to_json, :status => 400 and return false
    end
  end

  #def oauth_authorizations(subdomain_name,unique_identifier,host_url)
  #  request_link = 'https://'"#{subdomain_name}"'.zendesk.com/oauth/authorizations/new?'
  #  required_parameters = 'response_type=code&redirect_uri='"#{host_url}"'/zendesk/authorization_zendesk&client_id='+ unique_identifier+'&scope=read write'
  #  encode_url = CGI.escape(required_parameters)
  #  redirect_to request_link + encode_url
  #end


  # method for getting access_token and token_type from zendesk.
  def authorization_zendesk
    @error = ""
    @result = ""
    unless params[:code].blank?
      code = params[:code]
      zendesk_response = HTTParty.post('https://'"#{session[:subdomain_name]}"'.zendesk.com/oauth/tokens?grant_type=authorization_code&code='+ code + '&client_id='+ session[:unique_identifier] +'&client_secret='+ session[:secret] +'&redirect_uri='"#{request.protocol}#{request.host_with_port}"'/zendesk/authorization_zendesk&scope=read')
      response_code = zendesk_response.response.code.to_i
      if response_code == 200
        response_json = JSON.parse zendesk_response.response.body

        if !session[:subdomain_name].blank? and !session[:unique_identifier].blank?
          zendesk_user = User.find_by_subdomain_and_unique_identifier session[:subdomain_name] , session[:unique_identifier]

          unless zendesk_user.blank?
            zendesk_user.update_attributes(:subdomain => session[:subdomain_name],:unique_identifier=> session[:unique_identifier],:secret=>session[:secret], :token_type => response_json["token_type"],:user_id => session[:user_id],:first_name => session[:first_name], :last_name => session[:last_name] ,:email => session[:email],:access_token => response_json["access_token"],:company_id => session[:company_id],:api_key=>session[:api_key],:deal_id=>session[:deal_id])
          else
            zendesk_user = User.create(:subdomain => session[:subdomain_name],:unique_identifier=> session[:unique_identifier],:secret=>session[:secret], :token_type => response_json["token_type"],:user_id => session[:user_id],:first_name => session[:first_name], :last_name => session[:last_name] ,:email => session[:email],:access_token => response_json["access_token"],:company_id => session[:company_id],:api_key=>session[:api_key],:deal_id=>session[:deal_id])
          end
          if  session[:req_api] == "tickets_for_user_email"
            get_all_tickets_with_user_details_for_email(session[:subdomain_name],session[:unique_identifier],zendesk_user.token_type,zendesk_user.access_token,session[:email])
          elsif  session[:req_api] == "tickets_for_company_users"
            get_all_tickets_with_user_details_for_company(session[:subdomain_name],session[:unique_identifier],zendesk_user.token_type,zendesk_user.access_token,zendesk_user.company_id,zendesk_user.api_key)
          elsif  session[:req_api] == "tickets_for_deals"
            get_all_tickets_with_user_details_deals(session[:subdomain_name],session[:unique_identifier],zendesk_user.token_type,zendesk_user.access_token,zendesk_user.deal_id,zendesk_user.api_key)
          end
        end
      elsif response_code == 401
        error_obj = get_exception_object(response_json["error_description"],response_json["error"],401)
        render :json => error_obj.to_json, :status => 401 and return false
      end
    end

  end

  # method for getting all tickets by user Id.
  def get_all_tickets_with_user_details_deals(subdomain_name,unique_identifier,token_type,access_token,deal_id,api_key)
    userId_with_email = get_user_id_for_deals(subdomain_name,unique_identifier,token_type,access_token,deal_id,api_key)
    user_tickets_details=[]
    unless userId_with_email.blank?
      userId_with_email.each do |data|
        unless data[:user_id].blank?
          all_tickets = get_all_tickets_for_user_id(subdomain_name,token_type,access_token,data[:user_id])
          user_tickets_details << { :user_id => data[:user_id], :email =>data[:email], :tickets =>all_tickets }
        else
          user_tickets_details << { :user_id => '', :email =>data[:email], :tickets =>'' }
        end
      end
    end
    render :json => user_tickets_details.to_json, :status => 200 and return false
  end

  # method for getting all tickets and user detail for company.
  def get_all_tickets_with_user_details_for_company(subdomain_name,unique_identifier,token_type,access_token,company_id,api_key)
    userId_with_email = get_user_id_for_company_users(subdomain_name,unique_identifier,token_type,access_token,company_id,api_key)
    user_tickets_details=[]
    unless userId_with_email.blank?
      userId_with_email.each do |data|
        unless data[:user_id].blank?
          all_tickets = get_all_tickets_for_user_id(subdomain_name,token_type,access_token,data[:user_id])
          user_tickets_details << { :user_id => data[:user_id], :email =>data[:email], :tickets =>all_tickets }
        else
          user_tickets_details << { :user_id => '', :email =>data[:email], :tickets =>'' }
        end

      end
    end
    render :json => user_tickets_details.to_json, :status => 200 and return false
  end

  # method for get user Id from email address and get all tickets with user Id
  def get_all_tickets_with_user_details_for_email(subdomain_name,unique_identifier,token_type,access_token,email)
    unless email.blank?
      user_id =  get_user_id_for_email_address(subdomain_name,token_type,access_token,email)
      user_tickets_details=[]
      unless user_id.blank?
        all_tickets =  get_all_tickets_for_user_id(subdomain_name,token_type,access_token,user_id)
        user_tickets_details << { :user_id => user_id, :email =>email, :tickets =>all_tickets }
        render :json => user_tickets_details.to_json, :status => 200 and return false
      else
        error_obj = get_exception_object("user id not found.","Not found",302)
        render :json => error_obj.to_json, :status => 302 and return false
      end

    else
      error_obj = get_exception_object("Required parameters missing.","Bad Request",400)
      render :json => error_obj.to_json, :status => 400 and return false
    end
  end

  # method for getting all tickets opened by this particular user( by email)
  def get_all_tickets_for_user_email
    if !params[:subdomain_name].blank? and  !params[:unique_identifier].blank? and  !params[:secret].blank? and !params[:user_id].blank? and  !params[:first_name].blank? and  !params[:last_name].blank?  and  !params[:email].blank?

      session[:subdomain_name] = params[:subdomain_name]
      session[:unique_identifier] = params[:unique_identifier]
      session[:secret] = params[:secret]
      session[:user_id] = params[:user_id]
      session[:first_name] = params[:first_name]
      session[:last_name] = params[:last_name]
      session[:email] = params[:email]
      session[:company_id] =''
      session[:api_key] = ''
      session[:deal_id] = ''
      session[:req_api] = "tickets_for_user_email"

      if !session[:subdomain_name].blank? and !session[:unique_identifier].blank?
        # get token type/access token and save  access token  in our DB.
        zendesk_user = User.find_by_subdomain_and_unique_identifier session[:subdomain_name] , session[:unique_identifier]
        unless zendesk_user.blank?
          session[:token_type] = zendesk_user.token_type
          session[:access_token] = zendesk_user.access_token
          get_all_tickets_with_user_details_for_email(session[:subdomain_name],session[:unique_identifier],zendesk_user.token_type,zendesk_user.access_token,session[:email])
        else
          oauth_authorizations(session[:subdomain_name],session[:unique_identifier],"#{request.protocol}#{request.host_with_port}")
        end

      else
        error_obj = get_exception_object("Required parameters missing.","Bad Request",400)
        render :json => error_obj.to_json, :status => 400 and return false
      end

    else
      error_obj = get_exception_object("Required parameters missing.","Bad Request",400)
      render :json => error_obj.to_json, :status => 400 and return false
    end
  end

  # method for getting all tickets for deals.
  def get_all_tickets_for_deals
    if !params[:subdomain_name].blank? and  !params[:unique_identifier].blank? and  !params[:secret].blank?  and  !params[:deal_id].blank? and  !params[:api_key].blank?

      session[:subdomain_name] = params[:subdomain_name]
      session[:unique_identifier] = params[:unique_identifier]
      session[:secret] = params[:secret]
      session[:company_id] = ''
      session[:deal_id] = params[:deal_id]
      session[:api_key] = params[:api_key]
      session[:user_id] = ''
      session[:first_name] =  ''
      session[:last_name] =  ''
      session[:email] =  ''
      session[:req_api] = "tickets_for_deals"

      if !session[:subdomain_name].blank? and !session[:unique_identifier].blank?
        zendesk_user = User.find_by_subdomain_and_unique_identifier session[:subdomain_name] , session[:unique_identifier]
        unless zendesk_user.blank?
          session[:token_type] = zendesk_user.token_type
          session[:access_token] = zendesk_user.access_token
          #get_all_tickets_with_user_details_for_company(session[:subdomain_name],session[:unique_identifier],zendesk_user.token_type,zendesk_user.access_token,session[:deal_id],session[:api_key])
          get_all_tickets_with_user_details_deals(session[:subdomain_name],session[:unique_identifier],zendesk_user.token_type,zendesk_user.access_token,session[:deal_id],session[:api_key])
        else
          oauth_authorizations(session[:subdomain_name],session[:unique_identifier],"#{request.protocol}#{request.host_with_port}")
        end
      else
        error_obj = get_exception_object("Required parameters missing.","Bad Request",400)
        render :json => error_obj.to_json, :status => 400 and return false
      end
    else
      error_obj = get_exception_object("Required parameters missing.","Bad Request",400)
      render :json => error_obj.to_json, :status => 400 and return false
    end
  end

  # method for getting all tickets for company user.
  def get_all_tickets_for_company_user
    if !params[:subdomain_name].blank? and  !params[:unique_identifier].blank? and  !params[:secret].blank?  and  !params[:company_id].blank? and  !params[:api_key].blank?

      session[:subdomain_name] = params[:subdomain_name]
      session[:unique_identifier] = params[:unique_identifier]
      session[:secret] = params[:secret]
      session[:company_id] = params[:company_id]
      session[:api_key] = params[:api_key]
      session[:user_id] = ''
      session[:first_name] =  ''
      session[:last_name] =  ''
      session[:email] =  ''
      session[:deal_id] = ''
      session[:req_api] = "tickets_for_company_users"

      if !session[:subdomain_name].blank? and !session[:unique_identifier].blank?
        #get token type and access token
        zendesk_user = User.find_by_subdomain_and_unique_identifier session[:subdomain_name] , session[:unique_identifier]
        unless zendesk_user.blank?
          session[:token_type] = zendesk_user.token_type
          session[:access_token] = zendesk_user.access_token
          get_all_tickets_with_user_details_for_company(session[:subdomain_name],session[:unique_identifier],zendesk_user.token_type,zendesk_user.access_token,session[:company_id],session[:api_key])
        else
          oauth_authorizations(session[:subdomain_name],session[:unique_identifier],"#{request.protocol}#{request.host_with_port}")
        end
      else
        error_obj = get_exception_object("Required parameters missing.","Bad Request",400)
        render :json => error_obj.to_json, :status => 400 and return false
      end
    else
      error_obj = get_exception_object("Required parameters missing.","Bad Request",400)
      render :json => error_obj.to_json, :status => 400 and return false
    end
  end

  #geting user id for giving email address by following api
  def get_user_id_for_email_address(subdomain_name,token_type,access_token,email)
    req_query_str = "https://#{subdomain_name}.zendesk.com/api/v2/search.json?query=type:user+email:#{email}"
    tickets_response = HTTParty.get(req_query_str, :headers => {"Authorization" => "#{token_type} #{access_token}"})

    response_code = tickets_response.response.code.to_i
    user_details=""
    if response_code == 200
      response_json = JSON.parse tickets_response.response.body
      return_data = data_parse_for_user_id(response_json)
      unless return_data['data'].blank?
        return_data['data'].each do |data|
          user_details = data[:id]
        end
      end
    end
    return user_details
  end

  #geting all ickets details for giving user ID by following api
  def get_all_tickets_for_user_id(subdomain_name,token_type,access_token,user_id)
    unless user_id.blank?
      request_str = "https://#{subdomain_name}.zendesk.com/api/v2/users/#{user_id}/tickets/requested.json"
      tickets_response = HTTParty.get(request_str, :headers => {"Authorization" => "#{token_type} #{access_token}"})
      response_code = tickets_response.response.code.to_i
      if response_code == 200
        response_json = JSON.parse tickets_response.response.body
        return_data = data_parse_for_tickets(response_json)
        return return_data
      else
        return []
      end
    end
  end

  #geting user id and email for giving deal id by following api
  def get_user_id_for_deals(subdomain_name,unique_identifier,token_type,access_token,deal_id,api_key)
    if !deal_id.blank? and !api_key.blank?
      request_str = "https://api.#{subdomain_name}.com/api/v3/deals/#{deal_id}/people.json?api_key=#{api_key}"
      request_str_response = HTTParty.get(request_str)
      response_code = request_str_response.response.code.to_i
      if response_code == 200
        response_json = JSON.parse request_str_response.response.body
        return_data = user_data_parse(response_json)
        user_details=[]
        unless return_data.blank?
          return_data['data'].each do |data|
            userId =  get_user_id_for_email_address(subdomain_name,token_type,access_token,data[:email])
            user_id = userId.blank? ? "" : userId
            user_details << { :user_id => user_id, :email =>data[:email] }
          end
        end
        return user_details
      else
        error_obj = get_exception_object("Not Found.","Not Found",404)
        render :json => error_obj.to_json, :status => 404 and return false
      end
    else
      error_obj = get_exception_object("Required parameters missing.","Bad Request",400)
      render :json => error_obj.to_json, :status => 400 and return false
    end
  end


  #geting user id for company_id by following api
  def get_user_id_for_company_users(subdomain_name,unique_identifier,token_type,access_token,company_id,api_key)
    if !company_id.blank? and !api_key.blank?
      request_str = "https://api.#{subdomain_name}.com/api/v3/companies/#{company_id}/people.json?api_key=#{api_key}"
      request_str_response = HTTParty.get(request_str)
      response_code = request_str_response.response.code.to_i
      if response_code == 200
        response_json = JSON.parse request_str_response.response.body
        return_data = user_data_parse(response_json)
        user_details=[]
        unless return_data.blank?
          return_data['data'].each do |data|
            userId =  get_user_id_for_email_address(subdomain_name,token_type,access_token,data[:email])
            user_id = userId.blank? ? "" : userId
            user_details << { :user_id => user_id, :email =>data[:email] }
          end
        end
        return user_details
      else
        error_obj = get_exception_object("Not Found.","Not Found",404)
        render :json => error_obj.to_json, :status => 404 and return false
      end
    else
      error_obj = get_exception_object("Required parameters missing.","Bad Request",400)
      render :json => error_obj.to_json, :status => 400 and return false
    end
  end

  #data parser for tickets details
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

  # method for data parser for user details
  def data_parse_for_user_id(json)
    user_lists  = []
    data_hash = Hash.new()
    unless json.blank?
      if !json['results'].blank? and json['results'].length >= 0
        json['results'].each_with_index do |page, index|
          user_lists << { :id => page['id'],
                          :name => page['name'],
                          :email => page['email']
          }
        end
      end
    end
    data_hash["data"] = user_lists
    return data_hash
  end

  #data parser for user details  entries object
  def user_data_parse(json)
    user_lists  = []
    data_hash = Hash.new()
    unless json.blank?
      if !json['entries'].blank? and json['entries'].length >= 0
        json['entries'].each_with_index do |page, index|
          user_lists << { :email => page['email'],
                          :first_name => page['first_name'],
                          :last_name => page['last_name']
          }
        end
      end
    end
    data_hash["data"] = user_lists
    return data_hash
  end

end
