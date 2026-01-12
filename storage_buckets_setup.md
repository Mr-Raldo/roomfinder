# Supabase Storage Buckets Setup for Room Finder

## Overview
This document describes the storage buckets needed for the Room Finder application and how to set them up.

## Buckets Required

### 1. `profile-pictures`
**Purpose:** Store user profile pictures

**Configuration:**
```javascript
{
  "name": "profile-pictures",
  "public": false,
  "fileSizeLimit": 5242880, // 5MB
  "allowedMimeTypes": ["image/jpeg", "image/jpg", "image/png", "image/webp"]
}
```

**RLS Policies:**
- Users can upload their own profile pictures
- Users can view any profile picture (for chat/listings)

**Policy SQL:**
```sql
-- Allow users to upload their own profile picture
CREATE POLICY "Users can upload own profile picture"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'profile-pictures' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow users to update their own profile picture
CREATE POLICY "Users can update own profile picture"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'profile-pictures' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow users to delete their own profile picture
CREATE POLICY "Users can delete own profile picture"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'profile-pictures' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow anyone to view profile pictures
CREATE POLICY "Anyone can view profile pictures"
ON storage.objects FOR SELECT
USING (bucket_id = 'profile-pictures');
```

---

### 2. `house-images`
**Purpose:** Store house/property images uploaded by landlords

**Configuration:**
```javascript
{
  "name": "house-images",
  "public": true,
  "fileSizeLimit": 10485760, // 10MB
  "allowedMimeTypes": ["image/jpeg", "image/jpg", "image/png", "image/webp"]
}
```

**RLS Policies:**
```sql
-- Landlords can upload images for their houses
CREATE POLICY "Landlords can upload house images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'house-images' AND
  EXISTS (
    SELECT 1 FROM houses
    WHERE houses.id::text = (storage.foldername(name))[1]
    AND houses.landlord_id = auth.uid()
  )
);

-- Landlords can update their house images
CREATE POLICY "Landlords can update house images"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'house-images' AND
  EXISTS (
    SELECT 1 FROM houses
    WHERE houses.id::text = (storage.foldername(name))[1]
    AND houses.landlord_id = auth.uid()
  )
);

-- Landlords can delete their house images
CREATE POLICY "Landlords can delete house images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'house-images' AND
  EXISTS (
    SELECT 1 FROM houses
    WHERE houses.id::text = (storage.foldername(name))[1]
    AND houses.landlord_id = auth.uid()
  )
);

-- Anyone can view house images (public bucket)
CREATE POLICY "Anyone can view house images"
ON storage.objects FOR SELECT
USING (bucket_id = 'house-images');
```

---

### 3. `room-images`
**Purpose:** Store room images uploaded by landlords

**Configuration:**
```javascript
{
  "name": "room-images",
  "public": true,
  "fileSizeLimit": 10485760, // 10MB
  "allowedMimeTypes": [image/jpeg, image/jpg, image/png, image/webp]
}
```

**RLS Policies:**
```sql
-- Landlords can upload images for rooms in their houses
CREATE POLICY "Landlords can upload room images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'room-images' AND
  EXISTS (
    SELECT 1 FROM rooms r
    JOIN houses h ON r.house_id = h.id
    WHERE r.id::text = (storage.foldername(name))[1]
    AND h.landlord_id = auth.uid()
  )
);

-- Landlords can update room images
CREATE POLICY "Landlords can update room images"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'room-images' AND
  EXISTS (
    SELECT 1 FROM rooms r
    JOIN houses h ON r.house_id = h.id
    WHERE r.id::text = (storage.foldername(name))[1]
    AND h.landlord_id = auth.uid()
  )
);

-- Landlords can delete room images
CREATE POLICY "Landlords can delete room images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'room-images' AND
  EXISTS (
    SELECT 1 FROM rooms r
    JOIN houses h ON r.house_id = h.id
    WHERE r.id::text = (storage.foldername(name))[1]
    AND h.landlord_id = auth.uid()
  )
);

-- Anyone can view room images (public bucket)
CREATE POLICY "Anyone can view room images"
ON storage.objects FOR SELECT
USING (bucket_id = 'room-images');
```

---

### 4. `chat-attachments`
**Purpose:** Store images and files sent in chat conversations

**Configuration:**
```javascript
{
  "name": "chat-attachments",
  "public": false,
  "fileSizeLimit": 20971520, // 20MB
  "allowedMimeTypes": [
    "image/jpeg", "image/jpg", "image/png", "image/webp",
    application/pdf,
    application/msword,
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
  ]
}
```

**RLS Policies:**
```sql
-- Users can upload attachments in their conversations
CREATE POLICY "Users can upload chat attachments"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'chat-attachments' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can view attachments in their conversations
CREATE POLICY "Users can view chat attachments"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'chat-attachments' AND
  (
    auth.uid()::text = (storage.foldername(name))[1] OR
    EXISTS (
      SELECT 1 FROM chat_conversations
      WHERE (student_id = auth.uid() OR landlord_id = auth.uid())
    )
  )
);

-- Users can delete their own attachments
CREATE POLICY "Users can delete own chat attachments"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'chat-attachments' AND
  auth.uid()::text = (storage.foldername(name))[1]
);
```

---

