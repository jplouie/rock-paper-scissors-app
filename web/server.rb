require 'sinatra'
require 'pry-byebug'
require_relative '../config/environments.rb'

class RPS::Server < Sinatra::Application
  configure do
    set :bind, '0.0.0.0'
    enable :sessions
  end

  def check_login
    if !session[:user_id]
      redirect to('/login')
    end
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    @user = RPS::User.find_by(username: params[:name])
    if @user && @user.validate_password(params[:password])
      session[:user_id] = @user.id
      redirect to("/tournies")
    else
      redirect to('/login')
    end
  end

  post '/signup' do
    @user = RPS::User.new(
      username: params[:name],
      password_hash: RPS::User.encrypt_password(params[:password])
    )
    if @user.valid?
      @user.save
      RPS::Player.new(
        name: params[:name],
        wins: 0,
        loss: 0
      )
      redirect to("/tournies")
    else
      redirect to('/login')
    end
  end

  get '/tournies' do
    check_login
    @players = RPS::Player.all
    @players = @players.sort_by { |player| player.wins }.reverse
    @actives = RPS::Active.where(status: 'active')
    @actives = @actives.sort_by { |tourny| tourny.id }
    @finished = RPS::Active.where(status: 'finished')
    @finished = @finished.sort_by { |tourny| tourny.id }
    erb :actives
  end

  get '/tournies/new' do
    check_login
    erb :new
  end

  get '/tournies/:id' do
    check_login
    @tourny = RPS::Active.find(params[:id])
    @tournies = RPS::Tourny.where(active_id: @tourny.id)
    @all_players = @tournies.map do |player|
      RPS::Player.find(player.player_id)
    end
    @all_players = @all_players.sort_by { |player| player.id }
    @tournies = @tournies.sort_by { |player| player.slot_number }
    if @tourny.status == 'active'
      @players = RPS::Tourny.where(active_id: @tourny.id, status: 'waiting')
      @players = @players.map { |player| RPS::Player.find(player.player_id) }
      @players = @players.sort_by { |player| player.id }
      erb :tourny
    else
      @player = RPS::Tourny.find_by(active_id: @tourny.id, status: 'champion')
      @winner = RPS::Player.find(@player.player_id)
      erb :finished
    end
  end

  post '/tournies/:id' do
    RPS::Tourny.move(params)
  end

  post '/tournies' do
    @new_tourny = RPS::Active.create(status: 'active')
    @players = params[:players]
    @init_round = 0
    @players.each_index do |i|
      @init_round += 1 if i % 2 == 0
      @p = RPS::Player.find_by(name: @players[i])
      if @p
        RPS::Tourny.create(
          active_id: @new_tourny.id,
          player_id: @p.id,
          status: 'waiting',
          round: @init_round,
          slot_number: i + 1
        )
      else
        @p = RPS::Player.create(name: @players[i], wins: 0, loss: 0)
        RPS::Tourny.create(
          active_id: @new_tourny.id,
          player_id: @p.id,
          status: 'waiting',
          round: @init_round,
          slot_number: i + 1
        )
      end
    end
    redirect to('/tournies')
  end

  delete '/logout' do
    session[:user_id] = nil
    redirect to('/tournies')
  end
end