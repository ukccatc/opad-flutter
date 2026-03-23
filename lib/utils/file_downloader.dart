// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'logger.dart';

/// Utility class for downloading files in Flutter Web
/// This class only works on web platform (uses dart:html)
class FileDownloader {
  /// Download a file from the given URL
  /// 
  /// [url] - The URL of the file to download (relative or absolute)
  /// [filename] - Optional filename for the download
  static void downloadFile(String url, {String? filename}) {
    if (!kIsWeb) {
      Logger.warning('FileDownloader only works on web platform');
      return;
    }
    try {
      Logger.info('Simple download: $url, filename: $filename');
      
      // Create anchor element
      final anchor = html.AnchorElement(href: url)
        ..target = '_blank';
      
      if (filename != null && filename.isNotEmpty) {
        anchor.download = filename;
      }

      // Add to DOM temporarily
      html.document.body?.append(anchor);
      
      // Trigger click
      anchor.click();
      
      // Wait a bit before removing
      Future.delayed(const Duration(milliseconds: 100), () {
        anchor.remove();
      });
      
      Logger.info('Download triggered');
    } catch (e, stackTrace) {
      Logger.error('Error downloading file', e, stackTrace);
      // Fallback: open in new tab
      try {
        html.window.open(url, '_blank');
      } catch (e2) {
        Logger.error('Failed to open URL', e2);
      }
    }
  }

  /// Download a file with a specific filename
  /// This method fetches the file as blob and creates a download link
  /// This ensures the file is downloaded with the correct filename
  static Future<void> downloadFileAsBlob(String url, String filename) async {
    if (!kIsWeb) {
      Logger.warning('FileDownloader only works on web platform');
      return;
    }
    try {
      Logger.info('Attempting to download: $url');
      
      // Fetch the file
      final response = await html.HttpRequest.request(
        url,
        responseType: 'blob',
      );

      Logger.info('Response status: ${response.status}');
      Logger.info('Response statusText: ${response.statusText}');

      if (response.status == 200) {
        final blob = response.response as html.Blob;
        Logger.info('Blob size: ${blob.size} bytes');
        
        final blobUrl = html.Url.createObjectUrlFromBlob(blob);
        Logger.info('Created blob URL: $blobUrl');

        // Create download link
        final anchor = html.AnchorElement(href: blobUrl)
          ..download = filename
          ..style.display = 'none';

        html.document.body?.append(anchor);
        Logger.info('Triggering download for: $filename');
        anchor.click();
        
        // Wait a bit before removing
        await Future.delayed(const Duration(milliseconds: 100));
        anchor.remove();

        // Revoke blob URL to free memory
        html.Url.revokeObjectUrl(blobUrl);
        Logger.info('Download completed');
      } else {
        // Fallback to simple download if blob fetch fails
        Logger.warning('Failed to fetch blob, status: ${response.status}, trying fallback');
        downloadFile(url, filename: filename);
      }
    } catch (e, stackTrace) {
      Logger.error('Error downloading file as blob', e, stackTrace);
      // Fallback to simple download
      Logger.info('Trying fallback download method');
      downloadFile(url, filename: filename);
    }
  }
}

