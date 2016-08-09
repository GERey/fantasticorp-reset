#!/bin/bash

set -e

sudo docker exec -i $(sudo docker ps | grep circleci-frontend | awk '{print $1}') lein repl :connect 6005 <<EOF
(circle.http.api.admin-commands/force-unfollow "bellkev" "bellkev/fantasticorp-home")
(circle.http.api.admin-commands/delete-project "bellkev/fantasticorp-home")
(let [user (circle.model.user/find-one-by-login "bellkev")
      project (circle.model.api1/find-or-create-project "https://github.com/bellkev/fantasticorp-home" :user user)]
  (doseq [[k v] $ENV_VAR_MAP] (circle.model.project/create-env-var project k v))
  (circle.model.api1/project-follow user project))
EOF
