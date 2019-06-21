#!/bin/sh

git config --global user.email "cam40902.spam@gmail.com"
git config --global user.name "Bourne-ID"

git remote set-url origin https://Bourne-ID:${GH_TOKEN}@github.com/Bourne-ID/LinuxGSM.git

git checkout ${TRAVIS_BRANCH}
git add ./utilslgsm/data/default_parameters.csv
git commit --message "Travis build: $(date +%Y-%m-%d)"

git push --set-upstream origin ${TRAVIS_BRANCH}
