<img align="right" width="100" height="74" src="https://user-images.githubusercontent.com/8277210/183290025-d7b24277-dfb4-4ce1-bece-7fe0ecd5efd4.svg" />

# Scaffold Action

[![Slack](https://img.shields.io/badge/Slack-4A154B?style=for-the-badge&logo=slack&logoColor=white)](https://join.slack.com/t/devex-community/shared_invite/zt-1bmf5621e-GGfuJdMPK2D8UN58qL4E_g)

This GitHub action allows you to quickly scaffold repositories using any selected [Cookiecutter Template](https://www.cookiecutter.io/templates) via Port Actions.

In addition, as cookiecutter is an Open Source project you can make your own project, learn more about it [here](https://cookiecutter.readthedocs.io/en/2.0.2/tutorials.html#create-your-very-own-cookiecutter-project-template)

## Inputs

| Input                 | Description                                                                                                                   | Required | Default   |
|-----------------------|-------------------------------------------------------------------------------------------------------------------------------|----------|-----------|
| token                 | The GitHub Token to use to authenticate with the API with permissions to create repositories within the organization make sure to use [Fine-grained token](https://github.com/settings/tokens?type=beta) | Yes      |           |
| portClientId          | The Port Client ID to use to authenticate with the API                                                                        | Yes      |              |
| portClientSecret      | The Port Client Secret to use to authenticate with the API                                                                    | Yes      |              |
| blueprintIdentifier   | The blueprint identifier to use to populate the Port                                                                          | Yes      | Service      |
| repositoryName        | The name of the repository to create                                                                                          | Yes      |              |
| organizationName      | The name of the organization to create the repository in                                                                      | Yes      |              |
| cookiecutterTemplate  | The cookiecutter template to use to populate the repository                                                                   | Yes      |              |
| portUserInputs        | Port user inputs to came from triggering the action                                                                           | Yes      |              |
| portRunId             | Port run ID to came from triggering the action                                                                                | Yes      |              |
| monorepoUrl           | If using scaffolding within a monorepo specify the URL here                                                                   | Yes      |              |
| scaffoldDirectory     | Root folder to scaffold when using monorepo                                                                                   | Yes      |              |
| githubURL             | GitHub url for self hosted version                                                                                            | Yes      |https://api.github.com|
| createPortEntity      | Whether should create port entity with the action or not. You can set this to `false` if you'd like to create the entry yourself with `port-labs/port-github-action`  | No  | true  |

## Quickstart - Scaffold Golang Template

Follow these steps to get started with the Golang template

1. Create the following GitHub action secrets
* `ORG_TOKEN` - a PAT (Personal Access Token) with permissions to create repositories
* `PORT_CLIENT_ID` - Port Client ID [learn more](https://docs.getport.io/build-your-software-catalog/sync-data-to-catalog/api/#get-api-token)
* `PORT_CLIENT_SECRET` - Port Client Secret [learn more](https://docs.getport.io/build-your-software-catalog/sync-data-to-catalog/api/#get-api-token) 

2. Install the Ports GitHub app from [here](https://github.com/apps/getport-io/installations/new).
3. Create a blueprint at Port with the following properties:
>**Note** Keep in mind this can be any blueprint you would like and this is just an example
```json
{
  "identifier": "microservice",
  "title": "Microservice",
  "icon": "Microservice",
  "schema": {
    "properties": {
      "description": {
        "title": "Description",
        "type": "string"
      },
      "url": {
        "title": "URL",
        "format": "url",
        "type": "string"
      },
      "readme": {
        "title": "README",
        "type": "string",
        "format": "markdown",
        "icon": "Book"
      }
    },
    "required": []
  },
  "mirrorProperties": {},
  "calculationProperties": {},
  "relations": {}
}
```

4. Create an action at Port with the following JSON file:
>**Note** Keep in mind that any field started with `cookiecutter` will automtically be injected into the cookiecutter inputs as a variable here for example we  are using the `cookiecutter_app_name` input of the [Golang Template](https://github.com/lacion/cookiecutter-golang)


```json
[
  {
    "identifier": "scaffold",
    "title": "Scaffold Golang Microservice",
    "icon": "Git",
    "userInputs": {
      "properties": {
        "name": {
          "title": "Repo Name",
          "type": "string"
        },
        "cookiecutter_app_name": {
          "type": "string",
          "title": "Application Name"
        }
      },
      "required": [
        "name"
      ]
    },
    "invocationMethod": {
      "type": "GITHUB",
      "org": "port-cookiecutter-example",
      "repo": "gha-templater",
      "workflow": "scaffold-golang.yml",
      "omitUserInputs": true
    },
    "trigger": "CREATE",
    "description": "Scaffolding a new Microservice from a set of templates using Cookiecutter"
  }
]
```
5. Create a workflow file under .github/workflows/scaffold-golang.yml with the following content:
```yml
on:
  workflow_dispatch:
    inputs:
      port_payload:
        required: true
        description: "Port's payload, including details for who triggered the action and general context (blueprint, run id, etc...)"
        type: string
    secrets: 
      ORG_TOKEN: 
        required: true
      PORT_CLIENT_ID:
        required: true
      PORT_CLIENT_SECRET:
        required: true
jobs: 
  scaffold:
    runs-on: ubuntu-latest
    steps:
      - uses: port-labs/cookiecutter-gha@v1.1
        with:
          portClientId: ${{ secrets.PORT_CLIENT_ID }}
          portClientSecret: ${{ secrets.PORT_CLIENT_SECRET }}
          token: ${{ secrets.ORG_TOKEN }}
          portRunId: ${{ fromJson(inputs.port_payload).context.runId }}
          repositoryName: ${{ fromJson(inputs.port_payload).payload.properties.name }}
          portUserInputs: ${{ toJson(fromJson(inputs.port_payload).payload.properties) }} 
          cookiecutterTemplate: https://github.com/lacion/cookiecutter-golang
          blueprintIdentifier: 'microservice'
          organizationName: INSERT_ORG_NAME
```
6. Trigger the action from Port UI.
![gif](https://user-images.githubusercontent.com/51213812/230777057-081adf0c-f792-447e-bdec-35c99d73ba02.gif)

## Monorepo
If you would like to create a PR in a monorepo subfolder instead, you can fill out the following inputs
```yml
  monorepoUrl: <your-monorepo-url>
  scaffoldDirectory: <directory to scaffold in i.e apps/> 
```

## Connecting Port's GitHub exporter

To make sure all of the properties (like url, readme etc..) come directly from Github in a seamless way, you can connect our GitHub exporter next [here](https://docs.getport.io/build-your-software-catalog/sync-data-to-catalog/git/github/examples#mapping-repositories-and-issues) you can find more information about it.

