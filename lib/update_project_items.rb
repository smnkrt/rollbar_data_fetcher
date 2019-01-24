# frozen_string_literal: true

ExtractProjectItems = lambda do |project|
  url = URI("https://api.rollbar.com/api/1/items/?access_token=#{project.token}")
  items = MakeRequest.call(url).items.select(&ProductionEnvFilter)
  project.set(:items, items)
end
