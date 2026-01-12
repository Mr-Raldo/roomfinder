-- =====================================================
-- ROOM FINDER - COMPLETE DATABASE SCHEMA
-- =====================================================
-- This schema includes all tables, storage buckets,
-- indexes, triggers, and RLS policies
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. USER PROFILES TABLE
-- =====================================================
-- Main user table for all account types
CREATE TABLE rf_user_profile (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  pin TEXT NOT NULL, -- AES encrypted 4-digit PIN
  account_type TEXT NOT NULL CHECK (account_type IN ('Student', 'Landlord', 'Administrator')),

  -- Profile details
  profile_picture_url TEXT,
  date_of_birth DATE,
  gender TEXT CHECK (gender IN ('Male', 'Female', 'Other')),
  national_id TEXT,

  -- Student-specific fields
  student_id TEXT,
  institution TEXT,
  year_of_study INTEGER,

  -- Contact information
  emergency_contact_name TEXT,
  emergency_contact_phone TEXT,

  -- Account status
  is_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  is_suspended BOOLEAN DEFAULT FALSE,

  -- Notification settings
  push_token TEXT,
  email_notifications BOOLEAN DEFAULT TRUE,
  sms_notifications BOOLEAN DEFAULT TRUE,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  last_login TIMESTAMP
);

-- =====================================================
-- 2. OTP TABLE (for verification)
-- =====================================================
CREATE TABLE otps (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone TEXT NOT NULL,
  otp TEXT NOT NULL,
  expires_in TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  used BOOLEAN DEFAULT FALSE
);

-- =====================================================
-- 3. HOUSES/PROPERTIES TABLE
-- =====================================================
CREATE TABLE houses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  landlord_id UUID NOT NULL REFERENCES rf_user_profile(id) ON DELETE CASCADE,

  -- Basic information
  title TEXT NOT NULL,
  description TEXT,
  house_type TEXT CHECK (house_type IN ('Apartment', 'Cottage', 'Hostel', 'Shared House', 'Studio', 'Villa', 'Other')),

  -- Location details (GPS + Address)
  -- GPS Coordinates (from device location picker)
  latitude DECIMAL(10, 8) NOT NULL, -- e.g., -17.8292
  longitude DECIMAL(11, 8) NOT NULL, -- e.g., 31.0522
  gps_accuracy DECIMAL(10, 2), -- Accuracy in meters
  location_verified BOOLEAN DEFAULT FALSE, -- Verified by admin/system

  -- Full address components
  street_address TEXT NOT NULL, -- e.g., "123 Main Street"
  building_name TEXT, -- e.g., "Sunrise Apartments"
  suburb TEXT, -- e.g., "Avondale"
  city TEXT NOT NULL, -- e.g., "Harare"
  province TEXT, -- e.g., "Harare Province"
  postal_code TEXT, -- e.g., "263"
  country TEXT DEFAULT 'Zimbabwe',

  -- Additional location info
  landmarks_nearby TEXT, -- e.g., "Near UZ Main Campus, 500m from OK Supermarket"
  directions TEXT, -- Additional directions for finding the place
  google_maps_url TEXT, -- Link to Google Maps location

  -- Property features
  total_rooms INTEGER NOT NULL DEFAULT 1,
  total_bathrooms INTEGER,
  has_parking BOOLEAN DEFAULT FALSE,
  parking_spaces INTEGER,
  has_garden BOOLEAN DEFAULT FALSE,
  is_furnished BOOLEAN DEFAULT FALSE,

  -- Utilities & Amenities
  has_wifi BOOLEAN DEFAULT FALSE,
  wifi_speed TEXT, -- e.g., "20 Mbps", "100 Mbps"
  has_municipal_water BOOLEAN DEFAULT TRUE,
  has_borehole_water BOOLEAN DEFAULT FALSE,
  has_electricity BOOLEAN DEFAULT TRUE,
  has_backup_power BOOLEAN DEFAULT FALSE, -- Generator/Solar
  has_security BOOLEAN DEFAULT FALSE,
  security_type TEXT, -- e.g., "24/7 Guards", "CCTV", "Alarm"

  -- Rules & Policies
  has_curfew BOOLEAN DEFAULT FALSE,
  curfew_time TIME, -- e.g., "22:00:00"
  pets_allowed BOOLEAN DEFAULT FALSE,
  smoking_allowed BOOLEAN DEFAULT FALSE,
  visitors_allowed BOOLEAN DEFAULT TRUE,

  -- Images
  cover_image_url TEXT,

  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  is_verified BOOLEAN DEFAULT FALSE, -- Admin verification

  -- Stats (updated via triggers)
  total_views INTEGER DEFAULT 0,
  total_bookings INTEGER DEFAULT 0,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 4. HOUSE IMAGES TABLE
