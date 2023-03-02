require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "yaml"
require "pry"

def root
  File.expand_path("..","__FILE__")
end

def load_contacts
  session[:contacts] = YAML.load_file(File.join(root, "user_contacts.yml"))
end

configure do
  enable :sessions
  # set :session_secret, 'secret'

end

# Loads contacts from file at start of sesison, else returns contacts from session
def contacts
  load_contacts if session[:contacts].nil?
  session[:contacts]
end

get "/" do
  @contacts_list = contacts
  erb :contacts
end

get "/edit/:id" do
  @id = params[:id]
  @contact = session[:contacts][@id]
  erb :edit
end

post "/edit/:id" do
  contact_record = params.keys.each_with_object({}) do |key, obj|
    obj[key] = params[key] unless key == "id"
  end
  session[:contacts][params[:id]] = contact_record
  redirect "/"
end
