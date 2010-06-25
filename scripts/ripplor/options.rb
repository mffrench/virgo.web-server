require "rubygems"
require "choice"
require "etc"

Choice.options do

  header('')
  header('Required arguments:')

  option :start_repo, :required => true do
    short('-r')
    long('--repo=REPO')
    desc('The name of the starting repo')
  end

  separator('')
  separator('Optional arguments:')

  option :build_version, :required => false do
    short('-b')
    long('--virgo-build-version=VIRGO-BUILD-VERSION')
    validate(/\d(.\d(.\d(.([\w_-])+)?)?)?/)
    desc('The version to update Virgo Build to')
  end

  option :version, :required => false do
    short('-v')
    long('--version=VARIABLE:VERSION[,...]')
    validate(/.*:.*(,.*:.*)*/)
    desc('Versions to substitute during the ripple')
  end

  option :repository_map, :required => false do
    short('-m')
    long('--map=REPO-MAP')
    default('~/repository.map')
    desc('The property file containing a mapping from a repository name to a location')
    desc('(defaults to ~/repository.map)')
  end

  option :eclipse_build_keys, :required => false do
    short('-e')
    long('--eclipse-build-keys=ECLIPSE_BUILD_KEYS')
    default('~/eclipse.build.key')
    desc('The property file containing the keys used for publishing to eclipse build')
    desc('(defaults to ~/eclipse.build.key)')
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
  end
   
  option :dryrun?, :required => false do
   long('--dry-run')
   desc('Show what would happen but do not actually do anything')
  end
   
end
