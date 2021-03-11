require 'net/http'
require 'net/https'
require 'json'
require 'time'
require 'logger'

$logger = Logger.new(STDERR)

def fetch_last_updated_from_html(url)
  body = Net::HTTP.get(URI.parse(url))
  lines = body.split("\n")
  lines.grep(/data-refresh-info-last-updated-value/)
    .first
    .to_s
    .split('=')
    .last
    .to_s
    .gsub('"', '')
rescue => ex
  $logger.error(ex)
  nil
end

def fetch_last_modified_from_http(url)
  uri = URI.parse(url)
  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
    request = Net::HTTP::Get.new(uri)
    response = http.request(request)

    if response.code == '200'
      Hash[response.each_header.to_a]['last-modified']
    else
      nil
    end
  end
rescue => ex
  $logger.error(ex)
  nil
end

def fetch_status(url)
  JSON.parse(Net::HTTP.get(URI.parse(url)))
rescue => ex
  $logger.error(ex)
  {}
end

def delta_time(value)
  Time.now.to_i - (Time.parse(value) || 0).to_i
rescue => ex
  $logger.error(ex)
  nil
end