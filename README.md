<img align="right" width="100" height="74" src="https://user-images.githubusercontent.com/8277210/183290025-d7b24277-dfb4-4ce1-bece-7fe0ecd5efd4.svg" />

# Export teams and users of repository to Port

[![Slack](https://img.shields.io/badge/Slack-4A154B?style=for-the-badge&logo=slack&logoColor=white)](https://join.slack.com/t/devex-community/shared_invite/zt-1bmf5621e-GGfuJdMPK2D8UN58qL4E_g)

This action will fetch all the collaborators and teams of the repository and will do the following:

* If the team does not exist in Port it will automatically create it and assign it to an entity with an identifier that equals to the repository name.
* If a blueprint with the given identifier does not exist within Port, it will be created with the minimal required properties. If you already have a blueprint with the given Identifier, you can add the following property to the blueprint.

```json showLineNumbers
"collaborators": {
    "type": "array",
    "title": "Collaborators",
    "items": {
        "type": "string",
        "format": "user"
    }
}
```

Example:

```yaml showLineNumbers
  populate-teams:
    runs-on: ubuntu-latest
    steps:
      - name: Populate teams and users
        uses: port-labs/github-teams-and-collaborators@v1
        with:
          repo: ${{ github.repository }}
          token: ${{ secrets.GIT_ADMIN_TOKEN }}
          portClientId: ${{ secrets.PORT_CLIENT_ID }}
          portClientSecret: ${{ secrets.PORT_CLIENT_SECRET }}
          blueprintIdentifier: Service
```

Inputs:
| Input | Description | Required | Default |
| --- | --- | --- | --- |
| `token` | The GitHub Token to use to authenticate with the API | `true` | N/A |
| `repo` | The repository to get collaborators and teams for | `true` | N/A |
| `portClientId` | The Port Client ID to use to authenticate with the API | `true` | N/A |
| `portClientSecret` | The Port Client Secret to use to authenticate with the API | `true` | N/A |
| `blueprintIdentifier` | The blueprint identifier to use to populate the Port | `true` | `Service` |
