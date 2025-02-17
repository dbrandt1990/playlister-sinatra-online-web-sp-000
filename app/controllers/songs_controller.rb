require 'sinatra/base'
require 'rack-flash'

class SongsController < Sinatra::Base
  enable :sessions
  use Rack::Flash
  register Sinatra::ActiveRecordExtension
  set :session_secret, "my_application_secret"
  set :views, Proc.new { File.join(root, "../views/") }

  get '/songs' do
    @songs = Song.all
    erb :"songs/index"
  end

  get '/songs/new' do 
    @genres = Genre.all
    erb :"songs/new"
  end

  post '/songs' do 
    @song = Song.create(:name=> params[:song][:name])

    artist_entry = params[:song][:artist]

    if Artist.find_by(:name => artist_entry)
      @song.artist = Artist.find_by(:name => artist_entry)
    else
      @song.artist = Artist.create(:name => artist_entry)
    end

    genre_selections = params[:song][:genres]

    genre_selections.each do |genre|
      @song.genres << Genre.find(genre)
  end
  
    @song.save

  flash[:message] = "Successfully created song."
  redirect "/songs/#{@song.slug}"
end

  get '/songs/:slug' do 
    @song = Song.find_by_slug(params[:slug])
    erb :"songs/show"
  end

  patch '/songs/:slug' do 
    song = Song.find_by_slug(params[:slug])
      song.name = params[:song][:name]

      artist_name = params[:song][:artist]

      if Artist.find_by(:name => artist_name)
        if song.artist.name != artist_name
          song.update(:artist => Artist.find_by(:name => artist_name))
        end
      else 
        artist = Artist.create(:name => artist_name)
        song.update(:artist => artist)
      end

        song.genres.clear 
        genres = params[:song][:genres]
        genres.each do |g|
         song.genres << Genre.find(g)
        end

        song.save
        flash[:message] = "Successfully updated song."
        redirect "/songs/#{song.slug}"
  end

  get '/songs/:slug/edit' do 
    @genres = Genre.all
    @song = Song.find_by_slug(params[:slug])
    erb :"songs/edit"
  end
  
end