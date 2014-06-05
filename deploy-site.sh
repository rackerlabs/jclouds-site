#!/bin/bash

set -o errexit

jekyll build --safe

if [ ! -d "site-content" ]; then
  svn co https://svn.apache.org/repos/asf/jclouds/site-content
else
  svn up site-content
fi

cp -r _site/* site-content/
#jekyll copy site-content to _site so remove it
rm -rf site-content/site-content
rm site-content/deploy-site.sh

#add new files
cd site-content
svn status | awk '/^\?/{print $2}' | \
    while read filename; do svn --no-auto-props add $filename; done

if [ -z "$(svn status)" ]; then
    echo "No modified files in svn"
else
    echo "Modified files in svn:"

    svn status

    read -p "Are you sure you want to deploy the above changes? (y|n) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[y]$ ]]; then
        USERNAME_ARG=""
        if [ -n "$1" ]; then
            USERNAME_ARG="--username $1"
        fi

        PASSWORD_ARG=""
        if [ -n "$2" ]; then
            PASSWORD_ARG="--password $2"
        fi

        svn commit --no-auth-cache $USERNAME_ARG $PASSWORD_ARG --message 'deploy jclouds site content'
    fi
fi