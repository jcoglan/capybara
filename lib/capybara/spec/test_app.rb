require 'sinatra/base'
require 'rack'
require 'yaml'

class TestApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :static, true

  def self.page(method, path, &handler)
    template_name = ('template_' + path.gsub(/[^a-z]/i, '')).to_sym
    template(template_name, &handler)
    __send__(method, path) { erb(template_name) }
  end

  page :get, '/' do
    'Hello world!'
  end

  page :get, '/foo' do
    'Another World'
  end

  get '/redirect' do
    redirect '/redirect_again'
  end

  get '/redirect_again' do
    redirect '/landed'
  end

  page :get, '/host' do
    <<-HTML
    Current host is <%= request.scheme %>://<%= request.host %>
    HTML
  end

  page :get, '/redirect/:times/times' do
    <<-HTML
    <%
    times = params[:times].to_i
    if times.zero? %>
      redirection complete
    <% else
      redirect "/redirect/" + (times - 1).to_s + "/times"
    end
    %>
    HTML
  end

  page :get, '/landed' do
    "You landed"
  end

  page :get, '/with-quotes' do
    %q{"No," he said, "you can't do that."}
  end

  page :get, '/form/get' do
    '<pre id="results"><%= params[:form].to_yaml %></pre>'
  end

  page :get, '/favicon.ico' do
    ''
  end

  post '/redirect' do
    redirect '/redirect_again'
  end

  page :get, "/delete" do
    "The requested object was deleted"
  end

  page :delete, "/delete" do
    "The requested object was deleted"
  end

  get '/redirect_back' do
    redirect back
  end

  page :get, '/slow_response' do
    sleep 2
    'Finally!'
  end

  page :get, '/set_cookie' do
    <<-HTML
    <%
    cookie_value = 'test_cookie'
    response.set_cookie('capybara', cookie_value)
    %>
    
    Cookie set to <%= cookie_value %>
    HTML
  end

  page :get, '/get_cookie' do
    "<%= request.cookies['capybara'] %>"
  end

  page :get, '/get_header' do
    <<-HTML
    <%= env['HTTP_FOO'] %>
    HTML
  end

  page :get, '/:view' do |view|
    <<-HTML
    <%= erb params[:view].to_sym %>
    HTML
  end

  page :post, '/form' do
    '<pre id="results"><%= params[:form].to_yaml %></pre>'
  end

  page :post, '/upload_empty' do
    <<-HTML
    <%=
    if params[:form][:file].nil?
      'Successfully ignored empty file field.'
    else
      'Something went wrong.'
    end
    %>
    HTML
  end

  page :post, '/upload' do
    <<-HTML
    <%=
    begin
      buffer = []
      buffer << "Content-type: " + params[:form][:document][:type]
      buffer << "File content: " + params[:form][:document][:tempfile].read
      buffer.join(' | ')
    rescue
      'No file uploaded'
    end
    %>
    HTML
  end

  page :post, '/upload_multiple' do
    <<-HTML
    <%=
    begin
      buffer = []
      buffer << "Content-type: #{params[:form][:multiple_documents][0][:type]}"
      buffer << "File content: #{params[:form][:multiple_documents][0][:tempfile].read}"
      buffer.join(' | ')
    rescue
      'No files uploaded'
    end
    %>
    HTML
  end
end

if __FILE__ == $0
  Rack::Handler::WEBrick.run TestApp, :Port => 8070
end
