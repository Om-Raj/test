require 'spec_helper'
describe DealsController do

  context 'when no parameters defined' do
    it "has 400 code required parameters missing if no subdomain , secret key and deals id" do
      get 'index'
      expect(response.status).to eq(400)
    end
  end

  context 'when no secret key and deals id' do
    it "has 400 code required parameters missing if no secret key and deals id" do
      get 'index', {:subdomain_name => 'pipelinedeals'}
      expect(response.status).to eq(400) #Required parameters missing (Bad Request)
    end
  end

  context 'when no deals id' do
    it "has 400 code required parameters missing if no deals id" do
      get 'index', {:subdomain_name => 'pipelinedeals',:pipeline_secret => 'CuQxWURE6tHVrURlucW'}
      expect(response.status).to eq(400)
    end
  end


  context 'when invalid secret key' do
    it "has 401 Unauthorized code if valid subdomain and deals id but invalid secret" do
      get 'index', {:subdomain_name => 'pipelinedeals',:pipeline_secret => 'invalid',:pipeline_deals_id => '6259998'}
      expect(response.status).to eq(401)
    end
  end

  context 'when invalid deals id' do
    it "has 403 Forbidden status code if subdomain, secret and invalid deals id" do
      get 'index', {:subdomain_name => 'pipelinedeals',:pipeline_secret => 'CuQxWURE6tHVrURlucW',:pipeline_deals_id => '045334'}
      expect(response.status).to eq(403)
    end
  end

  context 'when valid parameters for GET Request' do
    it "has 200 status code if GET request with valid subdomain,secret and deals id" do
      get 'index', {:subdomain_name => 'pipelinedeals',:pipeline_secret => 'CuQxWURE6tHVrURlucW',:pipeline_deals_id => '6259998'}
      expect(response.status).to eq(200)
    end
  end

  context 'when valid parameters for POST Request' do
    it "has 200 status code if POST request with valid subdomain,secret and deals id" do
      post 'index', {:subdomain_name => 'pipelinedeals',:pipeline_secret => 'CuQxWURE6tHVrURlucW',:pipeline_deals_id => '6259998'}
      expect(response.status).to eq(200)
    end
  end

end
