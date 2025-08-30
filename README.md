# JetCV Enterprise - Flutter App

A comprehensive professional certification platform built with Flutter and Supabase, designed for managing legal entities, user authentication, and certification processes.

## Features

### 🔐 Authentication
- **Email/Password Sign Up & Sign In**
- **Google OAuth Integration**
- **Password Reset Functionality**
- **Session Management**

### 🏢 Legal Entity Management
- **Company Registration** (Public & Admin)
- **Legal Entity Approval/Rejection System**
- **Status Management** (Pending, Approved, Rejected)
- **Search and Filtering**
- **Email Invitation System**

### 👥 User Management
- **User Profiles with Personal Information**
- **Profile Completion Tracking**
- **KYC Integration Ready**
- **Role-based Access Control**

### 🎛️ Admin Dashboard
- **Comprehensive Statistics**
- **Legal Entity Management**
- **User Management**
- **Analytics Dashboard**
- **Manual Entity Creation**

### 🌐 Public Interface
- **Landing Page**
- **Company Registration Forms**
- **Feature Showcase**
- **Responsive Design**

## Architecture

### Tech Stack
- **Frontend**: Flutter 3.9+
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **State Management**: Provider
- **UI Components**: Material Design 3
- **Authentication**: Supabase Auth + Google OAuth

### Project Structure
```
lib/
├── config/           # App configuration and constants
├── models/           # Data models and enums
├── providers/        # State management providers
├── screens/          # UI screens
│   ├── admin/        # Admin-specific screens
│   ├── auth/         # Authentication screens
│   ├── home/         # User dashboard screens
│   ├── legal_entity/ # Legal entity screens
│   └── public/       # Public-facing screens
├── services/         # Business logic and API calls
├── utils/            # Utility functions
└── widgets/          # Reusable UI components
```

## Getting Started

### Prerequisites
- Flutter SDK 3.9.0 or higher
- Dart SDK 3.9.0 or higher
- Android Studio / VS Code
- iOS Simulator (for iOS development)
- Android Emulator (for Android development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd jetcv-enterprise
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a Supabase project at [supabase.com](https://supabase.com)
   - Update the configuration in `lib/config/app_config.dart`:
     ```dart
     static const String supabaseUrl = 'YOUR_SUPABASE_URL';
     static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Environment Configuration

The app supports multiple environments through build configurations:

```bash
# Development
flutter run --dart-define=ENVIRONMENT=development

# Production
flutter run --dart-define=ENVIRONMENT=production
```

## Database Schema

The app integrates with the following Supabase tables:

- **users**: User profiles and authentication
- **legal_entity**: Company and business information
- **certification**: Professional certifications
- **certifier**: Certification authorities
- **wallet**: Blockchain wallet integration
- **cv**: Curriculum vitae and professional documents
- **kyc_attempt**: Know Your Customer verification attempts
- **country**: Country codes and information

## Key Features Implementation

### Authentication Flow
1. **Public Home Screen** → User sees landing page
2. **Sign Up/Sign In** → User creates account or signs in
3. **Profile Completion** → User fills personal information
4. **Dashboard Access** → User accesses main application

### Admin Workflow
1. **Admin Login** → Admin authenticates with elevated privileges
2. **Dashboard Overview** → View statistics and recent activity
3. **Legal Entity Management** → Approve/reject company registrations
4. **User Management** → Monitor and manage user accounts

### Legal Entity Registration
1. **Public Registration** → Companies register through public form
2. **Admin Review** → Admins review and approve/reject registrations
3. **Status Updates** → Real-time status tracking
4. **Communication** → Email notifications and invitations

## Customization

### Theme Configuration
Update the app theme in `lib/config/app_config.dart`:

```dart
// Colors
static const int primaryColorValue = 0xFF2563EB;
static const int secondaryColorValue = 0xFF64748B;

// UI Constants
static const double defaultPadding = 16.0;
static const double defaultRadius = 8.0;
```

### Adding New Features
1. **Create Models**: Add new data models in `lib/models/`
2. **Update Services**: Extend Supabase service in `lib/services/`
3. **Add Providers**: Create state management in `lib/providers/`
4. **Build UI**: Create screens in `lib/screens/`

## API Integration

### Supabase Edge Functions
The app is designed to work with existing Supabase edge functions:
- `uploadProfilePicture`: Profile image uploads
- `uploadCompanyPicture`: Company logo and image uploads
- Email services for invitations and notifications

### Custom API Endpoints
Extend the `SupabaseService` class to add new API calls:

```dart
Future<dynamic> customApiCall() async {
  try {
    final response = await _client.functions.invoke('function-name');
    return response.data;
  } catch (e) {
    print('API call failed: $e');
    return null;
  }
}
```

## Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter test integration_test/
```

## Building for Production

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Deployment

### Android
1. Build APK or App Bundle
2. Upload to Google Play Console
3. Configure release channels

### iOS
1. Build iOS app
2. Upload to App Store Connect
3. Submit for review

### Web
1. Build web version
2. Deploy to hosting service (Netlify, Vercel, etc.)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Email: support@jetcv.com
- Documentation: [Link to documentation]
- Issues: [GitHub Issues page]

## Roadmap

### Phase 1 (Current)
- ✅ Basic authentication
- ✅ Legal entity management
- ✅ Admin dashboard
- ✅ Public registration

### Phase 2 (Next)
- 🔄 Advanced user profiles
- 🔄 KYC integration
- 🔄 Certification workflows
- 🔄 Blockchain integration

### Phase 3 (Future)
- 📋 Advanced analytics
- 📋 Multi-language support
- 📋 Mobile app stores
- 📋 Enterprise features

## Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- Material Design team for the design system
- Open source community for various packages

---

**JetCV Enterprise** - Professional certification platform built with Flutter and Supabase.
