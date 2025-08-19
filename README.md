# ChatterBox API
Rails API backend for the ChatterBox app — user accounts, groups (“circles”), and content. This service powers the Android app: https://github.com/KatieLonsdale/circles_fe

## Table of Contents
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [JSON API Contract](#json-api-contract)
- [License](#license)

## Tech Stack
- Ruby on Rails (API mode)
- PostgreSQL
- RSpec testing framework
- AWS S3 SDK

## Getting started
### Prerequisites
- Ruby 3.2.2
- PostgreSQL

1) Clone & install
```
git clone https://github.com/KatieLonsdale/circles_app.git
cd circles_app
bundle install
```

2) Environment
This project uses the Figaro gem to store environment variables. Create an application.yml
```
bundle exec figaro install
```
Add the following variables for full functionality:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- S3_BUCKET_NAME
- AWS_REGION
- GOOGLE_APPLICATION_CREDENTIALS_PATH
- FIREBASE_PROJECT_ID

3) Database
Create
```
rails db:create
```
Migrate
```
rails db:migrate
```

4) Run the server
```
bin/rails s
```
API will be available at http://localhost:3000

## JSON API Contract
This API uses RESTful architecture. See [json-contact.md](./json-contract.md) for full details.

## License
License: Proprietary, evaluation-only. See [LICENSE](./LICENSE).
