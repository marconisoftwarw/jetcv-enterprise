# Configuration Guide

## Environment Setup

### 1. Supabase Configuration

The app is pre-configured to use the development Supabase instance. To use your own:

1. **Create a Supabase project** at [supabase.com](https://supabase.com)
2. **Update the configuration** in `lib/config/app_config.dart`:

```dart
// Replace these values with your own
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 2. Environment Variables

You can configure the app using build-time flags:

```bash
# Development
flutter run --dart-define=ENVIRONMENT=development

# Production
flutter run --dart-define=ENVIRONMENT=production
```

### 3. Google OAuth Setup

To enable Google Sign-In:

1. **Create a Google Cloud Project**
2. **Enable Google Sign-In API**
3. **Configure OAuth consent screen**
4. **Add your app's SHA-1 fingerprint** (Android)
5. **Update the redirect URL** in Supabase Auth settings

### 4. Database Setup

The app expects the following Supabase tables to exist:

```sql
-- Users table
CREATE TABLE public.user (
  idUser uuid NOT NULL,
  firstName text,
  lastName text,
  email text,
  phone text,
  dateOfBirth date,
  address text,
  city text,
  state text,
  postalCode text,
  countryCode text,
  profilePicture text,
  gender text,
  createdAt timestamp with time zone NOT NULL DEFAULT now(),
  updatedAt timestamp with time zone,
  fullName text,
  type text,
  hasWallet boolean NOT NULL DEFAULT false,
  idWallet uuid,
  hasCv boolean NOT NULL DEFAULT false,
  idCv uuid,
  idUserHash text NOT NULL,
  profileCompleted boolean NOT NULL DEFAULT false,
  kycCompleted boolean,
  kycPassed boolean,
  languageCode text,
  CONSTRAINT user_pkey PRIMARY KEY (idUser)
);

-- Legal Entity table
CREATE TABLE public.legal_entity (
  idLegalEntity uuid NOT NULL DEFAULT gen_random_uuid(),
  idLegalEntityHash text NOT NULL,
  legalName text NOT NULL,
  identifierCode text NOT NULL,
  operationalAddress text NOT NULL,
  headquartersAddress text NOT NULL,
  legalRepresentative text NOT NULL,
  email text NOT NULL,
  phone text NOT NULL,
  pec text,
  website text,
  createdAt timestamp with time zone NOT NULL DEFAULT now(),
  updatedAt timestamp with time zone,
  statusUpdatedAt timestamp with time zone,
  statusUpdatedByIdUser uuid,
  requestingIdUser uuid NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  logoPictureUrl text,
  companyPictureUrl text,
  address text,
  city text,
  state text,
  postalcode text,
  countrycode text,
  CONSTRAINT legal_entity_pkey PRIMARY KEY (idLegalEntity)
);

-- Country table
CREATE TABLE public.country (
  code text NOT NULL,
  name text NOT NULL,
  createdAt timestamp with time zone NOT NULL DEFAULT now(),
  emoji text,
  CONSTRAINT country_pkey PRIMARY KEY (code)
);
```

### 5. Storage Buckets

Create the following storage buckets in Supabase:

- `profile-pictures`: For user profile images
- `company-pictures`: For company logos and images

### 6. Row Level Security (RLS)

Enable RLS and create policies for your tables:

```sql
-- Enable RLS
ALTER TABLE public.user ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_entity ENABLE ROW LEVEL SECURITY;

-- User policies
CREATE POLICY "Users can view own profile" ON public.user
  FOR SELECT USING (auth.uid() = idUser);

CREATE POLICY "Users can update own profile" ON public.user
  FOR UPDATE USING (auth.uid() = idUser);

-- Legal entity policies
CREATE POLICY "Anyone can view legal entities" ON public.legal_entity
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create legal entities" ON public.legal_entity
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can update legal entities" ON public.legal_entity
  FOR UPDATE USING (auth.uid() IN (
    SELECT idUser FROM public.user WHERE type = 'admin'
  ));
```

## Customization

### 1. App Theme

Update colors and styling in `lib/config/app_config.dart`:

```dart
// Brand colors
static const int primaryColorValue = 0xFF2563EB;    // Blue
static const int secondaryColorValue = 0xFF64748B;  // Gray

// UI constants
static const double defaultPadding = 16.0;
static const double defaultRadius = 8.0;
```

### 2. Feature Flags

Control app features through configuration:

```dart
// Authentication options
static const bool enableGoogleSignIn = true;
static const bool enableEmailSignIn = true;

// Debug mode
static const bool enableDebugMode = true;
```

### 3. Validation Rules

Customize form validation:

```dart
// Password requirements
static const int minPasswordLength = 8;

// Field length limits
static const int maxNameLength = 100;
static const int maxEmailLength = 255;
```

## Build Configuration

### 1. Android

Update `android/app/build.gradle.kts`:

```kotlin
android {
    defaultConfig {
        applicationId "com.jetcv.enterprise"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

### 2. iOS

Update `ios/Runner/Info.plist`:

```xml
<key>CFBundleDisplayName</key>
<string>JetCV Enterprise</string>
<key>CFBundleIdentifier</key>
<string>com.jetcv.enterprise</string>
```

### 3. Web

Update `web/index.html`:

```html
<title>JetCV Enterprise</title>
<meta name="description" content="Professional certification platform">
```

## Testing Configuration

### 1. Unit Tests

Create test files in the `test/` directory:

```dart
// test/services/supabase_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:jetcv_enterprise/services/supabase_service.dart';

void main() {
  group('SupabaseService', () {
    test('should initialize correctly', () async {
      // Test implementation
    });
  });
}
```

### 2. Integration Tests

Create integration tests in `integration_test/`:

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Test', () {
    testWidgets('should show login screen', (tester) async {
      // Test implementation
    });
  });
}
```

## Deployment Configuration

### 1. Production Build

```bash
# Android
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### 2. Environment Variables

Set production environment variables:

```bash
export SUPABASE_URL="https://your-production-project.supabase.co"
export SUPABASE_ANON_KEY="your-production-anon-key"
```

### 3. CI/CD

Example GitHub Actions workflow:

```yaml
name: Build and Deploy
on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.0'
      - run: flutter pub get
      - run: flutter test
      - run: flutter build web --release
```

## Troubleshooting

### Common Issues

1. **Supabase connection failed**
   - Check URL and API key
   - Verify project is active
   - Check network connectivity

2. **Google Sign-In not working**
   - Verify OAuth configuration
   - Check SHA-1 fingerprint (Android)
   - Ensure redirect URLs are correct

3. **Build errors**
   - Run `flutter clean`
   - Delete `build/` directory
   - Run `flutter pub get`

4. **Database errors**
   - Check table structure
   - Verify RLS policies
   - Check user permissions

### Support

For additional help:
- Check the [README.md](README.md) file
- Review Flutter documentation
- Check Supabase documentation
- Contact support@jetcv.com
