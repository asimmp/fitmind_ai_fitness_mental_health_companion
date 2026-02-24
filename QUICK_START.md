# Quick Start Guide - Profile Image Upload

## 🎬 How It Works (User Perspective)

```
User opens Profile Screen
            ↓
User sees profile avatar with camera icon
            ↓
User taps on avatar
            ↓
Image gallery opens
            ↓
User selects image
            ↓
Loading spinner appears
            ↓
Image uploads to Cloudinary
            ↓
URL saved to Firebase
            ↓
Success message appears
            ↓
Avatar updates with new image
```

---

## 🔄 Technical Flow

```
profile_screen.dart (_pickAndUploadImage)
            ↓
ImagePicker (gallery)
            ↓
CloudinaryService.uploadProfileImage()
            ↓
┌─────────────────────────────┐
│ Cloudinary Upload           │
│ Cloud: dfslzepiy            │
│ Preset: fitmind_images      │
│ Folder: profile_images/     │
└─────────────────────────────┘
            ↓
Get secure URL
            ↓
┌─────────────────────────────┐
│ Firebase Update             │
│ Collection: users           │
│ Field: profileImageUrl      │
│ Field: profileImageUpdatedAt│
└─────────────────────────────┘
            ↓
UI Refresh & Success Message
```

---

## 💾 Data Storage

### Cloudinary Storage
```
https://res.cloudinary.com/dfslzepiy/
  image/upload/v1708777800/
    profile_images/
      img_name_abc123.jpg
```

### Firebase Storage (users collection)
```json
{
  "userId": "user123",
  "name": "John Doe",
  "email": "john@example.com",
  "profileImageUrl": "https://res.cloudinary.com/dfslzepiy/image/upload/v1708777800/profile_images/img_name_abc123.jpg",
  "profileImageUpdatedAt": "2026-02-24T12:34:56Z"
}
```

---

## 📦 Package Integration

### Dependencies (Already in pubspec.yaml)
```yaml
dependencies:
  cloudinary_public: ^0.23.1
  firebase_core: ^4.4.0
  firebase_auth: ^6.1.4
  cloud_firestore: ^6.1.2
  image_picker: ^1.2.1
```

### Services
```
lib/
├── cloudinary_service.dart  ← Handles Cloudinary & Firebase
├── profile_screen.dart       ← UI for profile image upload
```

---

## 🛠️ Configuration

| Setting | Value |
|---------|-------|
| Cloud Name | `dfslzepiy` |
| Upload Preset | `fitmind_images` |
| Image Folder | `profile_images` |
| Image Quality | 85% |
| Max Size | 500x500px |
| Firebase Collection | `users` |
| Field Name | `profileImageUrl` |

---

## ✨ Features Summary

| Feature | Status | Notes |
|---------|--------|-------|
| Upload from gallery | ✅ | Both web & mobile |
| Auto compression | ✅ | 85% quality, 500x500px |
| Firebase integration | ✅ | Stores URL in users collection |
| Error handling | ✅ | Firebase & upload errors |
| Loading state | ✅ | Shows spinner during upload |
| Success feedback | ✅ | SnackBar message |
| Image caching | ✅ | Cloudinary CDN |
| Web support | ✅ | Full support |
| Mobile support | ✅ | iOS & Android |

---

## 🔐 Security Checklist

- ✅ Upload preset configured in Cloudinary dashboard
- ✅ Firebase auth required (only authenticated users can upload)
- ✅ Images organized in separate folder
- ✅ HTTPS/secure URLs only
- ✅ No sensitive data in image metadata
- ✅ No API keys exposed in code

---

## 🧪 Quick Test

1. **Open Profile Screen**
2. **Tap Profile Avatar** → Should see gallery
3. **Select Image** → Should show loading
4. **Wait for Upload** → Should show success
5. **Refresh Page** → Image should persist
6. **Check Firebase** → URL should be in `profileImageUrl` field

---

## 📞 Troubleshooting

### Issue: Image doesn't show after upload
**Solution**: 
- Check Firebase `profileImageUrl` field has value
- Verify Cloudinary URL is accessible
- Check internet connection

### Issue: Upload fails with error
**Solution**:
- Ensure Cloudinary credentials are correct
- Check Firebase authentication is working
- Verify image file is valid (JPG/PNG)
- Check app has gallery permission

### Issue: Image quality is poor
**Solution**:
- Quality is set to 85% (configurable in code)
- Upload higher resolution images (will auto-resize)

---

## 📚 Code Reference

### Import Service
```dart
import 'package:fitmind_ai_fitness_mental_health_companion/cloudinary_service.dart';
```

### Upload Image
```dart
final imageBytes = await imageFile.readAsBytes();
final imageUrl = await CloudinaryService.uploadProfileImage(
  imageBytes,
  'profile_pic.jpg',
);
```

### Get Image URL
```dart
final imageUrl = await CloudinaryService.getProfileImageUrl();
CircleAvatar(
  backgroundImage: NetworkImage(imageUrl),
)
```

---

**Status**: ✅ Ready to Deploy
**Last Updated**: February 24, 2026
