# Library Management (Rails API + React)

A simple library management system with:
- Rails 7.1 JSON API (PostgreSQL, Devise + JWT)
- React + Vite frontend (`frontend/`)

## Stack
- Ruby 3.2.2
- Rails 7.1
- PostgreSQL 13+
- Node 18+ and npm 9+

## Project layout
- Backend (Rails API): root directory
- Frontend (React + Vite): `frontend/`

## Prerequisites
- Ruby 3.2.2 (rbenv, asdf, or your preferred Ruby manager)
- Bundler: `gem install bundler`
- PostgreSQL running locally (defaults: host `localhost`, port `5432`)
- Node 18+ and npm 9+

Environment variables used by Rails (optional, with sensible defaults):
- `PGHOST` (default `localhost`)
- `PGPORT` (default `5432`)
- `PGUSER` (default current OS user)
- `PGPASSWORD` (if your Postgres requires a password)

## Backend setup (Rails API)
1) Install gems
```bash
bundle install
```

2) Setup database (create, migrate, seed)
```bash
bin/rails db:setup
# or explicitly
bin/rails db:create db:migrate db:seed
```

3) Run API server
```bash
bin/rails s
# API will be available at http://localhost:3000
```

### Seed data
The seed script creates roles, users, 20 books, and example borrowings. You can add as
many seed data you prefer.

Users (password: `password123`):
- Librarian: `alice@example.com`
- Members: `bob@example.com`, `carol@example.com`, `dave@example.com`, `eve@example.com`

## Frontend setup (React + Vite)
1) Install dependencies
```bash
cd frontend
npm install
```

2) Configure API base (optional)

The frontend uses `VITE_API_BASE` (default `http://localhost:3000/api/v1`). Create `.env` if you want to override:
```bash
echo 'VITE_API_BASE=http://localhost:3000/api/v1' > frontend/.env
```

3) Run dev server
```bash
npm run dev
# App will be available at http://localhost:5173
```

## Authentication
- Devise + JWT; tokens are returned in the `Authorization` response header.
- Frontend stores the token in `localStorage` under `jwt` and keeps basic user info (`currentUserId`, `currentUserName`, `currentUserRoleId`).
- A custom `auth:changed` event keeps the app header reactive after sign-in/sign-up/sign-out.

Auth endpoints:
- Sign up: `POST /api/v1/auth` (body `{ user: { name, email, password, password_confirmation } }`)
  - By default the user registered is a 'member'. If wish to have more librarian users,
  please add more records for it in the seed file.
- Sign in: `POST /api/v1/auth/sign_in` (body `{ user: { email, password } }`)
- Sign out: `DELETE /api/v1/auth/sign_out`

### Sign Up
Request
```json
{
  "user": {
    "name": "Alice",
    "email": "alice@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }
}
```
Success (201 Created)
```json
{
  "user": { "id": 1, "name": "Alice", "email": "alice@example.com", "user_role_id": 2 },
  "message": "Signed up successfully"
}
```
Response headers
```
Authorization: Bearer <JWT>
```

### Sign In
Request
```json
{ "user": { "email": "alice@example.com", "password": "password123" } }
```
Success (200 OK)
```json
{
  "user": { "id": 1, "name": "Alice", "email": "alice@example.com", "user_role_id": 2 },
  "message": "Logged in successfully"
}
```
Response headers
```
Authorization: Bearer <JWT>
```

### Sign Out
Request
```
DELETE /api/v1/auth/sign_out
```
Success (200 OK)
```json
{ "message": "Logged out successfully" }
```

## API overview (selected)

### Books
- `GET /api/v1/books?q&limit&offset`
```json
{
  "data": [
    {
      "id": 1,
      "title": "Sample Book 1",
      "author": "Author",
      "genre": "Fiction",
      "isbn": "ISBN-001001",
      "total_copies": 5,
      "available": true
    }
  ],
  "pagination": { "limit": 10, "offset": 0, "count": 10 }
}
```

- `GET /api/v1/books/:id`
```json
{
  "data": {
    "book": { "id": 1, "title": "Sample Book 1", "author": "Author", "genre": "Fiction", "isbn": "ISBN-001001", "total_copies": 5, "available": true },
    "book_borrowings": [
      { "id": 10, "book_id": 1, "borrowing_date": "2025-10-01", "due_date": "2025-10-15", "returned_date": null, "user_name": "Bob Member" }
    ],
    "current_user_has_active_borrowing": false
  }
}
```

