class NxtSchema::Application::Errors::SchemaError < ::String
  def initialize(application:, message:)
    super(message)
    @application = application
  end

  attr_reader :application
end
