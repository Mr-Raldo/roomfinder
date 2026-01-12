# Room Finder - Complete Database Setup Guide

## 📋 Overview

This guide will walk you through setting up the complete database schema for the Room Finder application, including all tables, storage buckets, triggers, and security policies.

---

## 🗂️ Database Schema Summary

### User Management (3 account types)
- ✅ **rf_user_profile** - Students, Landlords, Administrators
- ✅ **otps** - OTP verification codes

### Property & Room Management
- ✅ **houses** - Property listings with amenities
- ✅ **house_images** - Multiple images per property
- ✅ **rooms** - Individual rooms in properties
- ✅ **room_images** - Room photos
- ✅ **room_specifications** - Additional room details (wifi speed, water pressure, etc.)

### Booking & Occupancy
- ✅ **bookings** - Room booking requests
- ✅ **occupancies** - Current tenants/leases
- ✅ **payment_transactions** - Rent, deposits, utilities

### Communication
- ✅ **chat_conversations** - Student-Landlord conversations
- ✅ **chat_messages** - Message history
- ✅ **notifications** - Push notifications
- ✅ **broadcast_notices** - Landlord/Admin announcements
- ✅ **broadcast_recipients** - Who received broadcasts

### Reviews & Engagement
- ✅ **reviews** - Room/Landlord ratings
- ✅ **favorites** - Saved rooms
- ✅ **viewing_history** - Track room views

### Admin & Moderation
- ✅ **reported_content** - Flagged content

### Storage Buckets
- ✅ **profile-pictures** - User avatars
- ✅ **house-images** - Property photos (public)
- ✅ **room-images** - Room photos (public)
- ✅ **chat-attachments** - Chat files (private)
- ✅ **documents** - Legal documents (private)

---

## 🚀 Setup Instructions

### Step 1: Create Supabase Project

1. Go to https://supabase.com
2. Create a new project
3. Note down your:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY` (for edge functions)

### Step 2: Update Environment Variables

Update your `.env` file:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### Step 3: Run Database Schema

#### Option A: Using Supabase Dashboard (Recommended)

1. Go to your Supabase Dashboard
2. Navigate to **SQL Editor** in the left sidebar
3. Click **"New Query"**
4. Copy the entire contents of `database_schema.sql`
5. Paste into the editor
6. Click **"Run"**
7. Wait for all tables to be created (should take 10-30 seconds)

#### Option B: Using Supabase CLI

```bash
# Install Supabase CLI
npm install -g supabase

# Login
supabase login

# Link to your project
supabase link --project-ref your-project-ref

# Run migration
supabase db push

