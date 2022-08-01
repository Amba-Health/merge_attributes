require "rails/railtie"
module MergeAttributes
  class Railtie < ::Rails::Railtie
    initializer "merge_attributes.action_view" do |app|
      ActiveSupport.on_load :action_view do
        require "merge_attributes/helper"
        include MergeAttributes::Helper
      end
    end
  end
end
