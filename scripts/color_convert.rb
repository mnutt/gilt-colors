require 'rubygems'
require 'mongo'

@db = Mongo::Connection.new.db('gilt-look-colors')
@looks = @db.collection("looks")
@colors = @db.collection("colors")

@looks.find.each do |look|
  look["colors"].each do |color|
    @colors.insert({ "red" => color["red"],
                     "green" => color["green"],
                     "blue" => color["blue"],
                     "amount" => color["amount"],
                     "look" => {
                       "look_id" => look["look_id"],
                       "swatch_path" => look["image_path"],
                       "image_path" => look["image_path"].sub(/swatch/, "list")
                     }
                   })
  end
end