### 5. `documents`
**Purpose:** Store legal documents, contracts, ID documents, etc.

**Configuration:**
```javascript
{
  "name": "documents",
  "public": false,
  "fileSizeLimit": 10485760, // 10MB
  "allowedMimeTypes": [
    application/pdf,
    image/jpeg, image/jpg, image/png"
  ]
}
```

**RLS Policies:**
```sql
-- Users can upload their own documents
CREATE POLICY "Users can upload own documents"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'documents' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can view their own documents
CREATE POLICY "Users can view own documents"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'documents' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Admins can view all documents
CREATE POLICY "Admins can view all documents"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'documents' AND
  EXISTS (
    SELECT 1 FROM rf_user_profile
    WHERE id = auth.uid()
    AND account_type = 'Administrator'
  )
);

-- Users can delete their own documents
CREATE POLICY "Users can delete own documents"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'documents' AND
  auth.uid()::text = (storage.foldername(name))[1]
);
```

---

## Setup Instructions

### Option 1: Using Supabase Dashboard

1. Go to your Supabase project dashboard
2. Navigate to **Storage** in the left sidebar
3. Click **"New Bucket"** for each bucket above
4. Configure with the settings specified
5. Go to **Policies** tab for each bucket and add the RLS policies

### Option 2: Using Supabase CLI

Create a file `setup-storage.sql` and run:

```bash
supabase db reset
```

### Option 3: Using Supabase API

```javascript
// In your edge function or migration script
const { data, error } = await supabase.storage.createBucket('profile-pictures', {
  public: false,
  fileSizeLimit: 5242880,
  allowedMimeTypes: ['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
});
```

---

## File Naming Convention

### Profile Pictures
```
profile-pictures/{user_id}/avatar.{ext}
```

### House Images
```
house-images/{house_id}/{timestamp}_{filename}.{ext}
```

### Room Images
```
room-images/{room_id}/{timestamp}_{filename}.{ext}
```

### Chat Attachments
```
chat-attachments/{sender_id}/{conversation_id}_{timestamp}_{filename}.{ext}
```

### Documents
```
documents/{user_id}/{document_type}_{timestamp}.{ext}
```

---

## Flutter Integration Example

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Upload profile picture
  Future<String> uploadProfilePicture(File file, String userId) async {
    final String fileName = 'avatar.${file.path.split('.').last}';
    final String filePath = '$userId/$fileName';

    await _supabase.storage
        .from('profile-pictures')
        .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

    return _supabase.storage.from('profile-pictures').getPublicUrl(filePath);
  }

  // Upload house image
  Future<String> uploadHouseImage(File file, String houseId) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = '${timestamp}_${file.path.split('/').last}';
    final String filePath = '$houseId/$fileName';

    await _supabase.storage.from('house-images').upload(filePath, file);

    return _supabase.storage.from('house-images').getPublicUrl(filePath);
  }

  // Upload room image
  Future<String> uploadRoomImage(File file, String roomId) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = '${timestamp}_${file.path.split('/').last}';
    final String filePath = '$roomId/$fileName';

    await _supabase.storage.from('room-images').upload(filePath, file);

    return _supabase.storage.from('room-images').getPublicUrl(filePath);
  }

  // Upload chat attachment
  Future<String> uploadChatAttachment(
    File file,
    String senderId,
    String conversationId,
  ) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = '${conversationId}_${timestamp}_${file.path.split('/').last}';
    final String filePath = '$senderId/$fileName';

    await _supabase.storage.from('chat-attachments').upload(filePath, file);

    return _supabase.storage.from('chat-attachments').getPublicUrl(filePath);
  }

  // Delete file
  Future<void> deleteFile(String bucket, String filePath) async {
    await _supabase.storage.from(bucket).remove([filePath]);
  }
}
```

---

## Storage Limits & Quotas

- **Free tier:** 1 GB storage
- **Pro tier:** 100 GB storage
- Maximum file size per upload: 50 MB (configurable per bucket)
- Recommended image sizes:
  - Profile pictures: 500x500 pixels, < 1 MB
  - House images: 1920x1080 pixels, < 2 MB
  - Room images: 1920x1080 pixels, < 2 MB

---

## Image Optimization Tips

1. **Compress images before upload** using packages like `flutter_image_compress`
2. **Generate thumbnails** for faster loading in lists
3. **Use WebP format** for better compression
4. **Implement lazy loading** for image galleries
5. **Cache images** using `cached_network_image` package

---

## Security Best Practices

1. ✅ Always validate file types on the server
2. ✅ Implement file size limits
3. ✅ Use RLS policies to restrict access
4. ✅ Scan uploaded files for malware (optional)
5. ✅ Use signed URLs for private content
6. ✅ Implement rate limiting for uploads
7. ✅ Log all upload/delete operations
8. ✅ Regularly audit storage usage

---

## Troubleshooting

**Issue:** "Permission denied" when uploading
- **Solution:** Check RLS policies and ensure user is authenticated

**Issue:** File size too large
- **Solution:** Compress image before upload or increase bucket limit

**Issue:** Slow uploads
- **Solution:** Use CDN (Supabase provides this by default) and compress images

**Issue:** Storage quota exceeded
- **Solution:** Upgrade plan or implement cleanup policy for old files
