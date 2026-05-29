# Lyrics Admin Panel Web Application (Flutter Web + Supabase)

# Project Goal

Build a modern Admin Panel Web Application for managing lyrics data.

Current phase focuses ONLY on:

* Flutter Web Admin Panel
* Supabase Backend
* Database Structure
* Admin Features

Mobile application will be developed later.

---

# Tech Stack

## Frontend

* Flutter Web

## Backend

* Supabase

## Database

* PostgreSQL (Supabase)

## Authentication

* Supabase Auth

## State Management

* Riverpod

## Routing

* Go Router

---

# Admin Panel Features

# 1. Authentication Module

## Features

* Admin Login
* Forgot Password
* Session Management
* Protected Routes

---

# 2. Dashboard Module

## Dashboard Cards

* Total Songs
* Total Categories
* Total Tags
* Total Users
* Recent Songs

## Dashboard Charts (Optional)

* Songs Per Category
* Most Viewed Songs

---

# 3. Manage Songs

## Features

* Add Song
* Edit Song
* Delete Song
* Search Song
* Filter Songs
* Rich Text Lyrics Editor

---

## Song Fields

| Field       | Type              |
| ----------- | ----------------- |
| title       | String            |
| lyrics      | Text              |
| singer_name | String            |
| album_name  | String            |
| language    | String            |
| category    | Relation          |
| tags        | Multiple Relation |
| status      | Active/Inactive   |
| thumbnail   | Image             |
| created_at  | Timestamp         |

---

# 4. Manage Categories

## Features

* Add Category
* Edit Category
* Delete Category
* Enable / Disable Category

---

## Category Fields

| Field      | Type      |
| ---------- | --------- |
| name       | String    |
| image      | String    |
| status     | Boolean   |
| created_at | Timestamp |

---

# 5. Manage Tags

## Features

* Add Tag
* Edit Tag
* Delete Tag

---

## Tag Fields

| Field      | Type      |
| ---------- | --------- |
| name       | String    |
| created_at | Timestamp |

---

# 6. Manage Users

## Features

* View Users
* Ban User
* Delete User
* View Registration Date

---

# Database Design

# Tables Structure

## profiles

| Field      | Type      |
| ---------- | --------- |
| id         | UUID      |
| full_name  | String    |
| email      | String    |
| role       | String    |
| created_at | Timestamp |

---

## categories

| Field      | Type      |
| ---------- | --------- |
| id         | UUID      |
| name       | String    |
| image      | String    |
| status     | Boolean   |
| created_at | Timestamp |

---

## tags

| Field      | Type      |
| ---------- | --------- |
| id         | UUID      |
| name       | String    |
| created_at | Timestamp |

---

## songs

| Field       | Type      |
| ----------- | --------- |
| id          | UUID      |
| title       | String    |
| lyrics      | Text      |
| singer_name | String    |
| album_name  | String    |
| language    | String    |
| category_id | UUID      |
| thumbnail   | String    |
| status      | Boolean   |
| created_at  | Timestamp |

---

## song_tags

| Field   | Type |
| ------- | ---- |
| id      | UUID |
| song_id | UUID |
| tag_id  | UUID |

---

# Supabase Authentication

## Roles

### Admin

Can:

* Manage Songs
* Manage Categories
* Manage Tags
* Manage Users

### User

Can:

* Read Lyrics Only

---

# Row Level Security (RLS)

## Rules

### Songs

* Public can read active songs
* Only admin can create/update/delete

### Categories

* Public can read
* Only admin can modify

### Tags

* Public can read
* Only admin can modify

---

# Flutter Web Folder Structure

```bash id="6g6l26"
lib/
│
├── core/
│   ├── constants/
│   ├── theme/
│   ├── routes/
│   └── helpers/
│
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
│
├── modules/
│   ├── auth/
│   ├── dashboard/
│   ├── songs/
│   ├── categories/
│   ├── tags/
│   └── users/
│
├── shared/
│   ├── widgets/
│   └── layouts/
│
└── main.dart
```

---

# Recommended Flutter Packages

```yaml id="pib6nf"
dependencies:
  flutter:
    sdk: flutter

  flutter_riverpod:
  supabase_flutter:
  go_router:
  flutter_screenutil:
  cached_network_image:
  flutter_quill:
  data_table_2:
  file_picker:
  image_picker:
  google_fonts:
```

---

# UI Pages

# Authentication

* Login Page

# Dashboard

* Overview Statistics

# Songs

* Song List
* Add Song
* Edit Song

# Categories

* Category List
* Add Category

# Tags

* Tag List
* Add Tag

# Users

* User List

---

# Admin Panel Layout

# Sidebar Menu

* Dashboard
* Songs
* Categories
* Tags
* Users
* Logout

---

# Search & Filter System

## Song Search

Search by:

* Song Name
* Singer
* Tags
* Category

---

# Recommended UI Design

## Design Style

* Clean
* Modern
* Responsive
* Dark Sidebar
* Minimal Dashboard

---

# Suggested Development Order

# Phase 1

* Setup Flutter Web
* Setup Supabase
* Authentication

# Phase 2

* Dashboard UI
* Sidebar Navigation
* Route Protection

# Phase 3

* Categories CRUD
* Tags CRUD

# Phase 4

* Songs CRUD
* Image Upload
* Rich Lyrics Editor

# Phase 5

* Users Management
* Optimization

---

# Supabase Storage

## Buckets

### song-thumbnails

Store:

* Song Images
* Category Images

---

# Future Enhancements

## Next Phase

* Mobile App
* Public Lyrics Website
* SEO Optimization
* AI Lyrics Suggestion
* Favorite Songs
* Analytics

---

# Deployment

## Flutter Web

* Vercel
* Firebase Hosting
* Netlify

## Backend

* Supabase Cloud

---

# Production Recommendations

## Performance

* Pagination
* Lazy Loading
* Debounced Search

## Security

* Enable RLS
* Validate Admin Role
* Secure Storage Access

## Code Quality

* Repository Pattern
* Feature Based Architecture
* Reusable Components

---

# Final Objective

Create a scalable lyrics management admin panel where admin can:

* Manage songs efficiently
* Organize songs with categories/tags
* Handle users
* Prepare backend for future mobile app
