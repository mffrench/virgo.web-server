require "rubygems"
require "choice"
require "etc"

Choice.options do

  header('')
  header('Required arguments:')

  option :version, :required => true do
    short('-v')
    long('--version=VERSION')
    desc('The version number for the release')
  end

  option :build_stamp, :required => true do
    short('-s')
    long('--build-stamp=BUILD-STAMP')
    desc('The build stamp for the release')
  end

  option :release_type, :required => true do
    short('-t')
    long('--release-type=RELEASE-TYPE')
    desc('The release type for the release')
  end

  option :new_version, :required => true do
    short('-n')
    long('--new-version=NEW-VERSION')
    desc('The new version number for the release')
  end

  separator('')
  separator('Optional arguments:')

  option :build_version, :required => false do
    short('-b')
    long('--virgo-build-version=VIRGO-BUILD-VERSION')
    validate(/\d(.\d(.\d(.([\w_-])+)?)?)?/)
    desc('The version to update Virgo Build to')
  end

  option :repository_map, :required => false do
    short('-m')
    long('--map=REPOSITORY-MAP')
    default('~/repository.map')
    desc('The property file containing a mapping from a repository name to a location')
    desc('(defaults to ~/repository.map)')
  end

  option :eclipse_build_keys, :required => false do
    short('-e')
    long('--eclipse-build-keys=ECLIPSE_BUILD_KEYS')
    default('~/eclipse.build.key')
    desc('The property file containing the keys used for publishing to eclipse build')
    desc('(defaults to ~/s3.properties)')
  end
  
  option :s3_keys, :required => false do
    short('-s')
    long('--s3-keys=S3-KEYS')
    default('~/s3.properties')
    desc('The property file containing the S3 keys used for publishing')
    desc('(defaults to ~/s3.properties)')
  end

  option :remote_user, :required => false do
   short('-u')
   long('--remote-user=REMOTE-USER')
   default(Etc.getlogin)
   desc('User id to use for remote repository access')
   desc('(defaults to local login id)')
  end
   
  option :dryrun?, :required => false do
   long('--dry-run')
   desc('Show what would happen but do not actually do anything')
  end

end
