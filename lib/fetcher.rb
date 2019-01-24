# frozen_string_literal: true

require 'awesome_print'
require 'pry'

require_relative '../lib/make_request'
require_relative '../lib/fetch_projects'
require_relative '../lib/update_project_access_token'
require_relative '../lib/production_env_filter'
require_relative '../lib/update_projects_deploys'
require_relative '../lib/update_project_items'

projects = FetchProjects.call(ENV['ROLLBAR_ACCESS_TOKEN'])
project  = UpdateProjectAccessToken.call(projects[0], ENV['ROLLBAR_ACCESS_TOKEN'])
project  = ExtractProjectDeploys.call(project)
