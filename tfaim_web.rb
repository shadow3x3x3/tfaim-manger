# coding: utf-8
require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erb'
require 'pry'

require_relative 'src/reader'

### Configure && Initialize ###

configure do
  set :concentrations, {}
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
  puts "concentrations: #{settings.concentrations.clear}"
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
  puts "concentrations: #{settings.concentrations}"
  redirect "/food_choice" if params["subject"] == "rechoose"
  puts "### result ###"
  @EDI = calc_edi
  @EDI_male, @EDI_female, @EDI_full = edi_chart(@EDI)
  @table_hash = table_setting(settings.concentrations, @food_list)
  pp @table_hash
  # p @food_list
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
  settings.concentrations[food_name] = []

  food_size = @food_list[food_name].size

  ("0"...food_size.to_s).each do |index|
    settings.concentrations[food_name] << params[index].to_f
  end
end

def calc_edi
  result = {}
  settings.concentrations.each do |food, concentration|
    concentration.each_with_index do |c, i|
      calc_by_age(result, food, c, i)
    end
  end
  age_class = ['kid', 'child', 'teenager', 'adult', 'older']
  age_class.each { |age| calc_statistics(result, age) }
  result
end

def calc_by_age(result, food, c, i)
  @base_intake.each do |age, intake|
    result[age] ||= {}
    result[age][food] ||= []
    result[age][food] << (intake[food][i] * c / 1_000).round(2)
  end
end

def calc_statistics(result, age)
  if age != 'kid'
    # male
    index = get_max_intake(result, "#{age}_male_co")
    get_max_intake(result, "#{age}_male_wg")
    get_wg_exposure(result, "#{age}_male_wg")
    get_relative_max(result, "#{age}_male", index)
    get_co_exposure(result, "#{age}_male")
    # female
    index = get_max_intake(result, "#{age}_female_co")
    get_max_intake(result, "#{age}_female_wg")
    get_wg_exposure(result, "#{age}_female_wg")
    get_relative_max(result, "#{age}_female", index)
    get_co_exposure(result, "#{age}_female")
    # full
    index = get_max_intake(result, "#{age}_full_co")
    get_max_intake(result, "#{age}_full_wg")
    get_wg_exposure(result, "#{age}_full_wg")
    get_relative_max(result, "#{age}_full", index)
    get_co_exposure(result, "#{age}_full")
  else
    index = get_max_intake(result, "#{age}_co")
    get_max_intake(result, "#{age}_wg")
    get_wg_exposure(result, "#{age}_wg")
    get_relative_max(result, age, index)
    get_co_exposure(result, age)
  end
end

def get_max_intake(result, key)
  full_food = []
  result[key.to_sym].each { |_, values| full_food.concat(values) }
  result["#{key}_max".to_sym] = full_food.max
  full_food.index(full_food.max)
end

def get_wg_exposure(result, key)
  result["#{key}_exposure".to_sym] = result[key.to_sym].inject(0) do
    |s, values| s += values[1].inject(:+)
  end
end

def get_relative_max(result, age, index)
  full_food = []
  result["#{age}_wg".to_sym].each { |_, values| full_food.concat(values) }
  result["#{age}_relative".to_sym] = full_food[index]
end

def get_co_exposure(result, key)
  result["#{key}_co_exposure".to_sym] = (result["#{key}_wg_exposure".to_sym] +
    result["#{key}_co_max".to_sym] -
    result["#{key}_relative".to_sym]).round(2)
end

def edi_chart(result)
  [
    [
      0, @EDI[:child_male_co_exposure],
      @EDI[:teenager_male_co_exposure], @EDI[:adult_male_co_exposure],
      @EDI[:older_male_co_exposure]
    ].to_s, [
      0, @EDI[:child_female_co_exposure],
      @EDI[:teenager_female_co_exposure], @EDI[:adult_female_co_exposure],
      @EDI[:older_female_co_exposure]
    ].to_s, [
      @EDI[:kid_co_exposure], @EDI[:child_full_co_exposure],
      @EDI[:teenager_full_co_exposure], @EDI[:adult_full_co_exposure],
      @EDI[:older_full_co_exposure]
    ].to_s
  ]
end

def table_setting(cs, food_list)
  values = {}
  cs.each do |f, c|
    food_list[f].each_with_index { |l, i| values[l] = c[i] }
  end
  values
end