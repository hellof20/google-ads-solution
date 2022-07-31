#!/bin/bash

cd /tmp/$DEPLOY_ID/tf-tutorial
terraform apply -destroy -auto-approve -var="project=$PROJECT_ID" -var="access_token=$access_token" -no-color > tf.log 2>&1
if [ $? -eq 0 ]; then
    mysql --host=$host --user=$user --password=$password --database="ads" --execute="update deploy set status='empty' where id='$DEPLOY_ID';"
else
    mysql --host=$host --user=$user --password=$password --database="ads" --execute="update deploy set status='failed' where id='$DEPLOY_ID';"
fi