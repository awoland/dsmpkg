#!/bin/bash

dsm_version=6.2
dsm_platform="$1"
rootdir="$( cd "$(dirname "$0")" ; pwd -P )"
package_source=`readlink -f $2`
container="dsmpkg-$dsm_version-$dsm_platform"
dockercmd="docker exec -it $container"
buildtmp=`mktemp -d -t dsmpkg-build.XXXXXXXX`
pkgtmp=`mktemp -d -t dsmpkg-pkg.XXXXXXXX`

cd "$package_source"
docker run -d --rm -v "$package_source:/source:ro" -v "$buildtmp:/target" --name "$container" "matthiaslohr/dsmpkg-env:$dsm_version-$dsm_platform" /bin/bash -c "trap : TERM INT; sleep infinity & wait"
make bootstrap
$dockercmd /bin/bash -c "cp -r /source /source_int; cd /source_int; make build"

cp -r "$package_source/pkgfiles/"* $pkgtmp

cd "$buildtmp"
tar cfz $pkgtmp/package.tgz *
$dockercmd /bin/bash -c "rm -rf /target/*"
docker stop $container
rm -rf $buildtmp

cd "$pkgtmp"
source INFO
tar cfz "$rootdir/$package-$dsm_version-$dsm_platform.unsigned.spk" *
rm -rf "$pkgtmp"

