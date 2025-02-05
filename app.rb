# app.rb
require "sinatra"
require "sinatra/activerecord"
require "bcrypt"
require "./models/user"
require "./models/bookmark"
require "securerandom"

set :database_file, "config/database.yml"
enable :sessions
enable :method_override
set :session_secret, SecureRandom.hex(64)

# configure :development do
#   use Rack::LiveReload
# end

helpers do
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def authenticate!
    redirect "/login" unless logged_in?
  end
end

# -----------------------------------------
# AUTH ROUTES (as before)
# -----------------------------------------
get "/" do
  if logged_in?
    redirect "/bookmarks"
  else
    erb :index
  end
end

get "/signup" do
  erb :signup
end

post "/signup" do
  user = User.new(email: params[:email], password: params[:password])
  if user.save
    session[:user_id] = user.id
    redirect "/bookmarks"
  else
    @error = user.errors.full_messages.join(", ")
    erb :signup
  end
end

get "/login" do
  erb :login
end

post "/login" do
  user = User.find_by(email: params[:email])
  if user&.authenticate(params[:password])
    session[:user_id] = user.id
    redirect "/bookmarks"
  else
    @error = "Invalid email or password"
    erb :login
  end
end

get "/logout" do
  session.clear
  redirect "/"
end

# Bookmark routes
get "/bookmarks" do
  authenticate!
  @bookmarks = current_user.bookmarks.order(created_at: :desc)
  erb :bookmarks_index
end

post "/bookmarks" do
  authenticate!
  bookmark = current_user.bookmarks.new(title: params[:title], url: params[:url])
  if bookmark.save
    redirect "/bookmarks"
  else
    error_message = bookmark.errors.full_messages.join(", ")
    redirect "/bookmarks?error=#{URI.encode_www_form(error_message)}"
  end
end

patch "/bookmarks/:id" do
  authenticate!
  bookmark = current_user.bookmarks.find_by(id: params[:id])
  halt 404, "Bookmark not found" unless bookmark

  if bookmark.update(title: params[:title], url: params[:url])
    redirect "/bookmarks"
  else
    error_message = bookmark.errors.full_messages.join(", ")
    redirect "/bookmarks?error=#{URI.encode_www_form(error_message)}"
  end
end

delete "/bookmarks/:id" do
  authenticate!
  bookmark = current_user.bookmarks.find_by(id: params[:id])
  halt 404, "Bookmark not found" unless bookmark

  bookmark.destroy
  redirect "/bookmarks"
end