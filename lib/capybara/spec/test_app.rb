require 'sinatra/base'
require 'rack'
require 'yaml'

class TestApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :static, true

  def self.get_page(path, &handler)
    template_name = ('template_' + path.gsub(/[^a-z]/i, '')).to_sym
    template(template_name, &handler)
    get(path) { erb(template_name) }
  end

  get_page '/' do
    'Hello world!'
  end

  get_page '/foo' do
    'Another World'
  end

  get_page '/redirect' do
    redirect '/redirect_again'
  end

  get_page '/redirect_again' do
    redirect '/landed'
  end

  get_page '/redirect/:times/times' do
    times = params[:times].to_i
    if times.zero?
      "redirection complete"
    else
      redirect "/redirect/#{times - 1}/times"
    end
  end

  get_page '/landed' do
    "You landed"
  end

  get_page '/with-quotes' do
    %q{"No," he said, "you can't do that."}
  end

  get_page '/form/get' do
    '<pre id="results">' + params[:form].to_yaml + '</pre>'
  end

  get_page '/favicon.ico' do
    nil
  end

  post '/redirect' do
    redirect '/redirect_again'
  end

  delete "/delete" do
    "The requested object was deleted"
  end

  get_page '/redirect_back' do
    redirect back
  end

  get_page '/set_cookie' do
    cookie_value = 'test_cookie'
    response.set_cookie('capybara', cookie_value)
    "Cookie set to #{cookie_value}"
  end

  get_page '/get_cookie' do
    request.cookies['capybara']
  end

  get '/:view' do |view|
    erb view.to_sym
  end

  post '/form' do
    '<pre id="results">' + params[:form].to_yaml + '</pre>'
  end

  post '/upload' do
    begin
      buffer = []
      buffer << "Content-type: #{params[:form][:document][:type]}"
      buffer << "File content: #{params[:form][:document][:tempfile].read}"
      buffer.join(' | ')
    rescue
      'No file uploaded'
    end
  end
end

if __FILE__ == $0
  Rack::Handler::Mongrel.run TestApp, :Port => 8070
end
