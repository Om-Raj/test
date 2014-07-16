require 'lib_people'
class PeopleController < ApplicationController
  def index
    subdomain_name = params[:subdomain_name]
    pipeline_user_id = params[:pipeline_user_id]
    pipeline_secret = params[:pipeline_secret]
    if subdomain_name && pipeline_user_id && pipeline_secret
      people_email = PipeLineDeals.get_people_email(pipeline_user_id,pipeline_secret)
      return_json_obj(people_email,subdomain_name,"people")
    end
  end

end