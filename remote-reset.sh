#!/bin/bash

set -e



sudo docker exec -i $(sudo docker ps | grep circleci-frontend | awk '{print $1}') lein repl :connect 6005 <<EOF
(in-ns 'circle.model.build-storage.core)
(def count-by-mongo-opts (constantly 0))
(def delete-archived-build! identity)
(circle.http.api.admin-commands.user/force-unfollow "$GH_USER" "$GH_USER/$GH_REPO")
(circle.http.api.admin-commands/delete-project "$GH_USER/$GH_REPO")
(let [user (circle.model.user/find-one-by-login "$GH_USER") project (circle.model.api1/find-or-create-project "https://github.com/$GH_USER/$GH_REPO" :user user)] 
	(doseq [[k v] $ENV_VAR_MAP] (circle.model.project/create-env-var project k v))
	(circle.model.api1/project-follow user project))
EOF
