# Profile Image Upload Setup

## Overview
The app now supports profile image uploads using **Cloudinary** with the following configuration:
- **Cloud Name**: `dfslzepiy`
- **Upload Preset**: `fitmind_images`
- **Package**: `cloudinary_public: ^0.23.1`

## Features
✅ Upload profile images from gallery (both web and mobile)
✅ Automatic image optimization (85% quality, max 500x500px)
✅ Store image URL in Firebase `users` collection
✅ Display profile images with fallback icon
✅ Error handling for Firebase and upload failures
✅ Loading state with progress indicator
✅ Success feedback with SnackBar

## File Structure

### New Files Created:
1. **cloudinary_service.dart** - Service layer for Cloudinary operations
   - `uploadProfileImage()` - Upload and save to Firebase
   - `getProfileImageUrl()` - Retrieve profile image URL
   - `deleteProfileImage()` - Delete image (placeholder)

### Modified Files:
1. **profile_screen.dart** - Updated UI with image upload
   - Click/tap profile avatar to upload image
   - Shows camera icon on avatar
   - Displays loading state during upload
   - Shows success/error messages

## Firebase Structure
Profile images are stored in the `users` collection with the following fields:

```
users/
  {userId}/
    name: "User Name"
    email: "user@example.com"
    age: 25
    weight: 70
    goals: "Fitness"
    profileImageUrl: "https://res.cloudinary.com/..." ✨ NEW
    profileImageUpdatedAt: "2026-02-24T12:34:56.000Z" ✨ NEW
```

## How It Works

### For Mobile App:
1. User taps the profile avatar
2. Image picker opens from gallery
3. Image is compressed (85% quality, max 500x500)
4. Uploaded to Cloudinary with `profile_images` folder
5. Image URL stored in Firebase `profileImageUrl` field
6. UI updates automatically

### For Web:
1. Same process as mobile
2. `cloudinary_public` package handles web upload automatically
3. No additional configuration needed

## Usage Example

```dart
// In any screen, import the service
import 'package:fitmind_ai_fitness_mental_health_companion/cloudinary_service.dart';

// Upload profile image
final imageBytes = await imageFile.readAsBytes();
final imageUrl = await CloudinaryService.uploadProfileImage(
  imageBytes,
  fileName,
);

// Get profile image URL
final profileImageUrl = await CloudinaryService.getProfileImageUrl();
```

## Error Handling
- ✅ Firebase authentication errors
- ✅ Upload failures
- ✅ Network errors
- ✅ Invalid image files
- ✅ User not authenticated

## Security Notes
- Upload preset is public (set in Cloudinary dashboard)
- Only authenticated Firebase users can upload
- Images stored in `profile_images` folder for organization
- HTTPS/secure URLs only

## Testing Checklist
- [ ] Mobile: Pick image from gallery and upload
- [ ] Web: Pick image and upload
- [ ] Verify image appears in profile
- [ ] Check Firebase stores URL in users collection
- [ ] Test error cases (network down, invalid file, etc.)
- [ ] Verify image persists after logout/login

## Troubleshooting

**Image not appearing after upload:**
- Check Firebase `profileImageUrl` field is populated
- Verify Cloudinary URL is accessible

**Upload fails:**
- Ensure `dfslzepiy` cloud name is correct
- Check `fitmind_images` preset exists in Cloudinary
- Verify Firebase authentication is working

**"Failed to upload image" error:**
- Check internet connection
- Verify image file is valid
- Check Cloudinary quota/plan

## Next Steps (Optional)
- Add image cropping before upload
- Implement image caching locally
- Add delete profile image functionality
- Add multiple gallery image support
