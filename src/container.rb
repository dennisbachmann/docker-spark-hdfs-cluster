class Container

  @@spark_public_dns = 'localhost'

  def image
    @image ||= 'bachmann/spark-hdfs'
  end

  def command
    @command ||= '/usr/local/bin/boot'
  end

  def hostname
    @hostname ||= 'container'
  end

  def container_name
    @container_name ||= 'container_name'
  end

  def environment
    @spark_environment ||= {
       spark_conf_dir: '/conf/spark',
       spark_public_dns: @@spark_public_dns
     }
  end

  def networks
    @networks ||= [:hadoop]
  end

  def expose
    @expose ||= []
  end

  def ports
    @ports ||= []
  end

  def volumes
    @volumes ||= [
      {from: './data', to: '/tmp/data'},
      {from: './application', to: '/application'}
    ]
  end

  def to_hash
    hash = {
      'image' => image,
      'command' => command.join(' '),
      'hostname' => hostname,
      'container_name' => container_name
    }
    unless environment.empty?
      environments = {}
      environment.map do |key, value|
        environments.merge!({key.to_s.upcase => value})
      end
      hash.merge!({'environment' => environments})
    end
    unless networks.empty?
      list_of_networks = []
      networks.each do |network|
        list_of_networks << network.to_s
      end
      hash.merge!({'networks' => list_of_networks})
    end
    unless expose.empty?
      list_of_ports_to_expose = []
      expose.each do |port|
        list_of_ports_to_expose << port
      end
      hash.merge!({'expose' => list_of_ports_to_expose})
    end
    unless ports.empty?
      list_of_ports = []
      ports.each do |port|
        list_of_ports << "#{port}:#{port}"
      end
      hash.merge!({'ports' => list_of_ports})
    end
    unless volumes.empty?
      list_of_volumes = []
      volumes.each do |volume|
        list_of_volumes << "#{volume[:from]}:#{volume[:to]}"
      end
      hash.merge!({'volumes' => list_of_volumes})
    end
  end

  def to_yaml
    puts "image: #{image}"
    puts "command: #{command}"
    puts "hostname: #{hostname}"
    puts "container_name: #{container_name}"
    unless environment.empty?
      puts "environment:"
      environment.map do |key, value|
        puts "  #{key.to_s.upcase}: #{value}"
      end
    end
    unless networks.empty?
      puts "networks:"
      networks.each do |network|
        puts "  - #{network}"
      end
    end
    unless expose.empty?
      puts "expose:"
      expose.each do |port|
        puts "  - #{port}"
      end
    end
    unless ports.empty?
      puts "ports:"
      ports.each do |port|
        puts "  - #{port}:#{port}"
      end
    end
    unless volumes.empty?
      puts "volumes:"
      volumes.each do |volume|
        puts "  - #{volume[:from]}:#{volume[:to]}"
      end
    end
  end
end