- `POST /api/v1/books` (librarian)
Request
```json
{
  "book": {
    "title": "New Book",
    "author": "Author Name",
    "genre": "Fiction",
    "isbn": "ISBN-NEW-001",
    "total_copies": 5
  }
}
```
Success (201 Created)
```json
{
  "id": 123,
  "title": "New Book",
  "author": "Author Name",
  "genre": "Fiction",
  "isbn": "ISBN-NEW-001",
  "total_copies": 5,
  "available": true,
  "created_at": "2025-10-06T21:00:00Z",
  "updated_at": "2025-10-06T21:00:00Z"
}
```
Error (422)
```json
{ "errors": ["Isbn has already been taken"] }
```

- `PATCH /api/v1/books/:id` (librarian)
Request
```json
{ "book": { "title": "Updated Title", "total_copies": 8 } }
```
Success (200 OK)
```json
{
  "id": 123,
  "title": "Updated Title",
  "author": "Author Name",
  "genre": "Fiction",
  "isbn": "ISBN-NEW-001",
  "total_copies": 8,
  "available": true,
  "created_at": "2025-10-06T21:00:00Z",
  "updated_at": "2025-10-06T21:05:00Z"
}
```
Error (422)
```json
{ "errors": ["Title can't be blank"] }
```

- `DELETE /api/v1/books/:id` (librarian)
Success (204 No Content)
```
<no body>
```

### Borrowings
- Create: `POST /api/v1/books/:book_id/book_borrowings`
```json
{ "book_borrowing": { "due_date": "2025-10-15" } }
```

- Mark returned: `PATCH /api/v1/book_borrowings/:id/return`
```json
{ "id": 10, "book_id": 1, "user_id": 2, "borrowing_date": "2025-10-01", "due_date": "2025-10-15", "returned_date": "2025-10-10" }
```

### Dashboards
- Member: `GET /api/v1/dashboard/member`
```json
{
  "borrowings": [
    { "borrowing_id": 1, "book": { "id": 1, "title": "B1" }, "due_date": "2025-10-05", "returned_date": null, "overdue": true }
  ],
  "overdue_borrowings": [
    { "borrowing_id": 1, "book": { "id": 1, "title": "B1" }, "due_date": "2025-10-05", "returned_date": null, "overdue": true }
  ]
}
```

- Librarian: `GET /api/v1/dashboard/librarian`
```json
{
  "total_books": 42,
  "total_borrowed": 12,
  "books_due_today": [
    { "book": { "id": 1, "title": "B1" }, "borrowing": { "id": 10, "user": { "id": 2, "name": "Bob", "email": "bob@example.com" }, "due_date": "2025-10-06", "returned_date": null } }
  ],
  "overdue_members": [
    {
      "user": { "id": 3, "name": "Carol", "email": "carol@example.com" },
      "count": 2,
      "books": [
        { "book": { "id": 5, "title": "B5" }, "due_date": "2025-10-01", "returned_date": null },
        { "book": { "id": 7, "title": "B7" }, "due_date": "2025-09-29", "returned_date": "2025-10-03" }
      ]
    }
  ],
  "borrowings": [
    { "borrowing_id": 20, "book": { "id": 9, "title": "B9" }, "due_date": "2025-10-10", "overdue": false }
  ]
}
```

## Running tests
Use RSpec:
```bash
bundle exec rspec

# run a specific file
bundle exec rspec spec/controllers/api/v1/dashboard/member_controller_spec.rb
```

## Development notes
- CORS is enabled for the API (see `config/initializers/cors.rb`).
- Soft-delete flags exist on several tables (`deleted`, `deleted_at`).
- Books have `available` computed based on outstanding borrowings; librarians can mark borrowings returned.
- UI niceties: formatted dates (MM/DD/YYYY), clickable titles, account menu, and dashboard tabs.

## Common commands
```bash
# Reset the dev database and reseed
bin/rails db:drop db:create db:migrate db:seed

# Start API
bin/rails s

# Start frontend
cd frontend && npm run dev
```

## Troubleshooting
Postgres “database is being accessed by other users” when dropping:
```sql
-- connect to the postgres db (not the app db), then:
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname IN ('library_management_development','library_management_test')
  AND pid <> pg_backend_pid();
```

Missing JWTs in responses: ensure Devise and devise-jwt are configured and you’re hitting the `/api/v1/auth/sign_in` endpoint; the token is returned in the `Authorization` header.

Frontend cannot reach API: verify `VITE_API_BASE` and that Rails is running on `http://localhost:3000`.

