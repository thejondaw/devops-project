# API App

```shell
apps
┣ api
┃ ┣ node_modules       # Node.js dependencies
┃ ┣ src                # Source code
┃ ┣ tests              # Directory for tests
┃ ┣ .eslintignore      # Files to be ignored by ESLint
┃ ┣ .eslintrc.json     # ESLint configuration
┃ ┣ .gitignore         # Files to be ignored by Git
┃ ┣ Dockerfile         # Docker image configuration
┃ ┣ package.json       # NPM package manifest and dependencies
┃ ┣ package-lock.json  # Locked versions of dependencies
┃ ┗ README.md          # Documentation
```

```sh
# Install the node packages for the API:

npm install
```

```sh
# Start the app:

npm start
```

## NOTE this app uses two env variables:

- PORT: listening PORT
- DB: Name of database to connect
- DBUSER: Database user
- DBPASS: DB user password
- DBHOST: Database hostname
- DBPORT: Database server listening port

These variables need to be set.
