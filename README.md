# Docker Cluster for Spark and Hadoop DFS
A Spark + HadoopDFS docker cluster using docker-compose.

## Creating Docker-Compose file
This project contains a helper script writen in ruby to facilitate the creation of docker-compose clusters.

### Executing the script
The helper script is written in Ruby and makes use of Bundler to manage dependencies.

    bundle install
    ruby build_cluster.rb

These commands will ensure that the environment is properly setup and list all the options available.

### Examples
Below are some examples of how the *build_cluster.rb* script can be used.

**Generating a docker-compose.yml file with 4 workers.**

    ruby build_cluster.rb -w 4

**Generating a docker-compose.yml file with 4 workers and a helper container.**

    ruby build_cluster.rb -w 4 -h

**Generating a docker-compose.yml file with 4 workers with 4g of memory each.**

    ruby build_cluster.rb -w 4 -m 4g
