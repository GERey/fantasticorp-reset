#!/bin/bash

set -e

# Requires $TRELLO_KEY $TRELLO_TOKEN $GH_TOKEN

reset_trello() {
    echo "Resetting trello card..."
    curl -sS -X PUT "https://api.trello.com/1/cards/$TRELLO_CARD_ID/idList?key=$TRELLO_KEY&token=$TRELLO_TOKEN&value=$TRELLO_PR_LIST" > /dev/null
}

recreate_local_repo() {
    echo "Recreating local repo..."
    git init
    git add -A
    git remote add origin git@github.com:${GH_USER}/${GH_REPO}.git
    git commit -am "Initial commit"
}

recreate_local_project() {
    echo "Recreating local project..."
    rm -rf fantasticorp-home-temp
    cp -r fantasticorp-home-original fantasticorp-home-temp

    #change the title of the project, and the subtitle /headline
    sed -i '' "s_{{IMAGE}}_${IMAGE_URL}_" fantasticorp-home-temp/uwsgi/fantasticorp/templates/index.html
    sed -i '' "s/{{TITLE}}/$COMPANY_NAME/" fantasticorp-home-temp/uwsgi/fantasticorp/templates/index.html
    sed -i '' "s/{{SUBTITLE-QUESTION}}/$HEADLINE/" fantasticorp-home-temp/uwsgi/fantasticorp/templates/index.html
    sed -i '' "s/{{SUBTITLE}}/$ZINGER/" fantasticorp-home-temp/uwsgi/fantasticorp/templates/index.html

    #Change the config.yml
    sed -i '' "s/{GH-USER}/${GH_USER_LOWERCASE}/" fantasticorp-home-temp/.circleci/config.yml
    sed -i '' "s/{GH-USER}/${GH_USER_LOWERCASE}/" fantasticorp-home-temp/docker-compose.yml

    sed -i '' "s/{GH-REPO}/${GH_REPO}/" fantasticorp-home-temp/.circleci/config.yml
    sed -i '' "s/{GH-REPO}/${GH_REPO}/" fantasticorp-home-temp/docker-compose.yml

    sed -i '' "s/{GH-USER}/${GH_USER_LOWERCASE}/" fantasticorp-home-temp/script/deploy.sh
    sed -i '' "s/{GH-REPO}/${GH_REPO}/" fantasticorp-home-temp/script/deploy.sh
    if [[ -z $TRELLO_KEY ]]; then
        rm fantasticorp-home-temp/script/update-trello.sh
        sed -i '' '/update-trello/d' fantasticorp-home-temp/.circleci/config.yml
    fi
}

reset_github() {
    echo "Deleting gh repo..."
    curl -sS -u "$GH_USER:$GH_TOKEN" -X DELETE "https://api.github.com/repos/$1" > /dev/null
    echo "Recreating gh repo..."
    curl -sS -u "$GH_USER:$GH_TOKEN" -X POST -d @- "https://api.github.com/user/repos" > /dev/null <<EOF
{
  "name": "$GH_REPO",
  "private": false
}
EOF
    git push -u origin master
}

reset_circle_project() {
    echo "Resetting circle project..."
    ssh -i $SSH_KEY ubuntu@${CIRCLE_HOST} "ENV_VAR_MAP='$ENV_VAR_MAP' GH_USER=$GH_USER GH_REPO=$GH_REPO bash" < remote-reset.sh
}

recreate_pr() {
    echo "Recreating feature branch and PR..."
    git checkout -b update-button
    sed -i '' 's_<a class="cta cta-red" href="#">Try it now</a>_<a class="cta cta-green" href="#">Sign up now</a>_' uwsgi/fantasticorp/templates/index.html
    git commit -am "Update button"
    git push origin update-button
    curl -sS -u "$GH_USER:$GH_TOKEN" -X POST -d @- "https://api.github.com/repos/$GH_USER/$GH_REPO/pulls" > /dev/null <<EOF
{
  "title": "Update signup button",
  "body": "This is gonna triple our signups!",
  "head": "update-button",
  "base": "master"
}
EOF

}

source secrets

to_delete="$GH_USER/$GH_REPO"
echo "WARNING: $to_delete will be deleted/recreated. Are you sure you want to proceed? (y/n)"
read confirm
[[ $confirm = "y" ]] || exit 1
if [[ $TRELLO_KEY ]]; then reset_trello; fi
recreate_local_project
(cd fantasticorp-home-temp && recreate_local_repo)
(cd fantasticorp-home-temp && reset_github "$to_delete")
reset_circle_project
(cd fantasticorp-home-temp && recreate_pr)
