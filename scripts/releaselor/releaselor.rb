#!/usr/bin/env ruby -wKU
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require 'repository'
require 'options'

args = Choice.choices
bundle_version = args[:version] + '.' + args[:build_stamp]

if File.exist?(File.expand_path(args[:repository_map]))
  paths = Hash.new
  IO.foreach(File.expand_path(args[:repository_map])) do |line|
    paths[$1.strip] = $2.strip if line =~ /([^=]*)=(.*)/
  end
else
  paths = {
    'osgi-extensions' => 'osgi-extensions',
    'util' => 'util',
    'artifact-repository' => 'artifact-repository',
    'test' => 'test',
    'kernel' => 'kernel',
    'apps' => 'apps',
    'web' => 'web',
    'documentation' => 'documentation',
    'web-server' => 'web-server'
  }
end

ALL_REPOS = [
  Repository.new('osgi-extensions', paths['osgi-extensions'],'org.eclipse.virgo.osgi', bundle_version),
  Repository.new('util', paths['util'], 'org.eclipse.virgo.util', bundle_version),
  Repository.new('artifact-repository', paths['artifact-repository'], 'org.eclipse.virgo.repository', bundle_version),
  Repository.new('test', paths['test'], 'org.eclipse.virgo.osgi.test', bundle_version),
  Repository.new('kernel', paths['kernel'], 'org.eclipse.virgo.kernel', bundle_version, 'clean clean-integration test package publish'),
  Repository.new('web', paths['web'], 'org.eclipse.virgo.web', bundle_version),
  Repository.new('apps', paths['apps'], 'org.eclipse.virgo.apps', bundle_version),
  Repository.new('documentation', paths['documentation'], 'org.eclipse.virgo.documentation', bundle_version, 'doc publish publish-static'),
  Repository.new('web-server', paths['web-server'], nil, bundle_version, 'test package smoke-test publish')
]

log_file=File.expand_path('./release.log')
start_time = Time.new

versions = Hash.new
ALL_REPOS.each do |repo|
  puts 'Releasing ' + repo.name
  repo.checkout
  repo.create_release_branch(args[:version], args[:build_stamp], args[:release_type], versions)
  repo.build(args[:s3_keys], args[:publish_keys], log_file)
  repo.create_tag
  repo.update_master_branch(args[:new_version], versions)
  versions.merge!(repo.versions)
end

puts 'Execution Time: ' + Time.at(Time.new - start_time).utc.strftime('%R:%S')
puts ''

print 'Do you want to push? '
commit_ok = STDIN.gets.chomp
if commit_ok =~ /y.*/
  ALL_REPOS.each do |repo|
    repo.push(args[:new_version])
  end
end
