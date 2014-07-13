
# Config file.
config_file = Rails.root.join('config', 'zendesk.yml').to_s

# Load config file.
begin
  config = YAML.load(File.open(config_file))[Rails.env]
rescue
  raise "Failed to load required config: '#{config_file}'"
end

ENV['client_secret_key'] = config['client_secret_key']
ENV['client_id'] = config['client_id']