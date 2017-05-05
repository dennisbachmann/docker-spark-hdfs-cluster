#!/usr/local/bin/ruby -w
require 'rubygems'
require 'bundler/setup'
require 'mixlib/cli'
require 'psych'

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

  option :help,
    :short => "-?",
    :long => "--help",
    :description => "Show this message",
    :on => :tail,
    :boolean => true,
    :show_options => true,
    :exit => 0
end

cli = Builder.new
cli.parse_options

puts 'This will create a docker-compose file with the following options:'
puts "Version of docker-compose file: #{cli.config[:version]}"
puts "Number of workers: #{cli.config[:number_of_workers]}"
puts "Include helper? #{cli.config[:include_helper] ? 'Yes' : 'No'}"

nodes = [Master.new]
cli.config[:number_of_workers].to_i.times do |i|
  nodes << Worker.new(i+1)
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

File.open('docker-compose.yml', 'w') { |file| file.write(docker_compose.to_yaml) }
