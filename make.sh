#!/bin/bash

function clone_latest_component() {
        component=${1:?}
        location=${2:?}

        echo -e "\033[32mclone_latest_component\033[0m \033[33m$component => $location\033[0m"

        git clone https://github.com/oda-hub/frontend-$component $location || {
            echo "can not clone, exists?"
        }

	(
            cd $location
            git checkout master
            git pull origin master
            git status
            if [ -z "$(git status --porcelain)" ]; then
                echo -e "\033[32mdirectory clean!\033[0m"
            else
                echo -e "\033[31mdirectory not clean!\033[0m"
                exit 1
            fi
        ) || exit 1
}


function clone_all_latest() {
        #  this is better than a loop!
        clone_latest_component drupal7-for-astrooda drupal7-for-astrooda
        clone_latest_component bootstrap_astrooda drupal7-for-astrooda/sites/all/themes/bootstrap_astrooda
        clone_latest_component astrooda drupal7-for-astrooda/sites/all/modules/astrooda
        clone_latest_component drupal7-db-for-astrooda drupal7-db-for-astrooda # i really hope none of the data there is private


        mkdir -pv  drupal7-for-astrooda/sites/all/modules/jwt_link/JWT/Authentication 

        curl -L https://github.com/firebase/php-jwt/archive/refs/tags/v5.2.1.tar.gz | \
          tar xvzf - php-jwt-5.2.1/src/JWT.php -O >  \
          drupal7-for-astrooda/sites/all/modules/jwt_link/JWT/Authentication/JWT.php 
}


function compute-version() {
    for d in drupal7-for-astrooda/sites/all/modules/astrooda drupal7-for-astrooda drupal7-for-astrooda/sites/all/themes/bootstrap_astrooda .; do (
        dn=$(basename $(realpath $d))
        cd $d
        git branch | awk 'NF>1 {printf "'$dn':\n branch: "$2"\n commit: "}'
        git describe --abbrev=8 --always --tags
    ) done > version.yaml

    cat version.yaml | md5sum | cut -c 1-8
}

$@
