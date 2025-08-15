<!-- @format -->

# 🚀 Laravel S3 + CloudFront Configuration Guide

## 📋 Prerequisites

Setelah deployment Terraform selesai, Anda akan mendapatkan credentials untuk Laravel.

## 🔧 Laravel Configuration

### 1. Install AWS SDK

```bash
composer require aws/aws-sdk-php
```

### 2. Environment Variables (.env)

```env
# AWS Configuration
AWS_DEFAULT_REGION=ap-southeast-1
AWS_BUCKET=your-bucket-name-from-terraform-output
AWS_URL=https://your-cloudfront-domain-from-terraform-output
AWS_ACCESS_KEY_ID=your-access-key-from-terraform-output
AWS_SECRET_ACCESS_KEY=your-secret-key-from-terraform-output

# Optional: S3 Disk Configuration
FILESYSTEM_DISK=s3
```

### 3. Filesystem Configuration (config/filesystems.php)

```php
'disks' => [
    // ... other disks

    's3' => [
        'driver' => 's3',
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION'),
        'bucket' => env('AWS_BUCKET'),
        'url' => env('AWS_URL'),
        'endpoint' => env('AWS_ENDPOINT'),
        'use_path_style_endpoint' => env('AWS_USE_PATH_STYLE_ENDPOINT', false),
        'visibility' => 'public',
        'throw' => false,
    ],
],
```

### 4. Image Upload Controller Example

```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class ImageController extends Controller
{
    public function upload(Request $request)
    {
        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:2048'
        ]);

        try {
            $file = $request->file('image');
            $fileName = time() . '_' . Str::random(10) . '.' . $file->getClientOriginalExtension();

            // Upload to S3
            $path = Storage::disk('s3')->putFileAs(
                'images/users',
                $file,
                $fileName
            );

            // Get CloudFront URL
            $cloudFrontUrl = env('AWS_URL') . '/' . $path;

            return response()->json([
                'success' => true,
                'message' => 'Image uploaded successfully',
                'data' => [
                    'path' => $path,
                    'url' => $cloudFrontUrl,
                    'filename' => $fileName
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to upload image',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function delete(Request $request)
    {
        $request->validate([
            'path' => 'required|string'
        ]);

        try {
            // Delete from S3
            Storage::disk('s3')->delete($request->path);

            return response()->json([
                'success' => true,
                'message' => 'Image deleted successfully'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete image',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function list()
    {
        try {
            $files = Storage::disk('s3')->files('images/users');

            $fileList = [];
            foreach ($files as $file) {
                $fileList[] = [
                    'path' => $file,
                    'url' => env('AWS_URL') . '/' . $file,
                    'size' => Storage::disk('s3')->size($file),
                    'last_modified' => Storage::disk('s3')->lastModified($file)
                ];
            }

            return response()->json([
                'success' => true,
                'data' => $fileList
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to list images',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
```

### 5. Routes (routes/web.php atau routes/api.php)

```php
// Web Routes
Route::post('/upload-image', [ImageController::class, 'upload'])->name('upload.image');
Route::delete('/delete-image', [ImageController::class, 'delete'])->name('delete.image');
Route::get('/list-images', [ImageController::class, 'list'])->name('list.images');

// API Routes
Route::prefix('api')->group(function () {
    Route::post('/upload-image', [ImageController::class, 'upload']);
    Route::delete('/delete-image', [ImageController::class, 'delete']);
    Route::get('/list-images', [ImageController::class, 'list']);
});
```

### 6. Frontend Upload Example (JavaScript)

```javascript
// Upload Image
const uploadImage = async (file) => {
  const formData = new FormData();
  formData.append("image", file);

  try {
    const response = await fetch("/upload-image", {
      method: "POST",
      body: formData,
      headers: {
        "X-CSRF-TOKEN": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
    });

    const result = await response.json();

    if (result.success) {
      console.log("Image uploaded:", result.data.url);
      return result.data.url;
    } else {
      console.error("Upload failed:", result.message);
    }
  } catch (error) {
    console.error("Upload error:", error);
  }
};

// Delete Image
const deleteImage = async (path) => {
  try {
    const response = await fetch("/delete-image", {
      method: "DELETE",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-TOKEN": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
      body: JSON.stringify({ path }),
    });

    const result = await response.json();

    if (result.success) {
      console.log("Image deleted successfully");
    } else {
      console.error("Delete failed:", result.message);
    }
  } catch (error) {
    console.error("Delete error:", error);
  }
};
```

### 7. Blade Template Example

```php
{{-- Upload Form --}}
<form action="{{ route('upload.image') }}" method="POST" enctype="multipart/form-data">
    @csrf
    <input type="file" name="image" accept="image/*" required>
    <button type="submit">Upload Image</button>
</form>

{{-- Display Image --}}
@if($imageUrl)
    <img src="{{ $imageUrl }}" alt="Uploaded Image" style="max-width: 300px;">
@endif
```

## 🔒 Security Considerations

1. **File Validation**: Always validate file types and sizes
2. **Path Sanitization**: Sanitize file paths to prevent directory traversal
3. **Access Control**: Implement proper authentication and authorization
4. **CORS**: CORS sudah dikonfigurasi untuk localhost:5050

## 📁 File Structure

```
S3 Bucket Structure:
├── images/
│   ├── users/          # User uploads
│   ├── public/         # Public assets
│   └── temp/           # Temporary files
├── documents/
└── other-files/
```

## 🚀 Getting Started

1. **Deploy Terraform**: `make deploy`
2. **Get Credentials**: `terraform output`
3. **Update .env**: Copy credentials to Laravel .env
4. **Test Upload**: Use the controller examples above

## 🆘 Troubleshooting

### Common Issues:

1. **CORS Error**: Pastikan localhost:5050 ada di CORS allowed origins
2. **Permission Denied**: Periksa IAM credentials dan permissions
3. **File Not Found**: Periksa path dan bucket name

### Debug Commands:

```bash
# Test S3 connection
php artisan tinker
Storage::disk('s3')->put('test.txt', 'Hello World');

# Check file exists
Storage::disk('s3')->exists('test.txt');

# List files
Storage::disk('s3')->files('images/users');
```

## 💡 Best Practices

1. **Image Optimization**: Compress images before upload
2. **File Naming**: Use unique, secure file names
3. **Error Handling**: Implement proper error handling
4. **Logging**: Log upload/delete operations
5. **Cleanup**: Implement cleanup for temporary files
