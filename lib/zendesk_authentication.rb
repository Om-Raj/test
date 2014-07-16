module ZendeskAuth
  def self.get_zendesk_auth_url(subdomain_name,unique_identifier,secret_key,zendesk_get_access_token_url)
    url = "https://#{subdomain_name}.zendesk.com/oauth/authorizations/new?response_type=code&redirect_uri=#{zendesk_get_access_token_url}/&client_id=#{unique_identifier}&scope=read write"
    userObj = User.subdomain_exists(subdomain_name)
    if userObj.empty?
      User.saved_subdomain(subdomain_name,unique_identifier,secret_key)
    else
      User.update_identifier_key(userObj,unique_identifier,secret_key)
    end
    return url
  end

  def self.get_and_save_access_token(response,subdomain_name)
    if response.response.code.to_i == 200
      response_json = JSON.parse response.response.body
      userObj = User.subdomain_exists(subdomain_name)
      User.update_subdomain(userObj,response_json["token_type"],response_json["access_token"])
    end
  end

  def self.request_token_url(subdomain_name,code,unique_identifier,secret_key,return_url)
    return  'https://'"#{subdomain_name}"'.zendesk.com/oauth/tokens?grant_type=authorization_code&code='+ code + '&client_id='+ unique_identifier +'&client_secret='+ secret_key +'&redirect_uri='"#{return_url}"'/&scope=read'
  end

end