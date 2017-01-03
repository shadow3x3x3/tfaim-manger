# coding: utf-8
require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erb'
require 'pry'

require_relative 'src/reader'

### Configure && Initialize ###

configure do
  set :food_input, {}
end

before do
  @base_intake = Reader::intake
  @food_list   = Reader::food_list
end

### Routing & Controller ###

# Basic Controller
get '/' do
  @title = "添加物暴露量計算表"
  erb :index
end

get '/intro' do
  erb :intro
end

# User Controller
get '/user_login' do
  erb :"login/user_login"
end

get '/choice' do
  erb :"user/choice"
end

get '/input_choice' do
  puts settings.food_input.clear
  erb :"user/input_choice"
end

get '/food_choice' do
  erb :"user/food_choice"
end

post '/food_forms' do
  @food_kind = params["food-kind"]
  @food_list = @food_list[params["food-kind"].to_sym]
  erb :"user/food_forms"
end

post '/result' do
  input_collector(params)
  p settings.food_input
  redirect "/food_choice" if params["subject"] == "rechoose"
  erb :"user/result"
end

get '/food_upload' do
  erb :"user/food_upload"
end

# Manager Controller
get '/manager_login' do
  erb :"login/manager_login"
end

get '/manager_choice' do
  erb :"manager/manager_choice"
end

get '/manager/user' do
  @title = "管理使用者"
  erb :"manager/user"
end

get '/manager/data' do
  @title = "管理數據資料"
  erb :"manager/data"
end

### Functions ####

def input_collector(params)
  food_name = params["food-kind"].to_sym
  settings.food_input[food_name] = []

  food_size = @food_list[food_name].size

  ("0"...food_size.to_s).each do |index|
    settings.food_input[food_name] << params[index]
  end
end
