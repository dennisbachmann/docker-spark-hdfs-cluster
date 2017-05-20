#!/usr/local/bin/ruby -w
require 'rubygems'
require 'bundler/setup'
require 'mixlib/cli'
require 'psych'
require 'highline'
require 'fileutils'

require_relative 'src/container.rb'
require_relative 'src/master.rb'
require_relative 'src/worker.rb'
require_relative 'src/helper.rb'

class Builder
  include Mixlib::CLI

  option :version,
    short: '-v VERSION',
    long: '--version VERSION',
    default: '3',
    description: 'Version of docker-compose file to use'

  option :number_of_workers,
    short: '-w NUM_WORKERS',
    long: '--workers NUM_WORKERS',
    required: true,
    description: 'Number of workers in the cluster'

  option :include_helper,
    short: '-h',
    long: '--helper',
    description: 'Include helper container within the cluster',
    boolean: true

  option :worker_memory,
    short: '-m MEM_SIZE',
    long: '--memory MEM_SIZE',
    description: 'Define the amount of memory allocated to each worker',
    default: '8g'

  option :help,
    :short => "-?",
    :long => "--help",
    :description => "Show this message",
    :on => :tail,
    :boolean => true,
    :show_options => true,
    :exit => 0
end

file_name = 'docker-compose.yml'
backup_file = 'docker-compose.yml.old'

cli = Builder.new
cli.parse_options

prompt = HighLine.new

prompt.say "This will create a #{file_name} file with the following options:"
prompt.say "Version of docker-compose file: #{cli.config[:version]}"
prompt.say "Number of workers: #{cli.config[:number_of_workers]}"
prompt.say "Memory size for workers: #{cli.config[:worker_memory]}"
prompt.say "Include helper? #{cli.config[:include_helper] ? 'Yes' : 'No'}"
prompt.say "\n"

prompt.choose do |menu|
  menu.prompt = "Do you want to proceed? "
  menu.choice(:yes) { prompt.say("Proceeding!") }
  menu.choices(:no) do 
    prompt.say("Exiting...")
    exit!
  end
end

if File.exist? file_name
  prompt.say "File #{file_name} already exists."
  prompt.choose do |menu|
    menu.prompt = 'Do you want to create a backup copy? '
    menu.choice(:yes) do
      FileUtils.cp file_name, backup_file
      prompt.say "Backup created as #{backup_file}!"
    end
    menu.choice(:no) { prompt.say('Skiping backup...') }
  end
end

nodes = [Master.new]
cli.config[:number_of_workers].to_i.times do |i|
  nodes << Worker.new(i+1, cli.config[:worker_memory])
end
if cli.config[:include_helper]
  nodes << Helper.new
end

docker_compose = {
  'version' => '3',
  'services' => {},
  'networks' => {}
}

networks = []
for node in nodes do
  networks << node.networks
  docker_compose['services'].merge!({node.hostname => node.to_hash})
end

networks.flatten!.uniq!
for network in networks do
  docker_compose['networks'].merge!({network.to_s => nil})
end

File.open(file_name, 'w') { |file| file.write(docker_compose.to_yaml) }
