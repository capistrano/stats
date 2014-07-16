namespace :metrics do
  task :collect do
    Capistrano::MetricCollector.new(Dir.pwd).collect
  end
end

task 'deploy:starting' => 'metrics:collect'
