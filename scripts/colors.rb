ENV['RAILS_ENV'] = 'development'
require 'rubygems'
require 'mongo'
require 'progressbar'
require 'config/environment'

@db = Mongo::Connection.new.db('gilt-look-colors-test')
@coll = @db.collection("looks")
@coll.create_index("look_id")


pbar = ProgressBar.new("Processing Images", 101321)

ProductLook.find_each do |look|
  pbar.inc
  begin
    image_id = look.image_1_id
    next unless image_id
    next if @coll.find("look_id" => look.id).count > 0

    path = AssetUtil.id_to_path(image_id) + "/swatch.jpg"
    next unless File.exist?(path)

    doc = {
      "look_id" => look.id,
      "image_path" => path,
      "colors" => []
    }

    #puts path
    #puts "colors: "
    image = Magick::Image.read(path)[0]
    image = image.quantize(4, Magick::YUVColorspace, Magick::RiemersmaDitherMethod, 8)
    image.color_histogram.each do |pixel, amount|
      doc["colors"] << { "red" => pixel.red.to_i, "green" => pixel.green.to_i, "blue" => pixel.blue.to_i, "amount" => amount.to_i }
    end

    unless doc["colors"].empty?
      @coll.insert(doc)
    end
  rescue
    puts "Failed on look #{look.id}"
  end
end

pbar.finish
