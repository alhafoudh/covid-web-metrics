require 'net/http'
require 'json'
require 'time'
require 'logger'

logger = Logger.new(STDERR)

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
  logger.error(ex)
  nil
end

def fetch_status(url)
  JSON.parse(Net::HTTP.get(URI.parse(url)))
rescue => ex
  logger.error(ex)
  {}
end

def delta_time(value)
  Time.now.to_i - (Time.parse(value) || 0).to_i
rescue => ex
  logger.error(ex)
  nil
end