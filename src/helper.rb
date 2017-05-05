class Helper < Container
  def command
    @command ||= [super, 'helper']
  end

  def hostname
    @hostname ||= 'helper'
  end

  def container_name
    @container_name ||= 'spark-hdfs-cluster-helper'
  end
end
