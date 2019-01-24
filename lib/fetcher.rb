# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'
require 'awesome_print'
require 'pry'

require_relative 'simple_struct'

MakeRequest = lambda do |url|
  request  = Net::HTTP::Get.new(url)
  response = Net::HTTP.new(url.host, url.port)
                      .tap { |h| h.use_ssl = true }
                      .request(request)
  JSON.parse(response.read_body, object_class: SimpleStruct).result
end

FilterProjectsWithName = ->(result)   { result.reject { |r| r.name.nil? } }
ExtractProjectId       = ->(projects) { projects.map { |r| SimpleStruct.new(name: r.name, id: r.id) } }

FetchProjectsWithName  = lambda do |token|
  url = URI("https://api.rollbar.com/api/1/projects/?access_token=#{token}")
  (MakeRequest >> FilterProjectsWithName >> ExtractProjectId).call(url)
end

ReadScopeFilter = ->(resource) { resource.scopes.include?('read') }

ExtractProjectAccessToken = lambda do |project, access_token|
  url = URI("https://api.rollbar.com/api/1/project/#{project.id}/access_tokens?access_token=#{access_token}")
  token = MakeRequest.call(url).select { |e| e.scopes.include?('read') }.first.access_token
  project[:token] = token
  project
end

ProductionEnvFilter = ->(resource) { resource.environment == 'production' }

ExtractProjectDeploys = lambda do |project|
  url = URI("https://api.rollbar.com/api/1/deploys/?access_token=#{project.token}")
  deploys = MakeRequest.call(url).deploys.select(&ProductionEnvFilter)
  project[:deploys] = deploys
  project
end

ExtractProjectItems = lambda do |project|
  url = URI("https://api.rollbar.com/api/1/items/?access_token=#{project.token}")
  items = MakeRequest.call(url).items.select(&ProductionEnvFilter)
  project[:items] = items
  project
end

projects = FetchProjectsWithName.call(ENV['ROLLBAR_ACCESS_TOKEN'])

project  = ExtractProjectAccessToken.call(projects[0], ENV['ROLLBAR_ACCESS_TOKEN'])
project  = ExtractProjectDeploys.call(project)