-- =====================================================
CREATE TABLE house_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  house_id UUID NOT NULL REFERENCES houses(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  image_type TEXT CHECK (image_type IN ('exterior', 'interior', 'room', 'bathroom', 'kitchen', 'garden', 'other')),
  caption TEXT,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 5. ROOMS TABLE
-- =====================================================
CREATE TABLE rooms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  house_id UUID NOT NULL REFERENCES houses(id) ON DELETE CASCADE,

  -- Basic information
  room_number TEXT NOT NULL, -- e.g., "Room 1", "A1", "101"
  title TEXT NOT NULL,
  description TEXT,
  room_type TEXT CHECK (room_type IN ('Single', 'Shared', 'Studio', 'Ensuite', 'Master Bedroom', 'Other')),

  -- Capacity
  max_occupants INTEGER NOT NULL DEFAULT 1,
  current_occupants INTEGER DEFAULT 0,

  -- Size
  size_sqm DECIMAL(10, 2), -- Size in square meters

  -- Room features
  has_own_bathroom BOOLEAN DEFAULT FALSE,
  has_balcony BOOLEAN DEFAULT FALSE,
  has_wardrobe BOOLEAN DEFAULT FALSE,
  has_desk BOOLEAN DEFAULT FALSE,
  has_ac BOOLEAN DEFAULT FALSE,
  is_furnished BOOLEAN DEFAULT FALSE,

  -- Bed configuration
  bed_type TEXT, -- e.g., "Single Bed", "Double Bed", "Bunk Bed"
  number_of_beds INTEGER DEFAULT 1,

  -- Pricing
  price_per_month DECIMAL(10, 2) NOT NULL,
  deposit_amount DECIMAL(10, 2),
  utilities_included BOOLEAN DEFAULT FALSE,
  utilities_cost DECIMAL(10, 2), -- If not included

  -- Availability
  status TEXT NOT NULL DEFAULT 'vacant' CHECK (status IN ('vacant', 'occupied', 'reserved', 'maintenance')),
  available_from DATE,

  -- Images
  cover_image_url TEXT,

  -- Stats
  total_views INTEGER DEFAULT 0,
  total_bookings INTEGER DEFAULT 0,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 6. ROOM IMAGES TABLE
-- =====================================================
CREATE TABLE room_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  caption TEXT,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 7. ROOM SPECIFICATIONS TABLE (Additional amenities)
-- =====================================================
CREATE TABLE room_specifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  specification_key TEXT NOT NULL, -- e.g., "wifi_speed", "water_pressure", "floor_level"
  specification_value TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(room_id, specification_key)
);

-- =====================================================
-- 8. BOOKINGS TABLE
-- =====================================================
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES rf_user_profile(id) ON DELETE CASCADE,

  -- Booking details
  booking_status TEXT NOT NULL DEFAULT 'pending' CHECK (booking_status IN ('pending', 'approved', 'rejected', 'cancelled', 'expired')),

  -- Dates
  move_in_date DATE NOT NULL,
  move_out_date DATE,
  booking_date TIMESTAMP DEFAULT NOW(),

  -- Pricing at time of booking
  monthly_rent DECIMAL(10, 2) NOT NULL,
  deposit_paid DECIMAL(10, 2),
  total_amount DECIMAL(10, 2),

  -- Payment status
  payment_status TEXT DEFAULT 'unpaid' CHECK (payment_status IN ('unpaid', 'partial', 'paid')),

  -- Additional info
  number_of_occupants INTEGER DEFAULT 1,
  special_requests TEXT,

  -- Landlord response
  landlord_response TEXT,
  responded_at TIMESTAMP,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 9. OCCUPANCY TABLE (Current tenants)
