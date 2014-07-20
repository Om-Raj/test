require 'spec_helper'
describe CompaniesController do

  describe "without any parameters" do
    it "should be bad request" do
      get 'index'
      expect(response.message).to eq('Bad Request')
    end
  end


  describe "only subdomain parameter" do
    it "should be bad request" do
      get 'index', {:subdomain_name => 'pipelinedeals'}
      expect(response.status).to eq(400) #Required parameters missing (Bad Request)
    end
  end


  describe "for subdomain and secret parameters" do
    it "should be bad request" do
      get 'index', {:subdomain_name => 'pipelinedeals',:pipeline_secret => 'CuQxWURE6tHVrURlucW'}
      expect(response.status).to eq(400)
    end
  end


  describe "for subdomain,invalid secret and companyid parameters" do
    it "should be bad request" do
      get 'index', {:subdomain_name => 'pipelinedeals',:pipeline_secret => 'invalid',:pipeline_company_id => '21295979'}
      expect(response.status).to eq(401)
    end
  end


  describe "for subdomain, secret and invalid companyid parameters" do
    it "should be bad request" do
      get 'index', {:subdomain_name => 'pipelinedeals',:pipeline_secret => 'CuQxWURE6tHVrURlucW',:pipeline_company_id => '045334'}
       expect(response.status).to eq(403) #Couldn't find Company with ID
    end
  end


  describe "for GET request with valid subdomain,secret and companyid parameters" do
    it "should be bad request" do
      get 'index', {:subdomain_name => 'pipelinedeals',:pipeline_secret => 'CuQxWURE6tHVrURlucW',:pipeline_company_id => '21295979'}
      expect(response.status).to eq(200)
    end
  end

  describe "for POST request with valid subdomain,secret and companyid parameters" do
    it "should be bad request" do
      post 'index', {:subdomain_name => 'pipelinedeals',:pipeline_secret => 'CuQxWURE6tHVrURlucW',:pipeline_company_id => '21295979'}
      expect(response.status).to eq(200)
    end
  end

end
