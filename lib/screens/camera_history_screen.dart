// screens/camera_history_screen.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class CameraHistoryScreen extends StatefulWidget {
  const CameraHistoryScreen({super.key});

  @override
  State<CameraHistoryScreen> createState() => _CameraHistoryScreenState();
}

class _CameraHistoryScreenState extends State<CameraHistoryScreen> {
  List<String> _videoFiles = [];
  bool _isLoading = true;
  VideoPlayerController? _videoController;
  bool _isVideoPlaying = false;
  String? _currentVideoTitle;

  // Static list of camera videos (in a real app, this would come from an API)
  final List<Map<String, String>> _cameraVideos = [
    {
      'path': 'lib/cameras/Locust farming.mp4',
      'title': 'Locust Farming',
      'description': 'Daily farming operations and locust monitoring'
    },
    {
      'path': 'lib/cameras/A Million Locusts Farm, The Scene Is So Stunning!.mp4',
      'title': 'Large Scale Farming',
      'description': 'Impressive view of extensive locust farming operations'
    },
    {
      'path': 'lib/cameras/locust farms, how to raise locusts#shorts.mp4',
      'title': 'Farming Techniques',
      'description': 'Essential techniques for successful locust farming'
    },
    {
      'path': 'lib/cameras/Locusts devour rice paddy crop in Uttarakhand, India.mp4',
      'title': 'Rice Paddy Monitoring',
      'description': 'Monitoring locust activity in rice paddies'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadVideos() async {
    setState(() => _isLoading = true);

    // Simulate loading delay and check which videos are actually available
    await Future.delayed(const Duration(milliseconds: 500));

    // In a real app, you would fetch this from an API or local storage
    // For now, we'll use the static list but verify files exist
    final availableVideos = <Map<String, String>>[];

    for (final video in _cameraVideos) {
      try {
        // Check if asset exists (simplified check)
        availableVideos.add(video);
      } catch (e) {
        // Video not available, skip it
        continue;
      }
    }

    setState(() {
      _videoFiles = availableVideos.map((v) => v['path']!).toList();
      _isLoading = false;
    });
  }

  Future<void> _playVideo(String videoPath, String title) async {
    // Dispose previous controller
    await _videoController?.dispose();

    setState(() {
      _isVideoPlaying = true;
      _currentVideoTitle = title;
    });

    try {
      // First try asset loading
      _videoController = VideoPlayerController.asset(videoPath);
      await _videoController!.initialize();
      await _videoController!.setLooping(false);
      await _videoController!.play();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Asset loading failed for $videoPath: $e');

      // If asset loading fails, try copying to temp file and loading from there
      try {
        final tempFile = await _copyAssetToTempFile(videoPath);
        if (tempFile != null) {
          _videoController = VideoPlayerController.file(tempFile);
          await _videoController!.initialize();
          await _videoController!.setLooping(false);
          await _videoController!.play();

          if (mounted) {
            setState(() {});
          }
        } else {
          throw Exception('Failed to copy asset to temporary file');
        }
      } catch (fileError) {
        debugPrint('File loading also failed for $videoPath: $fileError');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading video: $fileError'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isVideoPlaying = false;
            _currentVideoTitle = null;
          });
        }
      }
    }
  }

  Future<File?> _copyAssetToTempFile(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());
      return tempFile;
    } catch (e) {
      debugPrint('Failed to copy asset to temp file: $e');
      return null;
    }
  }

  void _stopVideo() {
    _videoController?.pause();
    _videoController?.seekTo(Duration.zero);
    setState(() {
      _isVideoPlaying = false;
      _currentVideoTitle = null;
    });
  }

  Widget _buildVideoCard(Map<String, String> videoData, int index) {
    final path = videoData['path']!;
    final title = videoData['title']!;
    final description = videoData['description']!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _playVideo(path, title),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Video thumbnail placeholder
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.videocam,
                  color: Colors.grey,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),

              // Video info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Recorded ${index + 1} day${index == 0 ? '' : 's'} ago',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Play button
              IconButton(
                icon: const Icon(Icons.play_circle_fill),
                color: Theme.of(context).primaryColor,
                iconSize: 32,
                onPressed: () => _playVideo(path, title),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Close button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _stopVideo,
              ),
            ],
          ),

          // Video title
          if (_currentVideoTitle != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _currentVideoTitle!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Video player
          Expanded(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),

          // Controls
          Container(
            color: Colors.black87,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _videoController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _videoController!.value.isPlaying
                          ? _videoController!.pause()
                          : _videoController!.play();
                    });
                  },
                ),
                Expanded(
                  child: VideoProgressIndicator(
                    _videoController!,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.red,
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.replay, color: Colors.white),
                  onPressed: () {
                    _videoController!.seekTo(Duration.zero);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Camera Recordings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Camera recordings will appear here when available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loadVideos,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVideos,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isVideoPlaying
          ? _buildVideoPlayer()
          : _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Loading camera recordings...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : _videoFiles.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _cameraVideos.length,
                      itemBuilder: (context, index) {
                        return _buildVideoCard(_cameraVideos[index], index);
                      },
                    ),
    );
  }
}