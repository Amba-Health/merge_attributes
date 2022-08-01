require "merge_attributes/version"
require "merge_attributes/helper"

# If running inside a rails app, inject the helper
# https://api.rubyonrails.org/classes/Rails/Railtie.html
require "merge_attributes/railtie" if defined?(Rails::Railtie)
