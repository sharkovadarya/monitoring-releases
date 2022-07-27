require 'sinatra'

class FakeGithub < Sinatra::Base
  get '/repos/rubocop/rubocop/releases' do
    json_response 200, 'rubocop_releases.json'
  end

  get '/repos/rubocop/rubocop/tags' do
    json_response 200, 'rubocop_tags.json'
  end

  get '/repos/rubocop/rubocop/releases/latest' do
    json_response 200, 'rubocop_latest_release.json'
  end

  get '/repos/rspec/rspec-metagem/releases' do
    json_response 200, 'rspec-metagem_releases.json'
  end

  get '/repos/rspec/rspec-metagem/tags' do
    json_response 200, 'rspec-metagem_tags.json'
  end

  get %r{/repos/\w+/[\w-]+/commits/(\w+)} do |c|
    json_response 200, 'commit_' + c[0, 6] + '.json'
  end

  private
  def json_response(response_code, filename)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/' + filename, 'rb').read
  end
end