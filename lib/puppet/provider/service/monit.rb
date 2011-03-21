

# monit services

Puppet::Type.type(:service).provide :monit, :parent => :base do
  desc "Support for monit services."

  commands :monit => "monit"

  def self.summary
    processes = Hash.new
    execpipe("#{command(:monit)} summary") { |process|
      process.each { |line|
        next unless match = line.match(/^Process '([^']+)'\s*(\w.*\w)\s*$/)
        processes[match[1]] = match[2]
      }
    }
    processes
  end

  def self.instances
    summary.keys.map { |name| new(:name => name) }
  end
    
  def startcmd
    [command(:monit), 'start', @resource[:name]]
  end

  def stopcmd
    [command(:monit), 'stop', @resource[:name]]
  end

  def restartcmd
    [command(:monit), 'restart', @resource[:name]]
  end

  def status
    processes = self.class.summary
    if processes.key?(@resource[:name])
      if processes[@resource[:name]] =~ /^(running|initializing)$/
        return :running
      else
        return :stopped
      end
    else
      raise Puppet::Error.new("Service #{@resource[:name]} not found.")
    end
  end
end



