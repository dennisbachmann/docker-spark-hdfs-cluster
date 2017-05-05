class Master < Container
  def command
    @command ||= [super, 'master']
  end

  def hostname
    @hostname ||= 'master'
  end

  def container_name
    @container_name ||= 'spark-hdfs-cluster-master'
  end

  def environment
    @environment ||= super.merge({
      master: 'spark://master:7077'
    })
  end

  def expose
    @expose ||= (super + [
      7001,
      7002,
      7003,
      7004,
      7005,
      7006,
      7077,
      6066,
      50090,
      8020,
      9000,
      22
      ]).uniq
  end

  def ports
    @ports ||= (super + [
      8080,
      50070
      ])
  end

  def volumes
    @volumes ||= (super + [
      {from: './conf/master', to: '/conf'}
      ])
  end
end
