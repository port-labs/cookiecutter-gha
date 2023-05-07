#!/bin/sh

set -e

port_client_id="$INPUT_PORTCLIENTID"
port_client_secret="$INPUT_PORTCLIENTSECRET"
port_run_id="$INPUT_PORTRUNID"
github_token="$INPUT_TOKEN"
blueprint_identifier="$INPUT_BLUEPRINTIDENTIFIER"
repository_name="$INPUT_REPOSITORYNAME"
org_name="$INPUT_ORGANIZATIONNAME"
cookie_cutter_template="$INPUT_COOKIECUTTERTEMPLATE"
port_user_inputs="$INPUT_PORTUSERINPUTS"
monorepo_url="$INPUT_MONOREPOURL"
scaffold_directory="$INPUT_SCAFFOLDDIRECTORY"
branch_name="port_$port_run_id"

get_access_token() {
  curl -s --location --request POST 'https://api.getport.io/v1/auth/access_token' --header 'Content-Type: application/json' --data-raw "{
    \"clientId\": \"$port_client_id\",
    \"clientSecret\": \"$port_client_secret\"
  }" | jq -r '.accessToken'
}

send_log() {
  message=$1
  curl --location "https://api.getport.io/v1/actions/runs/$port_run_id/logs" \
    --header "Authorization: Bearer $access_token" \
    --header "Content-Type: application/json" \
    --data "{
      \"message\": \"$message\"
    }"
}

create_repository() {
  curl -i -H "Authorization: token $github_token" \
       -d "{ \
          \"name\": \"$repository_name\", \"private\": true
        }" \
      https://api.github.com/orgs/$org_name/repos
}

clone_monorepo() {
  git clone $monorepo_url monorepo
  cd monorepo
  git checkout -b $branch_name
}

prepare_cookiecutter_extra_context() {
  echo "$port_user_inputs" | jq 'with_entries(select(.key | startswith("cookiecutter_")) | .key |= sub("cookiecutter_"; ""))'
}

cd_to_scaffold_directory() {
  if [ -n "$monorepo_url" ] && [ -n "$scaffold_directory" ]; then
    cd $scaffold_directory
  fi
}

apply_cookiecutter_template() {
  extra_context=$(prepare_cookiecutter_extra_context)

  echo "🍪 Applying cookiecutter template $cookie_cutter_template with extra context $extra_context"
  # Convert extra context from JSON to arguments
  args=$(echo "$extra_context" | jq -r 'to_entries[] | "\(.key)=\(.value)"')

  # Call cookiecutter with extra context arguments

  echo "cookiecutter --no-input $cookie_cutter_template $args"

  # Call cookiecutter with extra context arguments
  cookiecutter --no-input $cookie_cutter_template $args
}


push_to_repository() {
  if [ -n "$monorepo_url" ] && [ -n "$scaffold_directory" ]; then
    git config user.name "GitHub Actions Bot"
    git config user.email "github-actions[bot]@users.noreply.github.com"
    git add .
    git commit -m "Scaffolded project in $scaffold_directory"
    git push -u origin $branch_name

    send_log "Creating pull request to merge $branch_name into main 🚢"

    owner=$(echo "$monorepo_url" | awk -F'/' '{print $4}')
    repo=$(echo "$monorepo_url" | awk -F'/' '{print $5}')

    echo "Owner: $owner"
    echo "Repo: $repo"

    PR_PAYLOAD=$(jq -n --arg title "Scaffolded project in $repo" --arg head "$branch_name" --arg base "main" '{
      "title": $title,
      "head": $head,
      "base": $base
    }')

    echo "PR Payload: $PR_PAYLOAD"

    curl -X POST \
      -H "Authorization: token $github_token" \
      -H "Content-Type: application/json" \
      -d "$PR_PAYLOAD" \
      "https://api.github.com/repos/$owner/$repo/pulls"

    else
      cd "$(ls -td -- */ | head -n 1)"
      git init
      git config user.name "GitHub Actions Bot"
      git config user.email "github-actions[bot]@users.noreply.github.com"
      git add .
      git commit -m "Initial commit after scaffolding"
      git branch -M main
      git remote add origin https://oauth2:$github_token@github.com/$org_name/$repository_name.git
      git push -u origin main
  fi
}


report_to_port() {
  curl --location "https://api.getport.io/v1/blueprints/$blueprint_identifier/entities?run_id=$port_run_id" \
    --header "Authorization: Bearer $access_token" \
    --header "Content-Type: application/json" \
    --data "{
      \"identifier\": \"$repository_name\",
      \"title\": \"$repository_name\",
      \"properties\": {}
    }"
}

main() {
  access_token=$(get_access_token)

  if [ -z "$monorepo_url" ] || [ -z "$scaffold_directory" ]; then
    send_log "Creating a new repository: $repository_name 🏃"
    create_repository
    send_log "Created a new repository at https://github.com/$org_name/$repository_name 🚀"
  else
    send_log "Using monorepo: $monorepo_url 🏃"
    clone_monorepo
    cd_to_scaffold_directory
    send_log "Cloned monorepo and created branch $branch_name 🚀"
  fi

  send_log "Starting templating with cookiecutter 🍪"
  apply_cookiecutter_template
  send_log "Pushing the template into the repository ⬆️"
  push_to_repository

  send_log "Reporting to Port the new entity created https://github.com/$org_name/$repository_name 🚢"
  report_to_port

  send_log "Finished! Visit https://github.com/$org_name/$repository_name 🏁✅"
}

main