-- =====================================================
CREATE TABLE occupancies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES rf_user_profile(id) ON DELETE CASCADE,
  booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,

  -- Occupancy details
  move_in_date DATE NOT NULL,
  move_out_date DATE,

  -- Lease information
  lease_start_date DATE NOT NULL,
  lease_end_date DATE,
  monthly_rent DECIMAL(10, 2) NOT NULL,
  deposit_paid DECIMAL(10, 2),

  -- Payment tracking
  rent_due_day INTEGER DEFAULT 1, -- Day of month rent is due
  last_payment_date DATE,
  next_payment_due DATE,

  -- Status
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'notice_given', 'expired', 'terminated')),

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 10. CHAT CONVERSATIONS TABLE
-- =====================================================
CREATE TABLE chat_conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Participants
  student_id UUID NOT NULL REFERENCES rf_user_profile(id) ON DELETE CASCADE,
  landlord_id UUID NOT NULL REFERENCES rf_user_profile(id) ON DELETE CASCADE,

  -- Related to a specific room/house (optional)
  room_id UUID REFERENCES rooms(id) ON DELETE SET NULL,
  house_id UUID REFERENCES houses(id) ON DELETE SET NULL,

  -- Status
  is_active BOOLEAN DEFAULT TRUE,

  -- Last message info (for list display)
  last_message_text TEXT,
  last_message_at TIMESTAMP,
  last_message_sender_id UUID REFERENCES rf_user_profile(id),

  -- Unread counts
  student_unread_count INTEGER DEFAULT 0,
  landlord_unread_count INTEGER DEFAULT 0,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  -- Ensure unique conversation between student and landlord
  UNIQUE(student_id, landlord_id)
);

-- =====================================================
-- 11. CHAT MESSAGES TABLE
-- =====================================================
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID NOT NULL REFERENCES chat_conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES rf_user_profile(id) ON DELETE CASCADE,

  -- Message content
  message_text TEXT,
  message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file', 'location', 'booking_request')),

  -- For images/files
  attachment_url TEXT,
  attachment_name TEXT,

  -- For booking requests
  related_booking_id UUID REFERENCES bookings(id),

  -- Status
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP,
  is_deleted BOOLEAN DEFAULT FALSE,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 12. NOTIFICATIONS TABLE
-- =====================================================
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES rf_user_profile(id) ON DELETE CASCADE,

  -- Notification details
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  notification_type TEXT NOT NULL CHECK (notification_type IN (
    'booking_request', 'booking_approved', 'booking_rejected',
    'new_message', 'payment_due', 'payment_received',
    'broadcast', 'room_available', 'maintenance', 'other'
  )),

  -- Related entities (optional)
  related_booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
  related_room_id UUID REFERENCES rooms(id) ON DELETE SET NULL,
  related_house_id UUID REFERENCES houses(id) ON DELETE SET NULL,
  related_conversation_id UUID REFERENCES chat_conversations(id) ON DELETE SET NULL,

  -- Deep link/action
  action_url TEXT, -- For navigation in app

  -- Status
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 13. BROADCAST NOTICES TABLE (From landlords/admins)
-- =====================================================
CREATE TABLE broadcast_notices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID NOT NULL REFERENCES rf_user_profile(id) ON DELETE CASCADE,

  -- Broadcast details
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  notice_type TEXT CHECK (notice_type IN ('room_available', 'maintenance', 'general', 'urgent')),

  -- Targeting
  target_audience TEXT DEFAULT 'all' CHECK (target_audience IN ('all', 'students', 'specific_house', 'specific_room')),
  target_house_id UUID REFERENCES houses(id) ON DELETE CASCADE,
  target_room_id UUID REFERENCES rooms(id) ON DELETE CASCADE,

  -- Attachments
  image_url TEXT,

  -- Visibility
  is_active BOOLEAN DEFAULT TRUE,
  expires_at TIMESTAMP,

  -- Stats
  total_views INTEGER DEFAULT 0,
  total_recipients INTEGER DEFAULT 0,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 14. BROADCAST RECIPIENTS TABLE (Track who received)
-- =====================================================
CREATE TABLE broadcast_recipients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  broadcast_id UUID NOT NULL REFERENCES broadcast_notices(id) ON DELETE CASCADE,
  recipient_id UUID NOT NULL REFERENCES rf_user_profile(id) ON DELETE CASCADE,

  -- Status
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP,

  created_at TIMESTAMP DEFAULT NOW(),

  UNIQUE(broadcast_id, recipient_id)
);

