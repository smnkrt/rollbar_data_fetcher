# frozen_string_literal: true

ProductionEnvFilter = ->(resource) { resource.environment == 'production' }
