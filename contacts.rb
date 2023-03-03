require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "yaml"
require "pry"

def root
  File.expand_path("..","__FILE__")
end

def load_contacts_from_file
  YAML.load_file(File.join(root, "user_contacts.yml"))
end

def set_contacts_in_session
  session[:contacts] = load_contacts_from_file
end

# Loads contacts from file at start of sesison, else returns contacts from session
def contacts
  set_contacts_in_session if session[:contacts].nil?
  session[:contacts]
end

def get_error_message(contact)
  # binding.pry
  return "Name, Email Phone are required fields" if contact["name"].empty? || contact["email"].empty?  || contact["phone"].empty?
  "Email is invalid" unless valid_email?(contact["email"])
end

def valid_email?(email)
  email.count("@.") == 2
end

configure do
  enable :sessions
  # set :session_secret, 'secret'
  set :erb, :escape_html => true
end

# Display contacts
get "/" do
  @contacts_list = contacts
  erb :contacts
end

# Display edit contact form
get "/edit/:id" do
  @id = params[:id]
  @contact = session[:contacts][@id]
  erb :edit
end

# Handle edit contact form
post "/edit/:id" do
  contact_record = params.keys.each_with_object({}) do |key, obj|
    obj[key] = params[key] unless key == "id"
  end
  error_message = get_error_message(contact_record)
  if error_message
    session[:message] = error_message
    @id = params[:id]
    @contact = contact_record
    erb :edit
  else
    session[:contacts][params[:id]] = contact_record
    session[:message] = "Contact updated."
    redirect "/"
  end
end

# Display new contact form
get "/new" do 
  erb :new
end

# Handle new contact form
# post "/new" do |name, email, phone, notes|
post "/new" do
  # %w(foo bar)
  keys = %w(name email phone notes)
  values = [params[:name], params[:email], params[:phone], params[:notes]]
  contact_record = keys.zip(values).to_h
  session[:contacts][params[:email]] = contact_record
  session[:message] = "New contact created."
  redirect "/"
end
