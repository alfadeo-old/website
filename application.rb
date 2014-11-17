require "rubygems"
require "sinatra"
require "sass"
require "haml"

get "/?" do
  redirect to("/news")
end

get "/news/?" do
  haml :news
end

get "/download/:set/:zip" do
  send_file File.join(settings.public_folder, "sets", "#{params[:set]}", "#{params[:zip]}")
end

get "/releases/?" do
  @hash = {}
  releases = Dir.entries("public/sets/releases").select{|entry| !(entry =='.' || entry == '..')}.sort{|a,b| a <=> b}
  releases.each do |release|
    @hash["#{release}"] = [File.read("public/sets/releases/#{release}/date").chomp]
    tracksfile = File.read("public/sets/releases/#{release}/#{release}")
    @hash["#{release}"] << tracksfile.split("\n")
    cover = Dir.entries("public/sets/releases/#{release}").delete_if{|entry| !entry.match(".jpg")}
    @hash["#{release}"] << cover[0]
  end
  haml :releases
end

get "/archive/?" do
  @hash = {}
  sets = Dir.entries("public/sets").select {|entry| File.directory?(File.join "public/sets/"+entry) and !(entry =='.' || entry == '..' || entry == "releases") }
  sets.each do |set|
    @hash["#{set}"] = [File.read("public/sets/#{set}/date").chomp]
    tracks = Dir.entries("public/sets/#{set}").select{|entry| entry =~ /\.mp3$/ }.sort{|a,b| a <=> b}
    @hash["#{set}"] << tracks
    cover = Dir.entries("public/sets/#{set}").select{|entry| entry.match(".jpg") }[0]
    @hash["#{set}"] << cover
    download = Dir.entries("public/sets/#{set}").select{|entry| entry.match(".zip") }
    @hash["#{set}"] << download[0]
  end
  haml :archive
end

get "/dicrom/?" do
  haml :dicrom
end

get "/remixes/?" do
  haml :remixes
end

get "/videos/?" do
  haml :videos
end

get "/images/?" do
  @albums = {}
  Dir["public/images/*"].each do |album|
    @albums[File.basename(album)] = Dir["#{album}/*"].collect{|t| t.sub(/public\//,'') unless t.match(/thumbs/)}.compact
  end
  haml :images
end

get "/about/?" do
  haml :about
end

get "/style.css" do
  headers "Content-Type" => "text/css; charset=utf-8"
  sass :style
end
