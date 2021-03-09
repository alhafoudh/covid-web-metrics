require 'json'
require 'pry'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/reloader'
require_relative 'metrics'

class App < Sinatra::Base
  register Sinatra::Reloader

  get '/metrics' do
    content_type 'text/plain'

    [
      {
        name: 'covid_web_status_status_at_cache_delta',
        value: delta_time(fetch_status('https://covid.freevision.sk/status.json').dig('status_at')),
      },
      {
        name: 'covid_web_status_status_at_origin_delta',
        value: delta_time(fetch_status('https://covid-web.charlie.freevision.sk/status.json').dig('status_at')),
      },

      {
        name: 'covid_web_testing_html_last_updated_cache_delta',
        value: delta_time(fetch_last_updated_from_html('https://covid.freevision.sk')),
      },
      {
        name: 'covid_web_testing_html_last_updated_origin_delta',
        value: delta_time(fetch_last_updated_from_html('https://covid-web.charlie.freevision.sk')),
      },
      {
        name: 'covid_web_testing_status_last_updated_origin_delta',
        value: delta_time(fetch_status('https://covid-web.charlie.freevision.sk/status.json').dig('testing', 'last_updated_at')),
      },

      {
        name: 'covid_web_vaccination_html_last_updated_cache_delta',
        value: delta_time(fetch_last_updated_from_html('https://covid.freevision.sk/vaccination')),
      },
      {
        name: 'covid_web_vaccination_html_last_updated_origin_delta',
        value: delta_time(fetch_last_updated_from_html('https://covid-web.charlie.freevision.sk/vaccination')),
      },
      {
        name: 'covid_web_vaccination_status_last_updated_origin_delta',
        value: delta_time(fetch_status('https://covid-web.charlie.freevision.sk/status.json').dig('vaccination', 'last_updated_at')),
      },
    ].reduce(StringIO.new) do |acc, metric|
      acc.puts "#{metric[:name]} #{metric[:value]}"
      acc
    end.tap do |io|
      halt 200, {}, io.string
    end
  end
end
