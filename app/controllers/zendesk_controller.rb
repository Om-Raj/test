require 'zendesk_authentication'
require 'httparty'
require 'json'
require 'open-uri'

class ZendeskController < ApplicationController

  def render_errors_messages(type,mess)
    return "https://www.pipelinedeals.com/admin/partner_integrations?"+ type +"="+ mess.to_s
  end

  def zendesk_authorizations
    subdomain_name = params[:subdomain_name]
    unique_identifier = params[:unique_identifier]
    secret = params[:secret]
    if subdomain_name && unique_identifier && secret
      session[:subdomain] = subdomain_name
      zen_request_url = ZendeskAuth.get_zendesk_auth_url(subdomain_name,unique_identifier,secret,zendesk_get_access_token_url)
      zen_request_url ? (redirect_to zen_request_url) : (redirect_to render_errors_messages(I18n.t(:message),I18n.t(:already_authenticated)))
    else
      redirect_to render_errors_messages(I18n.t(:error),I18n.t(:param_missing))
    end
  end

  def get_access_token
    if params[:code]
      subdomain_exists = User.subdomain_exists(session[:subdomain])
      subdomain = session[:subdomain]
      code = params[:code]
      unique_identifier = subdomain_exists[0]['unique_identifier']
      secret = subdomain_exists[0]['secret']
      zendesk_response = HTTParty.post(ZendeskAuth.request_token_url(subdomain,code,unique_identifier,secret,zendesk_get_access_token_url))
      update_response = ZendeskAuth.get_and_save_access_token(zendesk_response,subdomain)
      redirect_to render_errors_messages(I18n.t(:message),I18n.t(:auth_successful)) if update_response
    else
      redirect_to render_errors_messages(I18n.t(:error),I18n.t(:auth_fail))
    end
  end

end