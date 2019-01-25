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
project  = UpdateProjectAccessToken.call(projects[0], ENV['ROLLBAR_ACCESS_TOKEN'])
project  = ExtractProjectDeploys.call(project)
