require 'time'

module Capistrano

  class MetricMessage

    VERSION = 1
    SERIALIZE_ATTRIBUTES = [
      :version,
      :datetime,
      :ruby_version,
      :ruby_platform,
      :capistrano_version,
      :payload
    ]

    def initialize(attributes = {})
      @attributes = attributes.merge({
          :version            => VERSION,
          :datetime           => Time.now.iso8601,
          :capistrano_version => capistrano_version,
      })
    end

    def to_s
      @attributes.values_at(*SERIALIZE_ATTRIBUTES).join("|")
    end

    def anonymize!
      @attributes.each do |attr, value|
        @attributes[attr] = 'anonymous' unless attr == :version
      end
    end

    private

    def capistrano_version
      if Capistrano.const_defined?('VERSION')
        Capistrano::VERSION
      elsif Capistrano.const_defined?('Version')
        Capistrano::Version
      else
        "unknown"
      end
    end

  end

end
