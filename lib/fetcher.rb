# frozen_string_literal: true

require 'awesome_print'
require 'pry'

$LOAD_PATH.unshift('lib')

require 'make_request'
require 'fetch_projects'
require 'update_project_access_token'
require 'production_env_filter'
require 'update_projects_deploys'
require 'update_project_items'

projects = FetchProjects.call(ENV['ROLLBAR_ACCESS_TOKEN'])

projects.each do |project|
  puts "fetching: #{project.name}"

  project = UpdateProjectAccessToken.call(project, ENV['ROLLBAR_ACCESS_TOKEN'])
  next if project.token.nil?

  project = ExtractProjectDeploys.call(project)
  project = ExtractProjectItems.call(project)
  sleep(0.5)
end
#
binding.pry
