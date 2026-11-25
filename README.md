# DialCatz Action

Run your API tests on every change. This action runs [DialCatz](https://catzoid.com/dialcatz), Postman and OpenAPI collections in GitHub Actions, with a summary on the run's page and an error for each request that failed.

```yaml
name: API tests
on: [push, pull_request]
permissions:
  contents: read
jobs:
  api:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: docker compose up -d --wait   # start your API, if it is not running somewhere already
      - uses: catzoidhub/DialCatz-Action@v1
        with:
          path: ./api
          report: dialcatz-report.html
        env:
          baseUrl: http://localhost:3000
          apiToken: ${{ secrets.API_TOKEN }}
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: dialcatz-report
          path: dialcatz-report.html
          if-no-files-found: ignore
```

The app writes this file for you: right-click a collection → **Run in CI…**

## Inputs

| Input | |
|---|---|
| `path` | **Required.** A DialCatz workspace folder (with `dialcatz.yml`), a DialCatz or Postman collection file, or an OpenAPI file |
| `collection` | Only this collection of a workspace folder |
| `folder` | Only the requests under this folder |
| `vars` | Variables, one `name=value` per line |
| `env-file` | A file of `NAME=value` lines |
| `data` | A CSV or JSON file; the collection runs once per row |
| `spec` | An OpenAPI file every response is checked against |
| `retries` | Try a failed request again, up to this many times |
| `bail` | `true`: stop at the first failure |
| `report` | Where to write an HTML report |
| `details` | `true`: headers and bodies in the HTML report, credentials hidden |
| `junit` | Where to write a JUnit XML report |
| `args` | More options of `dialcatz run`, one per line (`--timeout=60`) |
| `working-directory` | Where to run (`.`) |
| `version` | The [dialcatz](https://www.npmjs.com/package/dialcatz) version on npm (`1`: the latest 1.x) |

Outputs: `passed`, `requests`, `failed`.

A `{{variable}}` takes its value from `vars`, then `env-file`, then an environment variable of the same name. Keep secrets in the repository's secrets and pass them with `env`. Node 20 or later is needed; GitHub's runners have it.

A request fails when it gets no answer, a test of it fails, or its response does not match `spec`. Without tests, an error 500 is an answer too, so give your requests tests.

## Licence

This action is MIT. The DialCatz CLI it runs is [GPL-3.0](https://github.com/catzoidhub/DialCatz); running it does not affect your own code's licence. Part of [Catzoid](https://catzoid.com).
