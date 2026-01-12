# Room Finder - Phone Authentication Setup

This is a Flutter mobile application for finding rooms, with phone-based authentication similar to the Geza app.

## Project Structure

```
roomfinder/
├── app/                          # Flutter mobile application
│   ├── lib/
│   │   ├── screens/
│   │   │   └── auth/
│   │   │       └── views/
│   │   │           └── screens/
│   │   │               ├── phone_login.dart              # Login screen
│   │   │               ├── phone_signup.dart             # Signup/registration screen
│   │   │               ├── phone_otp_verification.dart   # OTP verification
│   │   │               ├── phone_pin_setup.dart          # PIN creation
│   │   │               ├── phone_forgot_pin.dart         # Forgot PIN initiation
│   │   │               └── forgot_pin_otp_screen.dart    # PIN reset with OTP
│   │   ├── controllers/
│   │   │   └── auth_controller.dart  # Auth state management (no logic yet)
│   │   ├── routes/
│   │   │   └── app_routes.dart       # Navigation routes
│   │   ├── constants/
│   │   │   └── theme.dart            # App theme (blue/teal color scheme)
│   │   └── main.dart                 # App entry point
│   ├── assets/
│   │   └── images/
│   └── pubspec.yaml
└── README.md                     # This file
```

## What's Been Created

### ✅ Completed Setup

1. **Flutter App Structure**
   - Clean project structure with proper folder organization
   - GetX state management setup
   - Navigation routing configured

2. **Authentication Screens (UI Only - No Logic)**
   - **Login Screen**: Phone number + 4-digit PIN
   - **Signup Screen**: First name, last name, phone, account type (Student/Landlord/Administrator)
   - **OTP Verification**: 6-digit OTP input with resend functionality
   - **PIN Setup**: Create and confirm 4-digit PIN
   - **Forgot PIN**: Initiate PIN reset flow
   - **PIN Reset OTP**: Verify OTP and set new PIN

3. **Auth Controller**
   - Observable state variables for phone, PIN, OTP, user details
   - Placeholder methods for all auth operations
   - No business logic implemented yet

4. **Navigation & Routes**
   - All auth routes configured
   - GetX navigation setup
   - Screen transitions configured

5. **Theme & Design**
   - Blue/Teal color scheme (room-themed)
   - Consistent UI design across all screens
   - Material Design 3 components

## User Account Types

The app supports three account types:
- **Student**: Users looking for rooms
- **Landlord**: Users listing rooms
- **Administrator**: System administrators

## Next Steps

### 1. Backend Setup (Supabase)

You'll need to set up:
- New Supabase project
- Database tables:
  ```sql
  -- OTP storage
  CREATE TABLE otps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone TEXT NOT NULL,
    otp TEXT NOT NULL,
    expires_in TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
  );

  -- User profiles
  CREATE TABLE rf_user_profile (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone TEXT UNIQUE NOT NULL,
    first_name TEXT,
    last_name TEXT,
    pin TEXT NOT NULL,  -- AES encrypted
    account_type TEXT CHECK (account_type IN ('Student', 'Landlord', 'Administrator')),
    push_token TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
  );
  ```

### 2. Edge Functions

Create these Supabase Edge Functions (you can copy from Geza app):

- **send-otp-notifytext**: Generate and send OTP via NotifyText SMS API
- **verify-otp**: Validate OTP code
- **register-room-finder-user**: Create user account with encrypted PIN

### 3. Implement Business Logic

In `lib/controllers/auth_controller.dart`, implement:
- `sendOtp()`: Call send-otp edge function
- `verifyOtp()`: Call verify-otp edge function
- `register()`: Call registration edge function
- `login()`: Authenticate with phone + PIN
- `updatePin()`: Update user PIN
- PIN validation and phone number formatting

### 4. Environment Configuration

Create `.env` file in `app/` directory:
```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

Add to `pubspec.yaml` dependencies:
```yaml
supabase_flutter: ^2.6.0
flutter_dotenv: ^5.1.0
encrypt: ^5.0.3  # For PIN encryption
```

### 5. Home Screens

Create home screens for each user type:
- Student Home: Search and browse rooms
- Landlord Home: Manage room listings
- Administrator Home: System management

Update routes in `lib/routes/app_routes.dart` to include these screens.

### 6. Additional Features

- Room listing functionality
- Search and filters
- Booking/application system
- User profiles
- Messaging between students and landlords

## Running the App

```bash
cd roomfinder/app
flutter pub get
flutter run
```

## Authentication Flow

### Registration Flow:
1. User enters details on Signup screen
2. Send OTP to phone via edge function
3. Verify OTP
4. Create and confirm 4-digit PIN
5. Register user via edge function
6. Navigate to respective home screen based on account type

### Login Flow:
1. User enters phone + PIN
2. Validate credentials
3. Sign in with Supabase
4. Navigate to home screen based on account type

### Forgot PIN Flow:
1. Enter phone number
2. Receive OTP
3. Verify OTP
4. Create new PIN
5. Update PIN in database
6. Return to login

## Notes

- All screens are created without business logic - they're UI-only templates
- `print()` statements are placeholders for actual API calls
- Navigation routes are commented out where screens don't exist yet
- The app uses GetX for state management and navigation
- Theme uses blue/teal colors instead of Geza's rose gold theme

## Contact

For questions about implementation, refer to the existing Geza app structure.
