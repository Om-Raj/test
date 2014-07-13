require 'pipeline_lib'

class PipelineController < ApplicationController

  def render_errors_messages(page,type,mess)
    https://www.pipelinedeals.com/people
    return "https://www.pipelinedeals.com/#{page}?"+ type +"="+ mess.to_s
  end

  def user
    subdomain_name = params[:subdomain_name]
    pipeline_user_id = params[:pipeline_user_id]
    pipeline_secret = params[:pipeline_secret]
    if subdomain_name && pipeline_user_id && pipeline_secret
      people_email = PipeLineDeals.get_people_email(pipeline_user_id,pipeline_secret)
      if people_email
        people_zendesk_id(people_email,subdomain_name)
      else
        redirect_to render_errors_messages('people',I18n.t(:error),I18n.t(:user_email_not_found))
      end
    else
      redirect_to render_errors_messages('people',I18n.t(:error),I18n.t(:param_missing))
    end
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

  def people_zendesk_id(people_email,subdomain_name)
    subdomain_exists = User.subdomain_exists(subdomain_name)
    unless subdomain_exists.blank?
      access_token = subdomain_exists[0]['access_token']
      token_type = subdomain_exists[0]['token_type']
      people_zendesk_id = PipeLineDeals.get_people_zendesk_id(subdomain_name,people_email,access_token,token_type)
      zendesk_people_tickets(people_zendesk_id,subdomain_name,access_token,token_type)
    end

  end


  def zendesk_people_tickets(people_zendesk_id,subdomain_name,access_token,token_type)
    all_tickets = PipeLineDeals.get_all_tickets_people(subdomain_name,people_zendesk_id,access_token,token_type)
    render :json => data_parse_for_tickets(all_tickets).to_json, :status => 200 and return false
  end


end
