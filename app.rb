require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'open-uri'
require 'sinatra/json'
require 'RMagick'
require './models.rb'

before do
  Dotenv.load
  Cloudinary.config do |config|
    config.cloud_name = ENV['CLOUD_NAME']
    config.api_key    = ENV['CLOUDINARY_API_KEY']
    config.api_secret = ENV['CLOUDINARY_API_SECRET']
  end
end


get '/' do
  erb :index
end

get '/timeline' do
  @contributions = Contribution.all.order(like: :desc)
  erb :timeline
end

get '/new' do
  @mentors = Mentor.all
  erb :new
end

post '/new' do
  text = params[:text]
  mentor = Mentor.find(params[:mentor].to_i)
  author = params[:author]
  file = mentor.image
  image = Magick::Image.read(file).shift

  if mentor.wide
    annotate = Magick::Draw.new
    font = 'public/fonts/cinecaption226.ttf'
    text = "#{mentor.name}「#{text}」"
    annotate.annotate(image, 0, 0, 20, 275, text) do
      self.font      = font
      self.fill      = 'white'
      self.stroke    = 'transparent'
      self.pointsize = 12
      self.gravity   = Magick::NorthWestGravity
    end
  else
    annotate = Magick::Draw.new
    font = 'public/fonts/cinecaption226.ttf'
    text = "#{mentor.name}\n「#{text}」"
    annotate.annotate(image, 0, 0, 10, 460, text) do
      self.font      = font
      self.fill      = 'white'
      self.stroke    = 'transparent'
      self.pointsize = 12
      self.interline_spacing = 2
      self.gravity   = Magick::NorthWestGravity
    end
  end

  tempfile = Tempfile.open('temp')
  image.write("jpg:" + tempfile.path)

  upload = Cloudinary::Uploader.upload(tempfile.path)

  Contribution.create({
    image: upload['url'],
    author: author,
    mentor_id: params[:mentor].to_i,
    like: 0
  })

  redirect '/timeline'
end

post '/like/:id' do
  contribution = Contribution.find(params[:id])
  contribution.update_column(:like, contribution.like + 1)
end

get '/mentors_add' do
  erb :mentor
end

post '/new_mentor' do
  file = params[:file]
  name = params[:name]

  tmpfile = file[:tempfile]
  original = Magick::Image.read(tmpfile.path).shift
  if original.columns > original.rows
    wide = true
    image = original.resize_to_fill(500, 300)
    draw = Magick::Draw.new
    draw.fill = 'black'
    draw.stroke = 'none'
    draw.rectangle(0, 0, 500, 30)
    draw.draw(image)
    draw = Magick::Draw.new
    draw.fill = 'black'
    draw.stroke = 'none'
    draw.rectangle(0, 270, 500, 300)
    draw.draw(image)
    drawimage = Tempfile.open('temp')
    image.write("jpg:" + drawimage.path)
  else
    wide = false
    image = original.resize_to_fill(300,500)
    draw = Magick::Draw.new
    draw = Magick::Draw.new
    draw.fill = 'black'
    draw.stroke = 'none'
    draw.rectangle(0, 450, 300, 500)
    draw.draw(image)
    drawimage = Tempfile.open('temp')
    image.write("jpg:" + drawimage.path)
  end

  upload = Cloudinary::Uploader.upload(drawimage.path)

  Mentor.create({
    image: upload['url'],
    name: name,
    wide: wide
  })
  redirect '/new'
end

post '/delete/:id' do
  contribution = Contribution.find(params[:id])
  contribution.destroy
  redirect '/timeline'
end