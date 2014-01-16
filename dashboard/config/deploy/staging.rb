set :stage, :staging

# Dynamically set these from openkit config
app_ip = '54.184.19.198'
db_ip  = '10.0.0.1'

server app_ip, roles: %w{web app}, node_label: :staging_app1
