<img align="right" width="100" height="74" src=https://cdn.prod.website-files.com/622996415264e2107087774c/65b09e2a73ab4ac42ad0c139_logo.svg />

# Scaffold Action

[![Slack](https://img.shields.io/badge/Slack-4A154B?style=for-the-badge&logo=slack&logoColor=white)](https://join.slack.com/t/devex-community/shared_invite/zt-1bmf5621e-GGfuJdMPK2D8UN58qL4E_g)

Use Port automations to quickly scaffold repositories using  [Cookiecutter templates](https://www.cookiecutter.io/templates) via GitHub Actions.

[Cookiecutter](https://www.cookiecutter.io/) is an open source templating library for creating boilerplate for projects in any programming language. In addition to selecting an existing template, you can also [build your own.](https://cookiecutter.readthedocs.io/en/2.0.2/tutorials.html#create-your-very-own-cookiecutter-project-template)

## Inputs

| Input                 | Description                                                                                                                   | Required | Default   |
|-----------------------|-------------------------------------------------------------------------------------------------------------------------------|----------|-----------|
| token                 | The GitHub Token to use to authenticate with the API with permissions to create repositories within the organization. Make sure to use [fine-grained tokens.](https://github.com/settings/personal-access-tokens) | Yes      |           |
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

Follow these steps to get started with the [Cookiecutter Golang template.](https://github.com/lacion/cookiecutter-golang)

1. Create the following GitHub action secrets
* `ORG_TOKEN` - a PAT (Personal Access Token) with permissions to create repositories
* `PORT_CLIENT_ID` - Port Client ID [learn more](https://docs.port.io/build-your-software-catalog/sync-data-to-catalog/api/#get-api-token)
* `PORT_CLIENT_SECRET` - Port Client Secret [learn more](https://docs.port.io/build-your-software-catalog/sync-data-to-catalog/api/#get-api-token) 

2. Install the [Port GitHub app](https://github.com/apps/getport-io/installations/new).
3. Create a blueprint at Port with the following properties:
>**Note** This can be any blueprint you would like -- this is just an example
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
{
  "identifier": "scaffold",
  "title": "Scaffold Golang Microservice",
    "icon": "Git",
  "invocationMethod": {
    "type": "GITHUB",
    "org": "port-cookiecutter-example",
    "repo": "gha-templater",
    "workflow": "scaffold-golang.yml"
  },
  "trigger": {
    "type": "self-service",
    "operation": "CREATE",
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
    }
  }
}
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
<img src="https://docs.port.io/img/guides/scaffoldSelfServiceAfterCreation.png">

## Monorepo
If you would like to create a PR in a monorepo subfolder instead, you can fill out the following inputs
```yml
  monorepoUrl: <your-monorepo-url>
  scaffoldDirectory: <directory to scaffold in i.e apps/> 
```

## Connecting Port's GitHub integration

To automatically collect and update all of the properties (e.g. pull requests, README updates, issues, etc) in your Port software catalog from your GitHub repositories after they're scaffolded, you can [connect Port to GitHub](https://docs.port.io/build-your-software-catalog/sync-data-to-catalog/git/github/examples#mapping-repositories-and-issues).

