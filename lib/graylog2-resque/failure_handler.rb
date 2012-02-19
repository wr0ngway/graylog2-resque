require 'resque'
require 'gelf'

module Graylog2
  module Resque
    
    # A Failure backend that sends exceptions to Graylog
    #
    # Graylog2::Resque::FailureHandler.configure do |config|
    #   # required
    #   config.gelf_server = "server"
    #   config.gelf_port = "port"
    #
    #   # optional
    #   # config.host = "myhost"
    #   # config.facility = "rails_worker_exceptions"
    #   # config.level = GELF::FATAL
    #   # config.max_chunk_size = 'LAN'
    # end
    #
    class FailureHandler < ::Resque::Failure::Base

      class << self
        # required
        attr_accessor :gelf_server, :gelf_port
        # optional
        attr_accessor :facility, :level, :host, :max_chunk_size
      end

      def self.configure
        yield self
        raise "Graylog server and port needed for resque failure handler" unless gelf_server && gelf_port
        ::Resque::Failure.backend = self
      end

      def save
        begin
          data = {}

          trace = Array(exception.backtrace)
          if trace[0]
            data[:file] = trace[0].split(":")[0]
            data[:line] = trace[0].split(":")[1]
          end
          data[:facility] = self.class.facility if self.class.facility
          data[:level] = self.class.level || GELF::FATAL
          data[:host] = self.class.host if self.class.host

          data[:short_message] = "#{exception.class}: #{exception.message}"
          data[:full_message] = "Backtrace:\n" + trace.join("\n")
          data["_resque_worker"] = worker.to_s
          data["_resque_queue"] = queue.to_s
          data["_resque_class"] = payload['class'].to_s
          data["_resque_args"] = payload['args'].inspect.to_s
          
          notifier = GELF::Notifier.new(self.class.gelf_server, self.class.gelf_port, self.class.max_chunk_size || 'LAN')
          notifier.notify!(data)
        rescue Exception => e
          puts "Failed to send resque failure to graylog: #{e}"
        end
      end

      def self.count
        # We can't get the total # of errors from graylog so we fake it
        # by asking Resque how many errors it has seen.
        ::Resque::Stat[:failed]
      end

    end
    
  end
end