-- =====================================================
-- 15. REVIEWS TABLE (Students review rooms/landlords)
-- =====================================================
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES rf_user_profile(id) ON DELETE CASCADE,
  landlord_id UUID NOT NULL REFERENCES rf_user_profile(id) ON DELETE CASCADE,

  -- Review content
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  review_text TEXT,

  -- Category ratings
  cleanliness_rating INTEGER CHECK (cleanliness_rating >= 1 AND cleanliness_rating <= 5),
  communication_rating INTEGER CHECK (communication_rating >= 1 AND communication_rating <= 5),
  value_rating INTEGER CHECK (value_rating >= 1 AND value_rating <= 5),
  location_rating INTEGER CHECK (location_rating >= 1 AND location_rating <= 5),

  -- Status
  is_verified BOOLEAN DEFAULT FALSE, -- Only from actual tenants
  is_flagged BOOLEAN DEFAULT FALSE,

  -- Landlord response
  landlord_response TEXT,
  responded_at TIMESTAMP,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  -- One review per student per room
  UNIQUE(room_id, student_id)
);

-- =====================================================
-- 16. FAVORITES TABLE (Students save rooms)
-- =====================================================
CREATE TABLE favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID NOT NULL REFERENCES rf_user_profile(id) ON DELETE CASCADE,
  room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,

  created_at TIMESTAMP DEFAULT NOW(),

  UNIQUE(student_id, room_id)
);

-- =====================================================
-- 17. VIEWING HISTORY TABLE (Track room views)
-- =====================================================
CREATE TABLE viewing_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES rf_user_profile(id) ON DELETE CASCADE,
  room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  house_id UUID REFERENCES houses(id) ON DELETE CASCADE,

  -- View details
  view_duration INTEGER, -- Seconds spent viewing

  created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 18. REPORTED CONTENT TABLE
-- =====================================================
CREATE TABLE reported_content (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reporter_id UUID NOT NULL REFERENCES rf_user_profile(id) ON DELETE CASCADE,

  -- What's being reported
  report_type TEXT NOT NULL CHECK (report_type IN ('room', 'house', 'user', 'review', 'message')),
  reported_room_id UUID REFERENCES rooms(id) ON DELETE CASCADE,
  reported_house_id UUID REFERENCES houses(id) ON DELETE CASCADE,
  reported_user_id UUID REFERENCES rf_user_profile(id) ON DELETE CASCADE,
  reported_review_id UUID REFERENCES reviews(id) ON DELETE CASCADE,
  reported_message_id UUID REFERENCES chat_messages(id) ON DELETE CASCADE,

  -- Report details
  reason TEXT NOT NULL,
  description TEXT,

  -- Status
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'investigating', 'resolved', 'dismissed')),
  admin_notes TEXT,
  resolved_by UUID REFERENCES rf_user_profile(id),
  resolved_at TIMESTAMP,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 19. PAYMENT TRANSACTIONS TABLE
-- =====================================================
CREATE TABLE payment_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Transaction parties
  student_id UUID NOT NULL REFERENCES rf_user_profile(id) ON DELETE CASCADE,
  landlord_id UUID NOT NULL REFERENCES rf_user_profile(id) ON DELETE CASCADE,

  -- Related entities
  booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
  occupancy_id UUID REFERENCES occupancies(id) ON DELETE SET NULL,

  -- Payment details
  amount DECIMAL(10, 2) NOT NULL,
  payment_type TEXT NOT NULL CHECK (payment_type IN ('deposit', 'rent', 'utilities', 'penalty', 'refund')),
  payment_method TEXT CHECK (payment_method IN ('cash', 'bank_transfer', 'mobile_money', 'card', 'other')),

  -- Transaction info
  transaction_reference TEXT,
  payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),

  -- Dates
  payment_date DATE,
  period_start DATE, -- For rent payments
  period_end DATE,

  -- Metadata
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- User indexes
CREATE INDEX idx_rf_user_profile_phone ON rf_user_profile(phone);
CREATE INDEX idx_rf_user_profile_email ON rf_user_profile(email);
CREATE INDEX idx_rf_user_profile_account_type ON rf_user_profile(account_type);

-- OTP indexes
CREATE INDEX idx_otps_phone ON otps(phone);
CREATE INDEX idx_otps_expires_in ON otps(expires_in);

