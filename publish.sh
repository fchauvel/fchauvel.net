#!/bin/bash -f
# Usage: publish.sh

set -e

#git submodule update --recursive --remote

CONTENT_HASH=$(git rev-parse --short HEAD)
CONTENT_DESCRIPTION=$(git log -1 --pretty=%B | head -n 1)
THEME_HASH=$(cd themes/hugo-icarus-theme && git rev-parse --short HEAD)
THEME_DESCRIPTION=$(cd themes/hugo-icarus-theme && git log -1 --pretty=%B | head -n 1)

LOG_FILE="hugo.log"


git submodule update --remote

if [[ -z "${GITHUB_TOKEN}" ]]
then
    printf "Error: The Github token is not available!\n"
    exit 1
fi

printf "Rebuilding the website \n"
printf "   CONTENT ${CONTENT_HASH} ${CONTENT_DESCRIPTION}\n"
printf "   THEME   ${THEME_HASH} ${THEME_DESCRIPTION}\n"

hugo > hugo.log
if [ $? -ne 0 ]
then
    printf "Please fix issues raised by hugo (see ${LOG_FILE})\n"
    exit 1
fi

cd public

git checkout master
git add .
git commit -m "${CONTENT_DESCRIPTION}" \
    -m " - Content: fchauvel/fchauvel.net#${CONTENT_HASH}" \
    -m " - Theme:  fchauvel/hugo-icarus-theme#${THEME_HASH}"
    
git remote rm origin
git remote add origin https://fchauvel:${GITHUB_TOKEN}@github.com/fchauvel/fchauvel.github.io
git push origin master

printf "\nCheck out 'https://fchauvel.github.io/'\n"
