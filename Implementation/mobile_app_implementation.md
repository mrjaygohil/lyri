# Lyrics Mobile App Implementation Plan

# Project Overview

Build a scalable Flutter Mobile Application for a Lyrics Platform using Supabase backend.

This mobile application supports:

* Admin Flow
* User Flow
* User Generated Lyrics
* Playlist / Track List System
* Google Authentication
* Song Discovery Experience

The mobile app should be modern, fast, scalable, and optimized for future growth.

---

# Main Application Flow

# Common Authentication Screen

Single authentication screen for:

* Admin Users
* Normal Users

Authentication methods:

* Email & Password Login
* Google Sign In
* Sign Up
* Forgot Password

---

# Role Based Navigation

After successful login:

## If role = admin

Navigate to:

* Admin Dashboard
* Admin Management Screens

Admin flow remains similar to existing web admin flow.

---

## If role = user

Navigate to:

* User Mobile Home
* Explore Songs
* Categories
* Playlists
* Profile

---

# Authentication System

# Features

## Login

* Email Login
* Password Login
* Google Login

---

## Signup

* Email Signup
* Google Signup
* Auto Create User Profile

---

## Forgot Password

* Reset Password Email

---

# Google Authentication Flow

## Google Sign In Logic

If Google user exists:

* Login directly

Else:

* Create new profile
* Assign role = user
* Store basic details

---

# User Profile Auto Creation

When user signs up using Google:

Create profile automatically.

## Profile Fields

| Field         | Type      |
| ------------- | --------- |
| id            | UUID      |
| full_name     | String    |
| email         | String    |
| avatar        | String    |
| role          | String    |
| auth_provider | String    |
| created_at    | Timestamp |

---

# User Mobile Application Features

# 1. Home Screen

Main user dashboard.

---

# Home Sections

## Featured Categories

Horizontal scroll categories.

Display:

* Category Image
* Category Name

When clicked:

Open category songs screen.

---

## Trending Songs

Display:

* Thumbnail
* Song Title
* Singer Name
* Mini Lyrics Preview

---

## Recently Added Songs

Latest uploaded songs.

---

## Recommended Songs

Future recommendation support.

---

# Home UI Design

## Top App Bar

Contains:

* App Logo
* Search Icon
* Notification Icon
* Profile Avatar

---

## Bottom Navigation

Tabs:

* Home
* Categories
* Create Song
* Track Lists
* Profile

---

# 2. Categories Module

# Features

* View All Categories
* Category Song Listing
* Song Preview Cards

---

# Category Songs Screen

Display:

* Song Thumbnail
* Song Title
* Singer
* Short Lyrics Preview
* Favorite Button

---

# Song Preview Example

Preview should show:

* First 3-4 lines of lyrics
* Song image
* Singer
* Tags

---

# 3. Song Detail Screen

# Features

* Full Lyrics View
* Rich Lyrics Formatting
* Song Thumbnail
* Singer Details
* Album Details
* Category
* Tags
* Favorite Song
* Share Song
* Add To Track List

---

# UI Sections

## Header

* Large Song Thumbnail
* Gradient Background
* Song Info

---

## Lyrics Section

* Expandable Lyrics
* Smooth Scrolling
* Font Size Adjustment

---

## Action Buttons

* Favorite
* Share
* Add To Playlist
* Download (Future)

---

# 4. User Song Creation Module

Users can create and publish lyrics.

---

# Features

* Create Song
* Edit Own Songs
* Delete Own Songs
* Save Draft
* Publish Song
* Upload Thumbnail

---

# Song Creation Fields

| Field       | Type            |
| ----------- | --------------- |
| title       | String          |
| lyrics      | Text            |
| singer_name | String          |
| album_name  | String          |
| language    | String          |
| category    | Relation        |
| tags        | Multi Relation  |
| thumbnail   | Image           |
| visibility  | Public/Private  |
| status      | Draft/Published |
| created_by  | UUID            |

---

# Song Moderation System

## User Uploaded Songs

Default state:

* Pending Review

Admin can:

* Approve
* Reject
* Hide

---

# 5. Track List / Playlist Module

Users can create custom track lists.

Example:

* Sad Songs
* Gym Playlist
* Romantic Collection
* Chill Mood

---

# Playlist Features

* Create Playlist
* Edit Playlist
* Delete Playlist
* Add Songs
* Remove Songs
* Reorder Songs
* Public/Private Playlist

---

# Playlist UI

## Playlist Card

Display:

* Cover Image
* Playlist Name
* Number Of Songs
* Owner Name

---

# Playlist Database

## playlists

| Field       | Type      |
| ----------- | --------- |
| id          | UUID      |
| user_id     | UUID      |
| title       | String    |
| description | Text      |
| cover_image | String    |
| visibility  | String    |
| created_at  | Timestamp |

---

## playlist_songs

| Field       | Type    |
| ----------- | ------- |
| id          | UUID    |
| playlist_id | UUID    |
| song_id     | UUID    |
| order_no    | Integer |

---

# 6. Favorites Module

Users can save favorite songs.

---

# Features

* Add To Favorites
* Remove Favorite
* Favorite Songs Screen

---

# 7. Search Module

# Search Songs By

* Song Title
* Singer
* Album
* Category
* Tags
* Lyrics Keywords

---

# Search Features

* Debounced Search
* Recent Searches
* Trending Searches
* Voice Search (Future)

---

# 8. Profile Module

# Features

