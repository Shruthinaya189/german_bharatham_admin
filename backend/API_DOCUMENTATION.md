# German Bharatham Admin Backend API Documentation

## Overview
This backend provides a unified listings system across all categories: Accommodation, Food, Services, and Jobs.

## Key Changes Implemented

### 1. Unified Listings System
All categories now follow a consistent structure with proper models, controllers, and routes.

### 2. API Endpoints

#### Dashboard Stats
**GET** `/api/admin/stats`
Returns comprehensive dashboard statistics including:
- Total listings count (all categories combined)
- Total categories count
- Total users count
- Pending reviews count
- Category-wise breakdown (Accommodation, Food, Services, Jobs)
- Recent listings (top 6 across all categories)

Response Example:
```json
{
  "stats": {
    "totalListings": 53,
    "totalCategories": 4,
    "totalUsers": 150,
    "pendingReviews": 5
  },
  "categoryStats": [
    { "name": "Accommodation", "count": 29, "icon": "🏠" },
    { "name": "Food", "count": 14, "icon": "🍴" },
    { "name": "Services", "count": 7, "icon": "🔧" },
    { "name": "Jobs", "count": 3, "icon": "💼" }
  ],
  "recentListings": [...]
}
```

#### All Listings (Unified View)
**GET** `/api/admin/listings`
Query Parameters:
- `category` - Filter by category (Accommodation, Food, Job, Services)
- `status` - Filter by status (Active, Pending, Inactive)
- `search` - Search in title and location
- `sort` - Sort order (newest, oldest, a-z)

Returns all listings from all categories in a unified format.

#### Category Statistics
**GET** `/api/admin/categories`
Returns category information with listing counts.

#### Individual Category Endpoints

**Accommodation**
- GET `/api/admin/accommodation` - Get all accommodations
- GET `/api/admin/accommodation/:id` - Get single accommodation
- POST `/api/admin/accommodation` - Create accommodation (Admin only)
- PUT `/api/admin/accommodation/:id` - Update accommodation (Admin only)
- DELETE `/api/admin/accommodation/:id` - Delete accommodation (Admin only)

**Food & Grocery**
- GET `/api/admin/foodgrocery` - Get all food/grocery listings
- GET `/api/admin/foodgrocery/:id` - Get single item
- POST `/api/admin/foodgrocery` - Create item (Admin only)
- PUT `/api/admin/foodgrocery/:id` - Update item (Admin only)
- DELETE `/api/admin/foodgrocery/:id` - Delete item (Admin only)

**Jobs**
- GET `/api/admin/jobs` - Get all jobs
- GET `/api/admin/jobs/:id` - Get single job
- POST `/api/admin/jobs` - Create job (Admin only)
- PUT `/api/admin/jobs/:id` - Update job (Admin only)
- DELETE `/api/admin/jobs/:id` - Delete job (Admin only)

**Services**
- GET `/api/admin/services` - Get all services
- GET `/api/admin/services/:id` - Get single service
- POST `/api/admin/services` - Create service (Admin only)
- PUT `/api/admin/services/:id` - Update service (Admin only)
- DELETE `/api/admin/services/:id` - Delete service (Admin only)

### 3. Data Models

All models include:
- `title` - Listing title
- `category` - Main category (Accommodation, Food, Job, Services)
- `location` - Combined address for display
- `status` - Active, Pending, or Inactive
- `createdAt` - Timestamp
- `updatedAt` - Timestamp

### 4. Frontend Integration Requirements

#### Remove "Food & Grocery" from Sidebar
The Layout.js component should NOT have Food & Grocery as a separate menu item. It should only appear when viewing Categories > Food.

#### Update Dashboard Component
Replace hardcoded data with API calls to `/api/admin/stats`

#### Update Listings Component
Replace hardcoded data with API calls to `/api/admin/listings`

#### Update Categories Component
Replace hardcoded data with API calls to `/api/admin/categories`
When clicking on "Food" category, it should navigate to a filtered listings view showing only Food items.

### 5. Data Flow
When a new Food/Grocery listing is added:
1. It saves to the `foodgrocery` collection with status='Pending'
2. Dashboard stats automatically updates (total listings, pending reviews, category counts)
3. Recent listings shows the new item
4. Listings page shows it when fetching all listings
5. Categories page reflects the updated count for Food category

All data is real-time from the database - no hardcoded values.
