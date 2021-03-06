require 'spec_helper'
describe PeopleController do

  context 'when no parameters defined' do
    it "has 400 code required parameters missing if no subdomain , secret key and people id" do
      get 'index'
      expect(response.status).to eq(400)
    end
  end

  context 'when no secret key and people id' do
    it "has 400 code required parameters missing if no secret key and people id" do
      get 'index', {:subdomain_name => 'pipelinedeals'}
      expect(response.status).to eq(400)
    end
  end

  context 'when no people id' do
    it "has 400 code required parameters missing if no people id" do
      get 'index', {:subdomain_name => 'pipelinedeals',:pipeline_secret => 'CuQxWURE6tHVrURlucW'}
      expect(response.status).to eq(400)
    end
  end


  context 'when invalid secret key' do
    it "has 401 Unauthorized code if valid subdomain and people id but invalid secret" do
      get 'index', {:subdomain_name => 'pipelinedeals',:pipeline_secret => 'invalid',:pipeline_user_id => '1024984104'}
      expect(response.status).to eq(401)
    end
  end

  context 'when invalid people id' do
    it "has 403 Forbidden status code if subdomain, secret and invalid people id" do
      get 'index', {:subdomain_name => 'pipelinedeals',:pipeline_secret => 'CuQxWURE6tHVrURlucW',:pipeline_user_id => '045334'}
      expect(response.status).to eq(403)
    end
  end

  context 'when valid parameters for GET Request' do
    it "has 200 status code if GET request with valid subdomain,secret and people id" do
      get 'index', {:subdomain_name => 'pipelinedeals',:pipeline_secret => 'CuQxWURE6tHVrURlucW',:pipeline_user_id => '1024984104'}
      expect(response.status).to eq(200)
    end
  end

  context 'when valid parameters for POST Request' do
    it "has 200 status code if POST request with valid subdomain,secret and people id" do
      post 'index', {:subdomain_name => 'pipelinedeals',:pipeline_secret => 'CuQxWURE6tHVrURlucW',:pipeline_user_id => '1024984104'}
      expect(response.status).to eq(200)
    end
  end

end