* View Profile
* Edit Profile
* Profile Picture Upload
* My Songs
* My Playlists
* Favorites
* Logout

---

# 9. Admin Mobile Flow

If admin logs in from mobile:

Show admin dashboard optimized for tablet/mobile.

---

# Admin Features

* Manage Songs
* Approve User Songs
* Manage Categories
* Manage Tags
* Manage Users

---

# Updated Database Design

# profiles

| Field         | Type      |
| ------------- | --------- |
| id            | UUID      |
| full_name     | String    |
| email         | String    |
| avatar        | String    |
| role          | String    |
| auth_provider | String    |
| is_banned     | Boolean   |
| created_at    | Timestamp |

---

# categories

| Field      | Type      |
| ---------- | --------- |
| id         | UUID      |
| name       | String    |
| image      | String    |
| status     | Boolean   |
| created_at | Timestamp |

---

# songs

| Field           | Type      |
| --------------- | --------- |
| id              | UUID      |
| title           | String    |
| lyrics          | Text      |
| singer_name     | String    |
| album_name      | String    |
| language        | String    |
| category_id     | UUID      |
| thumbnail       | String    |
| visibility      | String    |
| approval_status | String    |
| created_by      | UUID      |
| approved_by     | UUID      |
| views_count     | Integer   |
| likes_count     | Integer   |
| created_at      | Timestamp |

---

# tags

| Field      | Type      |
| ---------- | --------- |
| id         | UUID      |
| name       | String    |
| created_at | Timestamp |

---

# song_tags

| Field   | Type |
| ------- | ---- |
| id      | UUID |
| song_id | UUID |
| tag_id  | UUID |

---

# playlists

| Field       | Type      |
| ----------- | --------- |
| id          | UUID      |
| user_id     | UUID      |
| title       | String    |
| description | Text      |
| cover_image | String    |
| visibility  | String    |
| created_at  | Timestamp |

---

# playlist_songs

| Field       | Type    |
| ----------- | ------- |
| id          | UUID    |
| playlist_id | UUID    |
| song_id     | UUID    |
| order_no    | Integer |

---

# favorites

| Field      | Type      |
| ---------- | --------- |
| id         | UUID      |
| user_id    | UUID      |
| song_id    | UUID      |
| created_at | Timestamp |

---

# Flutter Mobile Folder Structure

```bash id="sj58bn"
lib/
│
├── core/
│   ├── constants/
│   ├── theme/
│   ├── routes/
│   ├── services/
│   ├── helpers/
│   └── storage/
│
├── data/
│   ├── models/
│   ├── repositories/
│   ├── datasources/
│   └── providers/
│
├── modules/
│   ├── auth/
│   ├── splash/
│   ├── home/
│   ├── songs/
│   ├── categories/
│   ├── playlists/
│   ├── favorites/
│   ├── profile/
│   ├── search/
│   └── admin/
│
├── shared/
│   ├── widgets/
│   ├── components/
│   └── layouts/
│
└── main.dart
```

---

# Recommended Flutter Packages

```yaml id="h9s4vd"
dependencies:
  flutter:
    sdk: flutter

  flutter_riverpod:
  supabase_flutter:
  go_router:
  flutter_screenutil:
  cached_network_image:
  flutter_quill:
  image_picker:
  file_picker:
  google_fonts:
  google_sign_in:
  hive:
  hive_flutter:
  shimmer:
  share_plus:
  flutter_staggered_grid_view:
  flutter_svg:
  lottie:
```

---

# UI/UX Design Recommendations

# Design Style

* Music App Inspired
* Modern Dark UI
* Smooth Animations
* Glassmorphism Effects
* Gradient Cards
* Minimal Clean Layout

---

# Suggested Theme

## Dark Theme

Primary Colors:

* Purple
* Indigo
* Deep Blue

---

# Animations

* Hero Animations
* Fade Transitions
* Bottom Sheet Interactions
* Playlist Animations

---

# Supabase Storage Buckets

# song-thumbnails

Store:

* Song Images
* Playlist Covers
* User Uploaded Images

---

# avatars

Store:

* User Profile Pictures

---

# Row Level Security (RLS)

# Songs

## Public

Can read:

* Approved public songs

---

## Users

Can:

* Create own songs
* Edit own songs
* Delete own songs

---

## Admin

Can:

* Manage all songs
* Approve songs
* Delete songs

---

# Playlists

Users can:

* Manage own playlists

Public can:

* Read public playlists

---

# Favorites

Users can manage only their own favorites.

---

# Suggested Development Phases

# Phase 1

* Flutter Setup
* Supabase Setup
* Authentication
* Google Login
* Role Based Navigation

---

# Phase 2

* Home Screen
* Categories
* Song Detail Screen

---

# Phase 3

* Song Creation
* Song CRUD
* Image Upload

---

# Phase 4

* Playlist System
* Favorites
* Search System

---

# Phase 5

* Admin Mobile Flow
* Song Moderation
* Notifications

---

# Phase 6

* Performance Optimization
* Offline Support
* Analytics

---

# Future Enhancements

* Audio Streaming
* Lyrics Synchronization
* AI Lyrics Suggestions
* Followers System
* Realtime Comments
* Push Notifications
* Offline Downloads
* Multi Language Support

---

# Final Objective

Build a scalable lyrics ecosystem where:

* Users explore songs easily
* Users create and publish lyrics
* Users manage personal playlists
* Admin manages the platform efficiently
* Platform is ready for future public growth
