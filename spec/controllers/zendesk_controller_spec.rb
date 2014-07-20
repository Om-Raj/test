require 'spec_helper'
describe ZendeskController do

  describe "without any parameters" do
    it "should be bad request" do
      get 'zendesk_authorizations'
      expect(response.location).to match("required_parameters_missing")
    end
  end

  describe "create request with valid parameters" do
    it "should be redirect to pipelinedeals.zendesk.com for request code" do
      @request.host = "localhost:3000"
      get 'zendesk_authorizations' , {:subdomain_name => 'pipelinedeals',:unique_identifier => 'pipeline_deals_demo',:secret => '38dc2bd42c19f71dad666a013c5fa70476c6936d325836ec4fbf2c61d2b7314e'}
      expect(response).to redirect_to("https://pipelinedeals.zendesk.com/oauth/authorizations/new?response_type=code&redirect_uri=http://localhost:3000/zendesk/get_access_token/&client_id=pipeline_deals_demo&scope=read%20write")
    end
  end


  describe "in get_access_token method should have no code parameters" do
    it "should be bad request" do
      get 'get_access_token'
      expect(response.location).to match("authentication_failed")
    end
  end

end