#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

provider_class = Puppet::Type.type(:service).provider(:monit)

describe provider_class do
  before(:each) do
    processes = [
      "The Monit daemon 5.1.1 uptime: 22h 9m ",
      "",
      "Process 'sshd'                      running",
      "Process 'gdm'                       not monitored",
      "Process 'ftpd'                      initializing",
      "System 'hostname'                   running" ]
    
    provider_class.stubs(:execpipe).yields(processes)
  end

  describe "#instances" do
    it "should be able to find all instances" do
      instances = provider_class.instances
      instances.map {|provider| provider.name}.should =~ [ "gdm", "sshd", "ftpd" ]
    end
  end

  describe "#status" do
    it "should detect running process" do
      resource = Puppet::Type.type(:service).new(:name => "sshd", :provider => :monit)
      provider = provider_class.new(resource)

      provider.status.should == :running
    end

    it "should detect initializing process as running" do
      resource = Puppet::Type.type(:service).new(:name => "ftpd", :provider => :monit)
      provider = provider_class.new(resource)

      provider.status.should == :running
    end

    it "should detect stopped process" do
      resource = Puppet::Type.type(:service).new(:name => "gdm", :provider => :monit)
      provider = provider_class.new(resource)

      provider.status.should == :stopped
    end

  end
end
