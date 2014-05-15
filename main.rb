require 'rubygems'
require 'sinatra'

set :sessions, true

get '/inline' do
  "Hello from directly within the action!"
end

get '/template' do
  erb :mytemplate
end

get '/nested_template' do
  erb :"/users/profile"
end

get '/nothere' do
  redirect
  end