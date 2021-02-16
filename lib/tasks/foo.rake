# frozen_string_literal: true

namespace :foo do
  desc 'Some description'
  task bar: :environment do
    Version.create!(version: Time.current)
  end
end
