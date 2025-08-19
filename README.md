# ChatterBox API
Rails API backend for the ChatterBox app — user accounts, groups (“circles”), and content. This service powers the Android app: [https://github.com/KatieLonsdale/circles_fe]

## Table of Contents
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)

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
Create .env (or set these in your shell) and ensure Rails credentials are available.

Common variables:

# Database
DATABASE_URL=postgres://postgres:postgres@localhost:5432/circles_dev

3) Database
# Create, migrate, and seed
bin/rails db:setup
# (equivalent to: db:create db:migrate db:seed)

4) Run the server
bin/rails s
# API will be available at http://localhost:3000
