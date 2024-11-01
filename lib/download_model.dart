class Download {
  final String url;
  int downloadedBytes;
  int totalBytes;
  String status;
  bool isDownloading;

  Download({
    required this.url,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.status = 'Ready',
    this.isDownloading = false,
  });

  // Convert a Download object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'downloadedBytes': downloadedBytes,
      'totalBytes': totalBytes,
      'status': status,
      'isDownloading': isDownloading,
    };
  }

  // Create a Download object from a JSON map
  factory Download.fromJson(Map<String, dynamic> json) {
    return Download(
      url: json['url'],
      downloadedBytes: json['downloadedBytes'] ?? 0,
      totalBytes: json['totalBytes'] ?? 0,
      status: json['status'] ?? 'Ready',
      isDownloading: json['isDownloading'] ?? false,
    );
  }
}