-- House indexes
CREATE INDEX idx_houses_landlord_id ON houses(landlord_id);
CREATE INDEX idx_houses_city ON houses(city);
CREATE INDEX idx_houses_suburb ON houses(suburb);
CREATE INDEX idx_houses_is_active ON houses(is_active);
CREATE INDEX idx_houses_location ON houses USING gist (point(longitude, latitude)); -- For location-based searches

-- Room indexes
CREATE INDEX idx_rooms_house_id ON rooms(house_id);
CREATE INDEX idx_rooms_status ON rooms(status);
CREATE INDEX idx_rooms_price ON rooms(price_per_month);

-- Booking indexes
CREATE INDEX idx_bookings_room_id ON bookings(room_id);
CREATE INDEX idx_bookings_student_id ON bookings(student_id);
CREATE INDEX idx_bookings_status ON bookings(booking_status);

-- Occupancy indexes
CREATE INDEX idx_occupancies_room_id ON occupancies(room_id);
CREATE INDEX idx_occupancies_student_id ON occupancies(student_id);
CREATE INDEX idx_occupancies_status ON occupancies(status);

-- Chat indexes
CREATE INDEX idx_chat_conversations_student_id ON chat_conversations(student_id);
CREATE INDEX idx_chat_conversations_landlord_id ON chat_conversations(landlord_id);
CREATE INDEX idx_chat_messages_conversation_id ON chat_messages(conversation_id);
CREATE INDEX idx_chat_messages_sender_id ON chat_messages(sender_id);

-- Notification indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

-- Broadcast indexes
CREATE INDEX idx_broadcast_notices_sender_id ON broadcast_notices(sender_id);
CREATE INDEX idx_broadcast_notices_is_active ON broadcast_notices(is_active);

-- Review indexes
CREATE INDEX idx_reviews_room_id ON reviews(room_id);
CREATE INDEX idx_reviews_student_id ON reviews(student_id);
CREATE INDEX idx_reviews_landlord_id ON reviews(landlord_id);

-- Favorites indexes
CREATE INDEX idx_favorites_student_id ON favorites(student_id);
CREATE INDEX idx_favorites_room_id ON favorites(room_id);

-- Payment indexes
CREATE INDEX idx_payment_transactions_student_id ON payment_transactions(student_id);
CREATE INDEX idx_payment_transactions_landlord_id ON payment_transactions(landlord_id);
CREATE INDEX idx_payment_transactions_booking_id ON payment_transactions(booking_id);

-- =====================================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- =====================================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to all tables with updated_at
CREATE TRIGGER update_rf_user_profile_updated_at BEFORE UPDATE ON rf_user_profile FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_houses_updated_at BEFORE UPDATE ON houses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_rooms_updated_at BEFORE UPDATE ON rooms FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_occupancies_updated_at BEFORE UPDATE ON occupancies FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_chat_conversations_updated_at BEFORE UPDATE ON chat_conversations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_broadcast_notices_updated_at BEFORE UPDATE ON broadcast_notices FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_reported_content_updated_at BEFORE UPDATE ON reported_content FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payment_transactions_updated_at BEFORE UPDATE ON payment_transactions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Update room occupancy count when booking is approved
CREATE OR REPLACE FUNCTION update_room_occupancy()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'active' THEN
    UPDATE rooms
    SET current_occupants = current_occupants + NEW.number_of_occupants,
        status = CASE
          WHEN current_occupants + NEW.number_of_occupants >= max_occupants THEN 'occupied'
          ELSE status
        END
    WHERE id = NEW.room_id;
  END IF;
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_update_room_occupancy
AFTER INSERT OR UPDATE ON occupancies
FOR EACH ROW EXECUTE FUNCTION update_room_occupancy();

-- Update last message in conversation
CREATE OR REPLACE FUNCTION update_conversation_last_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE chat_conversations
  SET
    last_message_text = NEW.message_text,
    last_message_at = NEW.created_at,
    last_message_sender_id = NEW.sender_id,
    updated_at = NOW()
  WHERE id = NEW.conversation_id;

  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_update_conversation_last_message
AFTER INSERT ON chat_messages
FOR EACH ROW EXECUTE FUNCTION update_conversation_last_message();

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on tables
ALTER TABLE rf_user_profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE houses ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE occupancies ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE broadcast_notices ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_transactions ENABLE ROW LEVEL SECURITY;

