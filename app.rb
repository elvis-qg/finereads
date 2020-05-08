require 'sinatra'
require "sinatra/reloader" if development?


get "/" do 
  erb :landing_page, :layout => false
end