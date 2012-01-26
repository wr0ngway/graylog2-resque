require "spec_helper"

describe Graylog2::Resque::FailureHandler do
  include PerformJob

  context "configure" do

    it "should raise if nothing in config" do
      lambda {
        Graylog2::Resque::FailureHandler.configure do |config|
          config.gelf_server = nil
          config.gelf_port = nil
        end
      }.should raise_error("Graylog server and port needed for resque failure handler")
    end
    
    it "should raise if no gelf_port in config" do
      lambda {
        Graylog2::Resque::FailureHandler.configure do |config|
          config.gelf_server = 'localhost'
          config.gelf_port = nil
        end
      }.should raise_error("Graylog server and port needed for resque failure handler")
    end

    it "should raise if no gelf_server in config" do
      lambda {
        Graylog2::Resque::FailureHandler.configure do |config|
          config.gelf_server = nil
          config.gelf_port = 1234
        end
      }.should raise_error("Graylog server and port needed for resque failure handler")
    end
    
    it "should not raise if config valid" do
      lambda {
        Graylog2::Resque::FailureHandler.configure do |config|
          config.gelf_server = 'localhost'
          config.gelf_port = 1234
        end
      }.should_not raise_exception
    end
    
    it "should allow setting/getting global config" do
      Graylog2::Resque::FailureHandler.gelf_server = nil
      Graylog2::Resque::FailureHandler.gelf_port = nil
      Graylog2::Resque::FailureHandler.facility = nil
      Graylog2::Resque::FailureHandler.level = nil
      Graylog2::Resque::FailureHandler.host = nil
      Graylog2::Resque::FailureHandler.max_chunk_size = nil

      Graylog2::Resque::FailureHandler.configure do |config|
        config.gelf_server = 'localhost'
        config.gelf_port = 1234
        config.facility = 'somefacility'
        config.level = GELF::WARN
        config.host = 'somehost'
        config.max_chunk_size = 'LAN'
      end
      
      Graylog2::Resque::FailureHandler.gelf_server.should == 'localhost'
      Graylog2::Resque::FailureHandler.gelf_port.should == 1234
      Graylog2::Resque::FailureHandler.facility.should == 'somefacility'
      Graylog2::Resque::FailureHandler.level.should == GELF::WARN
      Graylog2::Resque::FailureHandler.host.should == 'somehost'
      Graylog2::Resque::FailureHandler.max_chunk_size.should == 'LAN'
    end
    
    it "should set failure handler" do
      ::Resque::Failure.backend = nil

      Graylog2::Resque::FailureHandler.configure do |config|
        config.gelf_server = 'localhost'
        config.gelf_port = 1234
      end
      
      ::Resque::Failure.backend.should == Graylog2::Resque::FailureHandler
    end

  end

  context "handling resque failures" do

    class SomeJob
      def self.perform(*args)
        raise "I failed"
      end
    end

    before(:each) do
      Graylog2::Resque::FailureHandler.configure do |config|
        config.gelf_server = 'localhost'
        config.gelf_port = 1234
        config.facility = 'somefacility'
        config.level = GELF::WARN
        config.host = 'somehost'
        config.max_chunk_size = 'WAN'
      end
    end
    
    it "triggers failure handler" do
      
      notifier = double("notifier")
      GELF::Notifier.should_receive(:new).with('localhost', 1234, 'WAN').and_return(notifier)
      notifier.should_receive(:notify!) do |data|
        data[:file].should == __FILE__
        data[:line].should =~ /\d+/
        data[:facility].should == 'somefacility'
        data[:level].should == GELF::WARN
        data[:host].should == 'somehost'
        data[:short_message].should == 'RuntimeError: I failed'
        data[:full_message].should =~ /Backtrace:.*/m
        data["_resque_worker"].should == ""
        data["_resque_queue"].should == "somequeue"
        data["_resque_class"].should == "SomeJob"
        data["_resque_args"].should == "[\"foo\"]"
      end
      
      run_resque_job(SomeJob, 'foo', :queue => :somequeue, :inline => true)
    end
    
  end
  
end
