# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

require_relative 'simple_struct'

MakeRequest = lambda do |url|
  request  = Net::HTTP::Get.new(url)
  response = Net::HTTP.new(url.host, url.port)
                      .tap { |h| h.use_ssl = true }
                      .request(request)
  JSON.parse(response.read_body, object_class: SimpleStruct).result
end