-- Users can view their own profile
CREATE POLICY "Users can view own profile" ON rf_user_profile
  FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON rf_user_profile
  FOR UPDATE USING (auth.uid() = id);

-- Landlords can view/manage their houses
CREATE POLICY "Landlords can manage own houses" ON houses
  FOR ALL USING (auth.uid() = landlord_id);

-- Everyone can view active houses
CREATE POLICY "Anyone can view active houses" ON houses
  FOR SELECT USING (is_active = true);

-- Landlords can manage rooms in their houses
CREATE POLICY "Landlords can manage own rooms" ON rooms
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM houses
      WHERE houses.id = rooms.house_id
      AND houses.landlord_id = auth.uid()
    )
  );

-- Everyone can view available rooms
CREATE POLICY "Anyone can view available rooms" ON rooms
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM houses
      WHERE houses.id = rooms.house_id
      AND houses.is_active = true
    )
  );

-- Students can create bookings
CREATE POLICY "Students can create bookings" ON bookings
  FOR INSERT WITH CHECK (auth.uid() = student_id);

-- Students can view their bookings
CREATE POLICY "Students can view own bookings" ON bookings
  FOR SELECT USING (auth.uid() = student_id);

-- Landlords can view bookings for their rooms
CREATE POLICY "Landlords can view bookings for own rooms" ON bookings
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM rooms r
      JOIN houses h ON r.house_id = h.id
      WHERE r.id = bookings.room_id
      AND h.landlord_id = auth.uid()
    )
  );

-- Landlords can update booking status
CREATE POLICY "Landlords can update booking status" ON bookings
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM rooms r
      JOIN houses h ON r.house_id = h.id
      WHERE r.id = bookings.room_id
      AND h.landlord_id = auth.uid()
    )
  );

-- Chat policies - users can access conversations they're part of
CREATE POLICY "Users can view own conversations" ON chat_conversations
  FOR SELECT USING (
    auth.uid() = student_id OR auth.uid() = landlord_id
  );

CREATE POLICY "Users can view messages in own conversations" ON chat_messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM chat_conversations
      WHERE chat_conversations.id = chat_messages.conversation_id
      AND (chat_conversations.student_id = auth.uid() OR chat_conversations.landlord_id = auth.uid())
    )
  );

CREATE POLICY "Users can send messages in own conversations" ON chat_messages
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM chat_conversations
      WHERE chat_conversations.id = chat_messages.conversation_id
      AND (chat_conversations.student_id = auth.uid() OR chat_conversations.landlord_id = auth.uid())
    )
    AND sender_id = auth.uid()
  );

-- Notifications - users can view their own
CREATE POLICY "Users can view own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- Favorites - students can manage their own
CREATE POLICY "Students can manage own favorites" ON favorites
  FOR ALL USING (auth.uid() = student_id);

-- Reviews - students can create, everyone can read
CREATE POLICY "Students can create reviews" ON reviews
  FOR INSERT WITH CHECK (auth.uid() = student_id);

CREATE POLICY "Everyone can read reviews" ON reviews
  FOR SELECT USING (true);

CREATE POLICY "Students can update own reviews" ON reviews
  FOR UPDATE USING (auth.uid() = student_id);

-- =====================================================
-- STORAGE BUCKETS FOR IMAGES
-- =====================================================
-- Note: These are created via Supabase Dashboard or API, not SQL
-- But here's the configuration:

/*
Bucket: profile-pictures
- Public: false
- File size limit: 5MB
- Allowed mime types: image/jpeg, image/png, image/webp

Bucket: house-images
- Public: true
- File size limit: 10MB
- Allowed mime types: image/jpeg, image/png, image/webp

Bucket: room-images
- Public: true
- File size limit: 10MB
- Allowed mime types: image/jpeg, image/png, image/webp

Bucket: chat-attachments
- Public: false
- File size limit: 20MB
- Allowed mime types: image/*, application/pdf, application/msword

Bucket: documents
- Public: false
- File size limit: 10MB
- Allowed mime types: application/pdf, image/*
*/

-- =====================================================
-- SEED DATA (Optional - for testing)
-- =====================================================

