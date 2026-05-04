# Firebase Setup Guide for Flutter Todo App

## 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Create a project"** or add to existing project
3. Name your project (e.g., "Flutter Todo App")
4. Follow the prompts to complete project creation

## 2. Register Your App in Firebase

### For All Platforms:

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Under "Your apps", add platforms based on your needs:
   - **Android**: Download `google-services.json`
   - **iOS**: Download `GoogleService-Info.plist`
   - **Web**: Copy the Firebase config
   - **Windows/macOS**: May need manual setup

### For Android:

1. Download `google-services.json` from Firebase Console
2. Place it in: `android/app/google-services.json`
3. Ensure `android/build.gradle` includes Firebase plugin

### For iOS:

1. Download `GoogleService-Info.plist` from Firebase Console
2. In Xcode, add file to your iOS project
3. Ensure it's added to all targets

## 3. Enable Firebase Services

In Firebase Console:

### Cloud Firestore

1. Go to **Firestore Database**
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development only)
4. Select your region
5. Click **"Enable"**

### Firebase Authentication

1. Go to **Authentication**
2. In **Sign-in method**, enable **"Email/Password"**
3. Click **"Save"**

### Firebase Storage (Optional - for file uploads)

1. Go to **Storage**
2. Click **"Get started"**
3. Accept default rules and click **"Done"**

## 4. Set Up Firestore Security Rules

⚠️ **Important**: Test mode allows anyone to read/write. For production, set proper rules.

Replace the default rules with:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;

      // User's tasks subcollection
      match /tasks/{taskId} {
        allow read, write: if request.auth.uid == userId;
      }
    }
  }
}
```

**To apply:**

1. Go to **Firestore Database** → **Rules**
2. Replace existing content with the rules above
3. Click **"Publish"**

## 5. Test Connection

Run your Flutter app:

```bash
flutter pub get
flutter run
```

The app should now:

- ✅ Initialize Firebase on startup
- ✅ Allow user registration and login
- ✅ Store tasks in Firestore
- ✅ Sync data across devices for logged-in user

## 6. Troubleshooting

### "FirebaseException: [firebase_core/not-initialized]"

- Ensure `Firebase.initializeApp()` is called in `main()` before `runApp()`
- Already done in your code ✅

### "Permission-denied" errors

- Check Firestore security rules (Step 4)
- Ensure user is authenticated before database operations
- Service handles this with `currentUser` checks ✅

### "google-services.json not found"

- For Android: Place file at `android/app/google-services.json`
- Run `flutter clean && flutter pub get && flutter run`

### iOS Build Errors

- Run `cd ios && pod install && cd ..`
- Then `flutter run`

## 7. Data Structure

Your app will create Firestore documents in this structure:

```
users/ (collection)
├── {userId} (document)
│   ├── uid: string
│   ├── email: string
│   ├── name: string
│   ├── createdAt: timestamp
│   ├── updatedAt: timestamp
│   └── tasks/ (subcollection)
│       └── {taskId} (document)
│           ├── id: string
│           ├── title: string
│           ├── description: string
│           ├── isCompleted: boolean
│           ├── createdAt: timestamp
│           └── updatedAt: timestamp
```

## 8. Migration from Hive to Firebase

To migrate existing Hive data to Firebase:

1. Load tasks from Hive
2. Sign in user with Firebase
3. Upload tasks to Firestore:

```dart
final tasks = dataStore.tasks; // From Hive
for (var task in tasks) {
  await firebaseService.addTask(task);
}
```

## 9. Next Steps

- Test authentication (sign up, sign in, sign out)
- Test adding, updating, deleting tasks
- Test real-time sync (open app on two devices)
- Update UI code to use `FirebaseService` instead of `HiveDataStore`
- Implement error handling and loading states

## 10. Production Checklist

Before deploying to production:

- [ ] Switch Firestore from **test mode** to **production rules**
- [ ] Enable Email Verification (Firebase Auth → Settings)
- [ ] Set up password reset email template
- [ ] Enable backup and disaster recovery
- [ ] Review and restrict API keys
- [ ] Test with real user data
- [ ] Monitor Firestore usage and costs
- [ ] Set up automated backups
