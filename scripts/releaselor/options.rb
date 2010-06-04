require "rubygems"
require "choice"

Choice.options do

  header ''
  header 'Required arguments:'

  option :version, :required => true do
    short '-v'
    long '--version=VERSION'
    desc 'The version number for the release'
  end

  option :build_stamp, :required => true do
    short '-s'
    long '--build-stamp=BUILD-STAMP'
    desc 'The build stamp for the release'
  end

  option :release_type, :required => true do
    short '-t'
    long '--release-type=RELEASE-TYPE'
    desc 'The release type for the release'
  end

  option :new_version, :required => true do
    short '-n'
    long '--new-version=NEW-VERSION'
    desc 'The new version number for the release'
  end

  separator ''
  separator 'Optional arguments:'

  option :repository_map, :required => false do
    short('-m')
    long('--map=REPOSITORY-MAP')
    default('~/repository.map')
    desc('The property file containing a mapping from a repository name to a location')
    desc('(defaults to ~/repository.map)')
  end

  option :s3_keys, :required => false do
    short '-s'
    long '--s3-keys=S3-KEYS'
    default '~/s3.properties'
    desc 'The property file containing the S3 keys used for publishing'
    desc '(defaults to ~/s3.properties)'
  end

  option :publish_keys, :required => false do
    short '-p'
    long '--publish-keys=PUBLISH-KEYS'
    default '~/publish.properties'
    desc 'The property file containing the ssh information used for publishing'
    desc '(defaults to ~/publish.properties)'
  end

end
