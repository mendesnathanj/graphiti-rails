require 'rescue_registry'
require 'graphiti/errors'

module Graphiti
  if defined?(Graphiti::Rails)
    remove_const :Rails
  end

  # Rails integration for Graphiti. See {file:README.md} for more details.
  module Rails
    autoload :Context, "graphiti/rails/context"
    autoload :Debugging, "graphiti/rails/debugging"
    autoload :ExceptionHandler, "graphiti/rails/exception_handlers"
    autoload :FallbackHandler, "graphiti/rails/exception_handlers"
    autoload :InvalidRequestHandler, "graphiti/rails/exception_handlers"

    def self.included(_klass)
      ActiveSupport::Deprecation.warn("With graphiti-rails, including Graphiti::Rails is unnecessary")
    end

    # @!attribute self.handled_exception_formats
    # A list of formats as symbols which will be handled by a GraphitiErrors::ExceptionHandler. See {Railtie}.
    cattr_accessor :handled_exception_formats, default: []
  end
end

ActiveSupport.on_load(:action_controller) do
  include Graphiti::Rails::Context
  include Graphiti::Rails::Debugging

  # A global handler here is somewhat risky. However, we explicitly only handle JSON:API by default.
  register_exception Exception, status: :passthrough, handler: Graphiti::Rails::FallbackHandler

  register_exception Graphiti::Errors::InvalidRequest,   status: 400, handler: Graphiti::Rails::InvalidRequestHandler
  register_exception Graphiti::Errors::RecordNotFound,   status: 404, handler: Graphiti::Rails::ExceptionHandler
  register_exception Graphiti::Errors::RemoteWrite,      status: 400, handler: Graphiti::Rails::ExceptionHandler
  register_exception Graphiti::Errors::SingularSideload, status: 400, handler: Graphiti::Rails::ExceptionHandler
end

ActiveSupport.on_load(:active_record) do
  require "graphiti/adapters/active_record"
end

require "graphiti/rails/railtie"
