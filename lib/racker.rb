require 'erb'
require 'yaml'
require_relative 'codebreaker/game'

class Racker
  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def self.call(env)
    new(env).response.finish
  end

  def response
    case @request.path
    
    when '/new'
      clear_data
      @game = Codebreaker::Game.new(@request.params['level'])
      @game.start
      save_state(@game)

      Rack::Response.new do |response|
        response.set_cookie('chances', @game.chances)
        response.redirect('/play')
      end

    when '/guess'
      @game = Codebreaker::Game.new
      state = YAML.load_file('./state.yml')
      @game.instance_variable_set(:@chances, state[:chances])
      @game.instance_variable_set(:@secret_code, Codebreaker::Code.new(state[:secret_code]))

      answer = @game.guess(@request.params['guess'])
      save_state(@game)
      save_guess(@request.params['guess'], answer)

      Rack::Response.new do |response|
        if @game.over?
          response.redirect('/lost')
        else        
          response.set_cookie('chances', @game.chances)
          response.set_cookie('guess', answer)
          answer == '++++' ? response.redirect('/won') : response.redirect('/play')
        end
      end

    when '/'     then Rack::Response.new(render('index.html.erb'))
    when '/play' then Rack::Response.new(render('play.html.erb'))
    when '/lost' then Rack::Response.new(render('lost.html.erb'))
    when '/won'  then Rack::Response.new(render('won.html.erb'))
    else              Rack::Response.new('Not Found', 404)
    end
  end

  def answer
    @request.cookies['guess']
  end

  def chances
    @request.cookies['chances']
  end

  def history
    history = []
    File.open('./guesses') do |file|
      file.each { |line| history << line }
    end
    history
  end
    
  def render(page)
    path = File.expand_path("../views/#{page}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  private

  def save_guess(guess, answer)
    File.open('./guesses', 'a') do |file| 
      file.puts "#{guess}: '#{answer}'"
    end
  end

  def save_state(game)
    File.open('./state.yml', 'w') do |file| 
      file.write({ 
        :chances     => game.chances,
        :secret_code => game.instance_variable_get(:@secret_code).to_s
      }.to_yaml)
    end
  end

  def clear_data
    File.open('./state.yml', 'w') { |file| file.truncate(0) }
    File.open('./guesses', 'w') { |file| file.truncate(0) }
  end
end
