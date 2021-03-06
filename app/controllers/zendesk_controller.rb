require 'zendesk_authentication'
require 'httparty'
require 'json'
require 'open-uri'

class ZendeskController < ApplicationController

  def render_errors_messages(type,mess)
    return "https://www.pipelinedeals.com/admin/partner_integrations?"+ type +"="+ mess.to_s
  end
  #redirect to zendesk for app authorizations
  def zendesk_authorizations
    subdomain_name = params[:subdomain_name]
    unique_identifier = params[:unique_identifier]
    secret = params[:secret]
    if subdomain_name && unique_identifier && secret
      session[:subdomain] = subdomain_name
      zen_request_url = ZendeskAuth.get_zendesk_auth_url(subdomain_name,unique_identifier,secret,zendesk_get_access_token_url)
      redirect_to URI.encode(zen_request_url)
    else
      redirect_to render_errors_messages(I18n.t(:error),I18n.t(:param_missing))
    end
  end

  #get code params from zendesk and make request for get access_token and token_type.
  def get_access_token
     unless params[:code].blank? 
      subdomain = session[:subdomain]
      code = params[:code]
      unique_identifier = get_user_secret_unique_identifier["unique_identifier"]
      secret = get_user_secret_unique_identifier["secret"]
      request_url = zendesk_request_token_url(subdomain,code,unique_identifier,secret,zendesk_get_access_token_url)
      zendesk_response = HTTParty.post(request_url)
      update_response = save_access_token(zendesk_response,subdomain)
      redirect_to render_errors_messages(I18n.t(:message),I18n.t(:auth_successful)) if update_response
    else
      redirect_to render_errors_messages(I18n.t(:error),I18n.t(:auth_fail))
    end
  end

  def get_user_secret_unique_identifier
    user_data = Hash.new
    subdomain_exists = User.subdomain_exists(session[:subdomain])
    if subdomain_exists
      user_data =  { "unique_identifier" => subdomain_exists[0]['unique_identifier'],
                     "secret" => subdomain_exists[0]['secret'] }
    end
    return user_data
  end

end
