# frozen_string_literal: true

ExtractProjectDeploys = lambda do |project|
  url = URI("https://api.rollbar.com/api/1/deploys/?access_token=#{project.token}")
  deploys = MakeRequest.call(url).deploys.select(&ProductionEnvFilter)
  project.set(:deploys, deploys)
end
