#!/usr/bin/env bash
dir=`dirname $0`
dir=`cd $dir;pwd`

for f in $(find . -iname "*.java" -or -iname "*.aj" -or -iname "*.xml" -or -iname ".project" -or -iname "*.MF" -or -iname "*.mf" -or -iname ".prefs"  -or -iname ".classpath" -or -iname "build.versions" -or -iname "*.properties" -or -iname "*.bat" -or -iname "*.sh" -or -iname "*.conf" -or -iname "*.profile" -or -iname "*.config" -or -iname "*.plan" -or -iname "runner.bundles")
do
	
sed -i -e 's/com\.springsource\.osgi\.teststubs/org.eclipse.virgo.teststubs.osgi/g' $f
sed -i -e 's/com\.springsource\.osgi\.stub/org.eclipse.virgo.teststubs.osgi/g' $f
sed -i -e 's/OSGI_TEST_STUBS_IVY_CACHE/TEST_STUBS_IVY_CACHE/g' $f

sed -i -e 's/com\.springsource\.osgi\.test\.stubs/org.eclipse.virgo.teststubs.osgi/g' $f
sed -i -e 's/com\.springsource\.osgi\.extensions/org.eclipse.virgo.osgi.extensions/g' $f
sed -i -e 's/com\.springsource\.osgi\.launcher/org.eclipse.virgo.osgi.launcher/g' $f

sed -i -e 's/com\.springsource\.util/org.eclipse.virgo.util/g' $f

sed -i -e 's/com\.springsource\.osgi\.test/org.eclipse.virgo.test/g' $f

sed -i -e 's/com\.springsource\.osgi\.medic/org.eclipse.virgo.medic/g' $f
sed -i -e 's/com\.springsource\.ch\.qos\.logback\.classic\.woven/org.eclipse.virgo.ch.qos.logback.classic.woven/g' $f

sed -i -e 's/com\.springsource\.repository/org.eclipse.virgo.repository/g' $f

sed -i -e 's/com\.springsource\.osgi/org.eclipse.virgo.osgi/g' $f

sed -i -e 's/com\.springsource\.kernel/org.eclipse.virgo.kernel/g' $f

sed -i -e 's/com\/springsource\/kernel/org\/eclipse\/virgo\/kernel/g' $f

sed -i -e 's/org\.eclipse\.virgo\.osgi\.test/org.eclipse.virgo.test/g' $f

sed -i -e 's/com\.springsource\.osgi\.webcontainer/org.eclipse.gemini.web/g' $f

sed -i -e 's/org\.eclipse\.virgo\.osgi\.webcontainer/org.eclipse.gemini.web/g' $f

rm $f-e
done

$dir/update-dependency.rb -v org.eclipse.virgo.teststubs -n 1.0.0.D-20100311162851
$dir/update-dependency.rb -v org.eclipse.virgo.osgi -n 2.1.0.D-20100311163103
$dir/update-dependency.rb -v org.eclipse.virgo.util -n 2.1.0.D-20100311163244
$dir/update-dependency.rb -v org.eclipse.virgo.test -n 2.1.0.D-20100311163545
$dir/update-dependency.rb -v org.eclipse.virgo.medic -n 1.0.1.D-20100311163649
$dir/update-dependency.rb -v org.eclipse.virgo.repository -n 2.1.0.D-20100311164021
$dir/update-dependency.rb -v org.eclipse.virgo.kernel -n 2.1.0.D-20100311164357
$dir/update-dependency.rb -v org.eclipse.gemini.web -n 1.0.0.BUILD-20100312113743



