# frozen_string_literal: true

ReadScopeFilter = ->(resource) { resource.scopes.include?('read') }

UpdateProjectAccessToken = lambda do |project, access_token|
  url = URI("https://api.rollbar.com/api/1/project/#{project.id}/access_tokens?access_token=#{access_token}")
  token = MakeRequest.call(url)
                     .select(&ReadScopeFilter)
                     .first
                     .access_token
                     .then { |t| project.set(:token, t) }
end
