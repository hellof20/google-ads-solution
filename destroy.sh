#!/bin/bash

echo "--------------------------------------------------"
if [[ $deploy_type == "Terraform" ]]
then
    echo $parameters | jq -r 'to_entries[] | .key + "=\"" + .value +"\""' > ./pangu.tfvars
    mysql --host=$host --user=$user --password=$password --database="ads" -N --execute="select CONCAT(id,'=\"',default_value,'\"') from parameters where solution_id='$solution_id' and show_on_ui=0 ;" >> ./pangu.tfvars
    cat pangu.tfvars
    echo "--------------------------------------------------"
    terraform apply -destroy -auto-approve -var-file="pangu.tfvars" -var="access_token=$access_token" -no-color -state=$data_dir/$DEPLOY_ID/terraform.tfstate
    if [ $? -eq 0 ]; then
        mysql --host=$host --user=$user --password=$password --database="ads" --execute="update deploy set status='destroy_success' where id='$DEPLOY_ID';"
    else
        mysql --host=$host --user=$user --password=$password --database="ads" --execute="update deploy set status='destroy_failed' where id='$DEPLOY_ID';"
    fi
else
    echo $parameters | jq -r 'to_entries[] | "export " + .key + "=\"" + .value +"\""' > ./pangu.env
    mysql --host=$host --user=$user --password=$password --database="ads" -N --execute="select CONCAT('export ',id,'=\"',default_value,'\"') from parameters where solution_id='$solution_id' and show_on_ui=0 ;" >> ./pangu.env
    source ./pangu.env
    cat pangu.env
    echo "--------------------------------------------------"
    CLOUDSDK_AUTH_ACCESS_TOKEN=$access_token bash destroy.sh
    if [ $? -eq 0 ]; then
        mysql --host=$host --user=$user --password=$password --database="ads" --execute="update deploy set status='destroy_success' where id='$DEPLOY_ID';"
    else
        mysql --host=$host --user=$user --password=$password --database="ads" --execute="update deploy set status='destroy_failed' where id='$DEPLOY_ID';"
    fi    
fi