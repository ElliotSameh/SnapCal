import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/foundation.dart';

class S3Service {
  static const String _folderPath = 'public/food-images/';

  Future<String> uploadImage({
    required File file,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final String fullPath = '$_folderPath$fileName';
      
      // Enhanced logging
      safePrint('═══════════════════════════════════════');
      safePrint('🚀 Starting S3 Upload');
      safePrint('📝 File name: $fileName');
      safePrint('🎯 S3 destination: $fullPath');
      safePrint('📦 File exists: ${await file.exists()}');
      safePrint('📏 File size: ${await file.length()} bytes');
      
      // Check auth session
      try {
        final session = await Amplify.Auth.fetchAuthSession();
        safePrint('🔐 Auth session fetched: ${session.isSignedIn}');
      } catch (e) {
        safePrint('⚠️  Auth check error: $e');
      }
      
      safePrint('📤 Starting upload...');

      final operation = Amplify.Storage.uploadFile(
        localFile: AWSFile.fromPath(file.path),
        path: StoragePath.fromString(fullPath),
        options: const StorageUploadFileOptions(
          metadata: {
            'content-type': 'image/jpeg',
          },
        ),
        onProgress: (progress) {
          final percentage = progress.fractionCompleted;
          safePrint('⬆️  Progress: ${(percentage * 100).toStringAsFixed(1)}%');
          if (onProgress != null) {
            onProgress(percentage);
          }
        },
      );

      final result = await operation.result;
      safePrint('✅ SUCCESS: ${result.uploadedItem.path}');
      safePrint('═══════════════════════════════════════');
      return result.uploadedItem.path;
      
    } on StorageException catch (e) {
      safePrint('═══════════════════════════════════════');
      safePrint('❌ StorageException:');
      safePrint('Message: ${e.message}');
      safePrint('Recovery: ${e.recoverySuggestion}');
      safePrint('Underlying: ${e.underlyingException}');
      safePrint('═══════════════════════════════════════');
      rethrow;
    } catch (e) {
      safePrint('❌ Error: $e (${e.runtimeType})');
      rethrow;
    }
  }

  Future<String> getDownloadUrl(String imageKey) async {
    try {
      final result = await Amplify.Storage.getUrl(
        path: StoragePath.fromString(imageKey),
      ).result;
      return result.url.toString();
    } catch (e) {
      debugPrint('Error getting URL: $e');
      rethrow;
    }
  }

  Future<void> deleteImage(String imageKey) async {
    try {
      await Amplify.Storage.remove(
        path: StoragePath.fromString(imageKey),
      ).result;
      debugPrint('Deleted image: $imageKey');
    } catch (e) {
      debugPrint('S3 Delete Error: $e');
      rethrow;
    }
  }
}
