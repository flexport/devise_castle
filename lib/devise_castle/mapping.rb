module DeviseCastle
  module Mapping
    def self.included(base)
      base.alias_method_chain :default_controllers, :castle
    end

    private
    def default_controllers_with_castle(options)
      options[:controllers] ||= {}
      options[:controllers][:sessions] ||= "devise_castle/sessions"
      default_controllers_without_castle(options)
    end
  end
end