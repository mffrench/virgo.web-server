#!/usr/bin/env ruby -wKU
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'repository'
require 'options'

args = Choice.choices

DRY_RUN = args[:dryrun?].nil? ? false : true
puts "This is a dry run..." if DRY_RUN

if File.exist?(File.expand_path(args[:repository_map]))
  paths = Hash.new
  IO.foreach(File.expand_path(args[:repository_map])) do |line|
    paths[$1.strip] = $2.strip if line =~ /([^=]*)=(.*)/
  end
else
  paths = {
    'osgi-test-stubs' => 'osgi-test-stubs',
    'osgi-extensions' => 'osgi-extensions',
    'util' => 'util',
    'test' => 'test',
    'medic' => 'medic',
    'artifact-repository' => 'artifact-repository',
    'kernel' => 'kernel',
    'kernel-tools' => 'kernel-tools',
    'web' => 'web',
    'apps' => 'apps',
    'documentation' => 'documentation',
    'web-server' => 'web-server',
    'jetty-server' => 'jetty-server'
  }
end

local_repo_root = 'git@git.springsource.org:virgo/'
eclipse_repo_root = 'ssh://' + args[:remote_user] + '@git.eclipse.org/gitroot/virgo/org.eclipse.virgo.'
ripple_branch = args[:branch_name]

ALL_REPOS = [
  Repository.new(eclipse_repo_root, 'osgi-test-stubs',     paths['osgi-test-stubs'],     'org.eclipse.virgo.teststubs',     nil, ripple_branch),
  Repository.new(eclipse_repo_root, 'osgi-extensions',     paths['osgi-extensions'],     'org.eclipse.virgo.osgi',          nil, ripple_branch),
  Repository.new(eclipse_repo_root, 'util',                paths['util'],                'org.eclipse.virgo.util',          nil, ripple_branch),
  Repository.new(eclipse_repo_root, 'test',                paths['test'],                'org.eclipse.virgo.test',          nil, ripple_branch),
  Repository.new(eclipse_repo_root, 'medic',               paths['medic'],               'org.eclipse.virgo.medic',         nil, ripple_branch),
  Repository.new(eclipse_repo_root, 'artifact-repository', paths['artifact-repository'], 'org.eclipse.virgo.repository',    nil, ripple_branch),
  Repository.new(eclipse_repo_root, 'kernel',              paths['kernel'],              'org.eclipse.virgo.kernel',        nil, ripple_branch, 'test package smoke-test publish publish-package-build'),
  Repository.new(eclipse_repo_root, 'kernel-tools',        paths['kernel-tools'],        'org.eclipse.virgo.kernel-tools',  nil, ripple_branch),
  Repository.new(eclipse_repo_root, 'web',                 paths['web'],                 'org.eclipse.virgo.web',           nil, ripple_branch),
  Repository.new(eclipse_repo_root, 'apps',                paths['apps'],                'org.eclipse.virgo.apps',          nil, ripple_branch),
  Repository.new(eclipse_repo_root, 'documentation',       paths['documentation'],       'org.eclipse.virgo.documentation', nil, ripple_branch, 'clean clean-integration doc-html publish'),
  Repository.new(eclipse_repo_root, 'web-server',          paths['web-server'],          'org.eclipse.virgo.web-server',    nil, ripple_branch, 'clean clean-integration test package smoke-test publish publish-package-build'),
  Repository.new(eclipse_repo_root, 'jetty-server',        paths['jetty-server'],        'org.eclipse.virgo.jetty-server',  nil, ripple_branch, 'clean clean-integration jar package')
]

repos = Array.new
repo_found = false
ALL_REPOS.each do |repo|
  if repo_found || repo.name == args[:start_repo]
    repos << repo
    repo_found = true
  end
end

log_file=File.expand_path('./ripple.log')
start_time = Time.new

versions = Hash.new
if !args[:version].nil?
  args[:version].split(",").each do |v|
    versions[$1.strip] = $2.strip if v =~ /(.*):(.*)/
  end
end

repos.each do |repo|
  puts 'Rippling ' + repo.name
  puts '  checkout with "' + repo.clone_command + '"' if DRY_RUN
  repo.checkout if !DRY_RUN
  puts '  update_versions ...' if DRY_RUN
  repo.update_versions(versions) if !DRY_RUN
  if !args[:build_version].nil?
    repo.update_virgo_build(args[:build_version]) if !DRY_RUN
  end
  puts '  build with user: ' + args[:remote_user] + ' and TARGETS: ' + repo.targets if DRY_RUN
  repo.build(args[:remote_user], log_file) if !DRY_RUN
  versions.merge!(repo.versions) if !DRY_RUN
end
  
if !DRY_RUN
  puts 'Execution Time: ' + Time.at(Time.new - start_time).utc.strftime('%R:%S')

  print 'Do you want to push? (y/n) '
  commit_ok = STDIN.gets.chomp
  if commit_ok =~ /y.*/
    repos.each do |repo|
      repo.push
    end
  end
end
