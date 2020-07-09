for d in drupal7-for-astrooda/sites/all/modules/astrooda drupal7-for-astrooda drupal7-for-astrooda/sites/all/themes/bootstrap_astrooda .; do (
    cd $d
    dn=$(basename $d)
    git branch | awk 'NF>1 {printf "'$dn':\n branch: "$2"\n commit: "}'
    git describe --abbrev=8 --always --tags
) done  > version.yaml

cat version.yaml | md5sum | cut -c 1-8
