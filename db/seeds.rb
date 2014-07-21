# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.delete_all
User.connection.execute("ALTER TABLE users AUTO_INCREMENT=1")
File.open("#{Rails.root}/db/data/user.txt","r") do |s|
  s.read.each_line do |f|
    id,subdomain,unique_identifier,secret,access_token,token_type,created_at,updated_at = f.chomp.split("|")
    User.create!(:id => id, :subdomain => subdomain,:unique_identifier=>unique_identifier,:secret=>secret,:access_token=>access_token,:token_type=>token_type,:created_at=>created_at,:updated_at=>updated_at)
  end
end
