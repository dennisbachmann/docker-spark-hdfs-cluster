class Worker < Container
  def initialize(id)
    @id = id
  end

  def command
    @command ||= [super, 'worker']
  end

  def hostname
    @hostname ||= "worker-#{@id}"
  end

  def container_name
    @container_name ||= "spark-hdfs-cluster-worker-#{@id}"
  end

  def environment
    @environment ||= super.merge({
      spark_worker_cores: 2,
      spark_worker_memory: '8g',
      spark_worker_port: 8881,
      spark_worker_webui_port: spark_worker_webui_port
    })
  end

  def expose
    @expose ||= (super + [
      7012,
      7013,
      7014,
      7015,
      7016,
      8881,
      50010,
      50020,
      50075,
      22
      ]).uniq
  end

  def ports
    @ports ||= (super + [
      spark_worker_webui_port
      ])
  end

  def volumes
    @volumes ||= (super + [
      {from: './conf/worker', to: '/conf'}
      ])
  end

  private

  def spark_worker_webui_port
    8080 + @id
  end
end
