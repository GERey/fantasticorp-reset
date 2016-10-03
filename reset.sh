#!/bin/bash

set -e

# Requires $TRELLO_KEY $TRELLO_TOKEN $GH_TOKEN

reset_trello() {
    echo "Resetting trello card..."
    card="SH4Nw0Xt"
    pr_list="5723d65380d5960bb11f079f"
    curl -sS -X PUT "https://api.trello.com/1/cards/$card/idList?key=$TRELLO_KEY&token=$TRELLO_TOKEN&value=$pr_list" > /dev/null
}

recreate_local_repo() {
    echo "Recreating local repo..."
    git init
    git add -A
    git remote add origin git@github.com:bellkev/fantasticorp-home.git
    git commit -am "Initial commit"
}

recreate_local_project() {
    echo "Recreating local project..."
    rm -rf fantasticorp-home-temp
    cp -r fantasticorp-home-original fantasticorp-home-temp
}

reset_github() {
    echo "Deleting gh repo..."
    curl -sS -u "bellkev:$GH_TOKEN" -X DELETE "https://api.github.com/repos/bellkev/fantasticorp-home" > /dev/null
    echo "Recreating gh repo..."
    curl -sS -u "bellkev:$GH_TOKEN" -X POST -d @- "https://api.github.com/user/repos" > /dev/null <<EOF
{
  "name": "fantasticorp-home",
  "private": true
}
EOF
    git push -u origin master
}

reset_circle_project() {
    echo "Resetting circle project..."
    ssh ubuntu@circle.fantasticorp.com "ENV_VAR_MAP='$ENV_VAR_MAP' bash" < remote-reset.sh
}

recreate_pr() {
    echo "Recreating feature branch and PR..."
    git checkout -b update-button
    sed -i '' 's_<a class="cta cta-red" href="#">Try it now</a>_<a class="cta cta-green" href="#">Sign up now</a>_' uwsgi/fantasticorp/templates/index.html
    git commit -am "Update button"
    git push origin update-button
    curl -sS -u "bellkev:$GH_TOKEN" -X POST -d @- "https://api.github.com/repos/bellkev/fantasticorp-home/pulls" > /dev/null <<EOF
{
  "title": "Update signup button",
  "body": "This is gonna triple our signups!",
  "head": "update-button",
  "base": "master"
}
EOF

}

source secrets

reset_trello
recreate_local_project
(cd fantasticorp-home-temp && recreate_local_repo)
(cd fantasticorp-home-temp && reset_github)
reset_circle_project
(cd fantasticorp-home-temp && recreate_pr)
