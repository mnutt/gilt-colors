require 'rubygems'
require 'sinatra'
require 'mongo'
require 'erb'

get '/' do
  @db = Mongo::Connection.new.db('gilt-look-colors')
  @coll = @db.collection("looks")
  @looks = @coll.find.limit(500)
  erb :index
end

get '/search/:red/:green/:blue' do
  @red, @green, @blue = %w(red green blue).map{|c| params[c.to_sym].to_i }
  @color = "rgb(#{@red}, #{@green}, #{@blue})"
  @db = Mongo::Connection.new.db('gilt-look-colors')
  @coll = @db.collection("colors")
  @colors = @coll.find("red" => { "$gt" => @red.to_i - 15, "$lt" => @red.to_i + 15 },
                       "green" => { "$gt" => @green.to_i - 15, "$lt" => @green.to_i + 15},
                       "blue" => { "$gt" => @blue.to_i - 15, "$lt" => @blue.to_i + 15},
                       "amount" => { "$gt" => 100 }).sort(["amount", 'descending']).limit(300)

  erb :search
end
