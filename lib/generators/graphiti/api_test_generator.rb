require_relative "generator_mixin"

module Graphiti
  class ApiTestGenerator < ::Rails::Generators::Base
    include GeneratorMixin

    source_root File.expand_path("../templates", __FILE__)

    argument :resource, type: :string
    class_option :actions,
      type: :array,
      default: nil,
      aliases: ["--actions", "-a"],
      desc: 'Array of controller actions, e.g. "index show destroy"'

    class_option :'rawid',
      type: :boolean,
      default: false,
      aliases: ["--rawid", "-r"],
      desc: "Generate tests using rawid"

    desc "Generates rspec request specs at spec/api"
    def generate
      generate_api_specs
    end

    private

    def var
      resource_class.type.to_s.singularize.to_sym
    end

    def dir
      api_namespace.slice(1..-1)
    end

    def nested_dir
      @resource.gsub(/\w+::/, '').gsub("Resource", "").underscore.pluralize
    end

    def generate_api_specs
      if actions?("index")
        to = File.join("spec", dir, nested_dir, "index_spec.rb")
        template("index_request_spec.rb.erb", to)
      end

      if actions?("show")
        to = File.join("spec", dir, nested_dir, "show_spec.rb")
        template("show_request_spec.rb.erb", to)
      end

      if actions?("create")
        to = File.join("spec", dir, nested_dir, "create_spec.rb")
        template("create_request_spec.rb.erb", to)
      end

      if actions?("update")
        to = File.join("spec", dir, nested_dir, "update_spec.rb")
        template("update_request_spec.rb.erb", to)
      end

      if actions?("destroy")
        to = File.join("spec", dir, nested_dir, "destroy_spec.rb")
        template("destroy_request_spec.rb.erb", to)
      end
    end

    def resource_class
      @resource.constantize
    end

    def type
      resource_class.type
    end

    def model_class
      resource_class.model
    end
  end
end