# Or run the SQL file directly
psql postgresql://postgres:[YOUR-PASSWORD]@db.[YOUR-PROJECT-REF].supabase.co:5432/postgres < database_schema.sql
```

### Step 4: Create Storage Buckets

#### Option A: Using Supabase Dashboard

1. Go to **Storage** in left sidebar
2. Create each bucket with these settings:

**Bucket: `profile-pictures`**
- Public: ❌ No
- File size limit: 5 MB
- Allowed MIME types: `image/jpeg, image/png, image/webp`

**Bucket: `house-images`**
- Public: ✅ Yes
- File size limit: 10 MB
- Allowed MIME types: `image/jpeg, image/png, image/webp`

**Bucket: `room-images`**
- Public: ✅ Yes
- File size limit: 10 MB
- Allowed MIME types: `image/jpeg, image/png, image/webp`

**Bucket: `chat-attachments`**
- Public: ❌ No
- File size limit: 20 MB
- Allowed MIME types: `image/*, application/pdf, application/msword`

**Bucket: `documents`**
- Public: ❌ No
- File size limit: 10 MB
- Allowed MIME types: `application/pdf, image/*`

3. For each bucket, go to **Policies** tab and add the RLS policies from `storage_buckets_setup.md`

#### Option B: Using SQL (Run in SQL Editor)

See `storage_buckets_setup.md` for the complete SQL policies

### Step 5: Verify Setup

Run these queries in the SQL Editor to verify:

```sql
-- Check all tables are created
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Should return 19 tables:
-- bookings, broadcast_notices, broadcast_recipients, chat_conversations,
-- chat_messages, favorites, house_images, houses, notifications,
-- occupancies, otps, payment_transactions, reported_content,
-- reviews, rf_user_profile, room_images, room_specifications,
-- rooms, viewing_history

-- Check indexes
SELECT indexname, tablename
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename;

-- Check triggers
SELECT trigger_name, event_object_table
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table;

-- Check RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- Check storage buckets
SELECT * FROM storage.buckets;
```

### Step 6: Configure Edge Functions

Your edge functions need access to these tables:

**send-otp-notifytext** → Uses `otps` table
**verify-otp** → Uses `otps` table
**register-user-with-kyc** → Uses `rf_user_profile` table

Make sure your edge functions have the correct table names:

```typescript
// In your edge functions, change:
.from('kyc_profile')  // OLD (Geza)

// To:
.from('rf_user_profile')  // NEW (Room Finder)
```

---

## 📊 Database Relationships Diagram

```
rf_user_profile (Students, Landlords, Admins)
├── houses (landlord_id) → Landlords create properties
│   ├── house_images
│   └── rooms
│       ├── room_images
│       ├── room_specifications
│       ├── bookings (student_id) → Students book rooms
│       ├── occupancies (student_id) → Active tenants
│       ├── reviews (student_id)
│       └── favorites (student_id)
│
├── chat_conversations (student_id + landlord_id)
│   └── chat_messages
│
├── notifications
├── broadcast_notices (sender = landlord/admin)
│   └── broadcast_recipients
│
├── viewing_history
├── reported_content
└── payment_transactions
```

---

## 🔐 Security Features

### Row Level Security (RLS)
- ✅ Users can only view/edit their own profile
- ✅ Landlords can only manage their own properties
- ✅ Students can only create/view their own bookings
- ✅ Chat messages restricted to conversation participants
- ✅ Notifications only visible to recipient

### Data Privacy
- ✅ PIN encrypted with AES (same as Geza app)
- ✅ Phone numbers stored in E.164 format
- ✅ Personal documents in private storage buckets
- ✅ Chat attachments not publicly accessible

### Admin Powers
- ✅ Administrators can view all content
- ✅ Can verify/suspend users
- ✅ Can approve/reject listings
- ✅ Can resolve reported content

---

## 🎯 Key Features Enabled

### For Students:
- ✅ Search & browse available rooms
- ✅ Filter by location, price, amenities
- ✅ Save favorite rooms
- ✅ Book rooms & track applications
- ✅ Chat with landlords
- ✅ Review rooms & landlords
- ✅ Track payment history

### For Landlords:
- ✅ List multiple properties
- ✅ Add multiple rooms per property
- ✅ Upload property & room images
- ✅ Specify amenities (wifi, water, curfew, etc.)
- ✅ Manage bookings (approve/reject)
- ✅ Chat with potential tenants
- ✅ Broadcast notices to tenants
- ✅ Track occupancy & payments
- ✅ View analytics & stats

### For Administrators:
- ✅ Manage all users
- ✅ Verify/approve listings
- ✅ Handle reported content
- ✅ View system-wide analytics
- ✅ Send broadcast notifications
- ✅ Moderate reviews

---

## 📈 Performance Optimizations

### Indexes Created
- All foreign keys indexed
- Search fields indexed (city, status, price)
- Frequently queried fields indexed
- Composite indexes for common queries

### Triggers Implemented
- ✅ Auto-update `updated_at` timestamps
- ✅ Update room occupancy on booking
- ✅ Update conversation last message
- ✅ Increment view counts

### Views Created
- ✅ `available_rooms_view` - Join rooms with house details & landlord info
- ✅ `landlord_stats_view` - Aggregated stats for landlord dashboard

---

## 🧪 Testing the Setup

### Create Test Data

```sql
-- 1. Create test landlord (after registration via app)
-- The auth will be created via edge function

-- 2. Create test house
INSERT INTO houses (
  landlord_id, title, description, house_type,
  address, city, total_rooms,
  has_wifi, has_municipal_water, has_parking,
  is_active
) VALUES (
  'landlord-user-id-here',
  'Student Accommodation Near Campus',
  'Modern accommodation with all amenities',
  'Apartment',
  '123 Main Street',
  'Harare',
  5,
  true, true, true,
  true
);

-- 3. Create test rooms
INSERT INTO rooms (
  house_id, room_number, title, room_type,
  max_occupants, price_per_month, deposit_amount,
  status, has_own_bathroom
) VALUES (
  'house-id-here',
  'Room 1',
  'Single Room with Ensuite',
  'Ensuite',
  1,
  500.00,
  500.00,
  'vacant',
  true
);

-- 4. Query available rooms
SELECT * FROM available_rooms_view WHERE city = 'Harare';
```

---

## 🔧 Troubleshooting

### Issue: Tables not created
**Solution:** Check SQL Editor for errors, run schema in smaller chunks

### Issue: RLS blocking queries
**Solution:** Verify RLS policies are set correctly, check auth.uid() matches

### Issue: Storage upload fails
**Solution:** Verify bucket exists, check RLS policies on storage.objects

### Issue: Triggers not firing
**Solution:** Check trigger function exists, verify BEFORE/AFTER timing

### Issue: Foreign key constraint errors
**Solution:** Ensure parent records exist before creating child records

---

## 📝 Next Steps

After setting up the database:

1. ✅ Update edge functions to use `rf_user_profile` table
2. ✅ Test registration & login flow
3. ✅ Create test landlord and add properties
4. ✅ Test student booking flow
5. ✅ Test chat functionality
6. ✅ Test notifications
7. ✅ Set up scheduled tasks for:
   - Expiring old OTPs
   - Sending rent reminders
   - Cleaning up expired bookings

---

## 🔄 Maintenance Tasks

### Regular Cleanup (Create as Supabase Functions)

```sql
-- Delete expired OTPs (run daily)
DELETE FROM otps WHERE expires_in < NOW();

-- Archive old messages (run monthly)
-- Move messages older than 6 months to archive table

-- Clean up orphaned images (run weekly)
-- Find and remove images not referenced in tables
```

### Backups
- Supabase Pro plan includes automatic daily backups
- Can also export data manually via Dashboard

---

## 📞 Support

For issues with:
- **Database schema:** Check this guide first
- **Supabase platform:** https://supabase.com/docs
- **App integration:** Check Flutter app code

---

## ✅ Setup Checklist

- [ ] Supabase project created
- [ ] Environment variables set
- [ ] Database schema executed successfully
- [ ] All 19 tables created
- [ ] All indexes created
- [ ] All triggers created
- [ ] RLS policies enabled
- [ ] 5 storage buckets created
- [ ] Storage RLS policies set
- [ ] Edge functions updated with new table names
- [ ] Test user registration works
- [ ] Test login works
- [ ] Test data queries work

---

**Your database is now fully set up and ready for the Room Finder app! 🎉**
