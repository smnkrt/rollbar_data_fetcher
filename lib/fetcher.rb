require 'uri'
require 'net/http'
require 'json'
require 'awesome_print'
require 'pry'


MakeRequest = ->(url) do
  http = Net::HTTP.new(url.host, url.port).tap { |h| h.use_ssl = true }
  request = Net::HTTP::Get.new(url)
  response = http.request(request)
  JSON.parse(response.read_body).fetch("result")
end

FilterProjectsWithName = ->(result)   { result.reject { |r| r["name"].nil? } }
ExtractProjectId       = ->(projects) { projects.map { |r| { name: r["name"], id: r["id"] } } }

FetchProjectsWithName  = ->(token) do
  url = URI("https://api.rollbar.com/api/1/projects/?access_token=#{token}")
  (MakeRequest >> FilterProjectsWithName >> ExtractProjectId).call(url)
end

ExtractProjectAccessToken = ->(project, access_token) do
  project_id = project.fetch(:id)
  url = URI("https://api.rollbar.com/api/1/project/#{project_id}/access_tokens?access_token=#{access_token}")
  token = MakeRequest.call(url).select { |e| e["scopes"].include?("read") }.first["access_token"]
  project.merge(token: token)
end

ExtractProjectDeploys = ->(project) do
  project_token = project.fetch(:token)
  url = URI("https://api.rollbar.com/api/1/deploys/?access_token=#{project_token}")
  MakeRequest.call(url).fetch("deploys").select { |d| d["environment"] == "production" }
end

projects = FetchProjectsWithName.call(ENV['ROLLBAR_ACCESS_TOKEN'])
project  = ExtractProjectAccessToken.call(projects[0], ENV['ROLLBAR_ACCESS_TOKEN'])

latest_deploys = ExtractProjectDeploys.call(project)
