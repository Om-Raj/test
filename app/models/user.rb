class User < ActiveRecord::Base
  attr_accessible :access_token,:subdomain, :token_type, :unique_identifier, :secret
  scope :subdomain_exists, lambda { |sub_name| where(:subdomain => sub_name) unless sub_name.nil? }

  def self.saved_subdomain(subdomain_name,unique_identifier,secret_key)
    User.create(:subdomain => subdomain_name,:unique_identifier => unique_identifier,:secret => secret_key)
  end

  def self.update_subdomain(userObj,token_type,access_token)
    userObj[0].token_type = token_type
    userObj[0].access_token = access_token
    userObj[0].save
  end
end
