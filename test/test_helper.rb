require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'matchy'
require 'fakeweb'

FakeWeb.allow_net_connect = false

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'gluepi'

class Test::Unit::TestCase
end

def api_uri(path)
  base_uri = Gluepi::Client::API_URI.gsub(/\/v1/, ":80/v1")
  "#{base_uri}#{path}"
end

def fixture_file(filename)
  return '' if filename == ''
  file_path = File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
  File.read(file_path)
end

def stub_get(url, filename, status = nil)
  stub_uri(:get, url, filename, status)
end
  
def stub_post(url, filename, status = nil)
  stub_uri(:post, url, filename, status)
end

def stub_uri(method, url, filename, status = nil)
  options = { :string => fixture_file(filename) }
  options[:status] = status unless status.nil?

  uri = api_uri(url).gsub(/:\/\//, "://username:password@")
  FakeWeb.register_uri(method, uri, options)
end
  
def stub_login
   stub_get("/user/validate", "authentication/success.xml")
   Gluepi.login("username", "password")
end


