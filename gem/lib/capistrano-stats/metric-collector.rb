require 'socket'
require 'digest'
require 'pathname'

module Capistrano

  class MetricCollector

    attr_reader :pwd

    def initialize(pwd)
      @pwd = Pathname.new(pwd)
    end

    def enabled?
      ask_to_enable unless File.exists?(sentry_file)
      File.read(sentry_file).chomp == "true"
    end

    def collect
      socket = UDPSocket.new
      message.anonymize! unless enabled?
      socket.send(message.to_s, 0, *destination)
    end

    private

    def destination
      target = ENV.fetch('CAPISTRANO_METRICS', 'metrics.capistranorb.com:1200')
      host, port = target.split(':')

      if port == ""
        raise StandardError.new("Invalid port: \"%s\"" % port)
      else
        port = port.to_i
      end

      [host, port]
    end

    def anon_project_hash
      git_remote = `git config --get-regex 'remote\..*\.url'`.chomp.split(' ').last
      @anon_project_hash = "not-git"
      unless git_remote.to_s == ""
        @anon_project_hash = Digest::MD5.hexdigest(git_remote)[0..7]
      end
      @anon_project_hash
    end

    def ask_to_enable
      return false unless $stdin.tty?
      show_prompt
      result = ask_to_confirm("Do you want to enable statistics? (y/N): ")
      show_thank_you_note(result)
      write_setting(result)
    end

    def show_prompt
      puts <<-EOF
        Would you like to enable statistics?  Here is an example message we would
        send:

        #{message}

      EOF
    end

    def show_thank_you_note(result)
      puts(result ? "Thank you, you may wish to add .capistrano/ to your source
           control database to avoid future prompts" : "Your preferences have
           been saved.")
    end

    def message
      @message ||= MetricMessage.new({
        :payload       => anon_project_hash,
        :ruby_version  => RUBY_VERSION,
        :ruby_platform => RUBY_PLATFORM,
      })
      @message
    end

    def sentry_file
      @pwd.join('.capistrano', 'metrics')
    end

    def ask_to_confirm(prompt)
      $stdout.write(prompt)
      $stdout.flush
      $stdin.gets.chomp.downcase[0] == ?y ? true : false
    end

    def write_setting(value)
      Dir.mkdir(sentry_file.dirname) rescue nil
      File.open(sentry_file, "wb") do |f|
        f.write(value)
      end
    end

  end

end