-- Insert a test administrator (password will be set via auth)
-- INSERT INTO rf_user_profile (phone, email, first_name, last_name, pin, account_type, is_verified)
-- VALUES ('+263771234567', 'admin@roomfinder.com', 'System', 'Administrator', 'encrypted_pin', 'Administrator', true);

-- =====================================================
-- LOCATION HELPER FUNCTIONS
-- =====================================================

-- Calculate distance between two GPS coordinates (in kilometers)
-- Uses Haversine formula
CREATE OR REPLACE FUNCTION calculate_distance(
  lat1 DECIMAL,
  lon1 DECIMAL,
  lat2 DECIMAL,
  lon2 DECIMAL
)
RETURNS DECIMAL AS $$
DECLARE
  R DECIMAL := 6371; -- Earth's radius in kilometers
  dLat DECIMAL;
  dLon DECIMAL;
  a DECIMAL;
  c DECIMAL;
BEGIN
  dLat := radians(lat2 - lat1);
  dLon := radians(lon2 - lon1);

  a := sin(dLat/2) * sin(dLat/2) +
       cos(radians(lat1)) * cos(radians(lat2)) *
       sin(dLon/2) * sin(dLon/2);

  c := 2 * atan2(sqrt(a), sqrt(1-a));

  RETURN R * c;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Find houses within radius (in kilometers)
CREATE OR REPLACE FUNCTION find_houses_nearby(
  user_lat DECIMAL,
  user_lon DECIMAL,
  radius_km DECIMAL DEFAULT 5
)
RETURNS TABLE (
  house_id UUID,
  distance_km DECIMAL,
  title TEXT,
  street_address TEXT,
  suburb TEXT,
  city TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    h.id,
    calculate_distance(user_lat, user_lon, h.latitude, h.longitude) as distance,
    h.title,
    h.street_address,
    h.suburb,
    h.city
  FROM houses h
  WHERE h.is_active = true
  AND calculate_distance(user_lat, user_lon, h.latitude, h.longitude) <= radius_km
  ORDER BY distance;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- HELPFUL VIEWS
-- =====================================================

-- View for available rooms with house details (including location)
CREATE VIEW available_rooms_view AS
SELECT
  r.*,
  h.title as house_title,
  h.street_address,
  h.building_name,
  h.suburb,
  h.city,
  h.province,
  h.latitude,
  h.longitude,
  h.landmarks_nearby,
  h.google_maps_url,
  h.has_wifi,
  h.has_municipal_water,
  h.has_borehole_water,
  h.has_parking,
  h.has_security,
  h.has_curfew,
  h.curfew_time,
  h.landlord_id,
  u.first_name as landlord_first_name,
  u.last_name as landlord_last_name,
  u.phone as landlord_phone,
  (SELECT AVG(rating) FROM reviews WHERE reviews.room_id = r.id) as average_rating,
  (SELECT COUNT(*) FROM reviews WHERE reviews.room_id = r.id) as total_reviews
FROM rooms r
JOIN houses h ON r.house_id = h.id
JOIN rf_user_profile u ON h.landlord_id = u.id
WHERE r.status = 'vacant'
AND h.is_active = true;

-- View for landlord dashboard stats
CREATE VIEW landlord_stats_view AS
SELECT
  h.landlord_id,
  COUNT(DISTINCT h.id) as total_houses,
  COUNT(DISTINCT r.id) as total_rooms,
  COUNT(DISTINCT CASE WHEN r.status = 'vacant' THEN r.id END) as vacant_rooms,
  COUNT(DISTINCT CASE WHEN r.status = 'occupied' THEN r.id END) as occupied_rooms,
  COUNT(DISTINCT b.id) as total_bookings,
  COUNT(DISTINCT CASE WHEN b.booking_status = 'pending' THEN b.id END) as pending_bookings,
  COALESCE(SUM(CASE WHEN o.status = 'active' THEN o.monthly_rent END), 0) as monthly_income
FROM rf_user_profile u
LEFT JOIN houses h ON u.id = h.landlord_id
LEFT JOIN rooms r ON h.id = r.house_id
LEFT JOIN bookings b ON r.id = b.room_id
LEFT JOIN occupancies o ON r.id = o.room_id AND o.status = 'active'
WHERE u.account_type = 'Landlord'
GROUP BY h.landlord_id;

-- =====================================================
-- END OF SCHEMA
-- =====================================================

-- Grant necessary permissions (adjust as needed)
-- GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
-- GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
