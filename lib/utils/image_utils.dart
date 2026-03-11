class ImageUtils {
  static String? getHighQualityImageUrl(String? thumbnailUrl) {
    if (thumbnailUrl == null) return null;

    String url = thumbnailUrl;

    // Upgrade to HTTPS — Android 9+ blocks cleartext HTTP by default
    if (url.startsWith('http://')) {
      url = 'https://${url.substring(7)}';
    }

    if (url.contains('zoom=1')) {
      url = url.replaceAll('zoom=1', 'zoom=5');
    } else if (url.contains('zoom=2')) {
      url = url.replaceAll('zoom=2', 'zoom=5');
    } else if (url.contains('zoom=3')) {
      url = url.replaceAll('zoom=3', 'zoom=5');
    }

    return url;
  }
  
  static int? getCacheWidth({required double displayWidth}) {
    if (displayWidth <= 100) {
      return 200;
    } else if (displayWidth <= 200) {
      return 300;
    } else {
      return 600;
    }
  }
}

