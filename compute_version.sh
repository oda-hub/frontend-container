for d in \
        $PWD/drupal7-for-astrooda/sites/all/modules/astrooda \
        $PWD/drupal7-for-astrooda \
        $PWD/drupal7-for-astrooda/sites/all/themes/bootstrap_astrooda \
        $PWD; do (
    cd $d
    dn=$(basename $(realpath $d))
    git branch | awk 'NF>1 {printf "'$dn':\n branch: "$2"\n commit: "}'
    git describe --abbrev=8 --always --tags
) done  > version.yaml

cat version.yaml | md5sum | cut -c 1-8
