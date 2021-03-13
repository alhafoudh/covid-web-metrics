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

def fetch_response_from_http(url)
  uri = URI.parse(url)
  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
    request = Net::HTTP::Get.new(uri)

    http.request(request)
  end
rescue => ex
  $logger.error(ex)
  nil
end

def fetch_header_from_http(url, header)
  response = fetch_response_from_http(url)

  if response.code == '200'
    Hash[response.each_header.to_a][header]
  else
    nil
  end
rescue => ex
  $logger.error(ex)
  nil
end

def fetch_last_modified_from_http(url)
  fetch_header_from_http(url, 'last-modified')
end

def log_url_header(url, header)
  "url=#{url} header=#{header} value=#{fetch_header_from_http(url, header.downcase)}"
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