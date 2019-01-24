# frozen_string_literal: true

FilterProjectsWithName = ->(result) { result.reject { |r| r.name.nil? } }
ExtractProjectId       = lambda do |projects|
  projects.map { |r| SimpleStruct.new(name: r.name, id: r.id) }
end

FetchProjects = lambda do |token|
  url = URI("https://api.rollbar.com/api/1/projects/?access_token=#{token}")
  (MakeRequest >> FilterProjectsWithName >> ExtractProjectId).call(url)
end
