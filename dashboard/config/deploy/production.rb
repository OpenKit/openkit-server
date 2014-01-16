set :stage, :production

# Dynamically set these from openkit config
app_ip = '54.184.19.198'
db_ip  = '10.0.0.1'

server app_ip, roles: %w{web app}, node_label: :prod_app1
server db_ip, roles: %w{db}, node_label: :prod_db1
