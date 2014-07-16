require File.expand_path('../capistrano-stats/metric-collector', __FILE__)
require File.expand_path('../capistrano-stats/metric-message', __FILE__)
require File.expand_path('../capistrano-stats/version', __FILE__)

require 'capistrano/version'

unless Capistrano.const_defined?('VERSION')
  Capistrano::VERSION = Capistrano::Version
end

case Capistrano::VERSION.to_s.to_i
when 2
  Capistrano::Configuration.instance.load do
    namespace :metrics do
      task :collect do
        Capistrano::MetricCollector.new(Dir.pwd).collect
      end
    end
    on :start, 'metrics:collect'
  end
when 3
  load File.expand_path('../../tasks/metrics.rake', __FILE__)
else
  warn "Unsupported Capistrano Version"
end
