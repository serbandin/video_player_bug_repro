import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player Bug Repro',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
      home: const VideoPlayerPage(),
    );
  }
}

const testVideos = {
  '01 - Mainconcept (bitstream_restriction_flag=0)': 'assets/test_videos/01_bug_mainconcept.mp4',
  '02 - libx264 (bitstream_restriction_flag=1)': 'assets/test_videos/02_fixed_libx264.mp4',
};

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  String? _error;
  String _selectedVideo = testVideos.keys.first;

  @override
  void initState() {
    super.initState();

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller?.dispose();
    setState(() {
      _isInitialized = false;
      _error = null;
    });

    _controller = VideoPlayerController.asset(
      testVideos[_selectedVideo]!,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true, allowBackgroundPlayback: false),
    );

    try {
      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.setVolume(0);
      _controller!.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player Bug Repro'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedVideo,
              isExpanded: true,
              items: testVideos.keys.map((name) {
                return DropdownMenuItem(
                  value: name,
                  child: Text(name, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedVideo = value);
                  _initializeVideo();
                }
              },
            ),
          ),
          Expanded(child: Center(child: _buildContent())),
        ],
      ),
      floatingActionButton: _isInitialized && _controller != null
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (_controller!.value.isPlaying) {
                    _controller!.pause();
                  } else {
                    _controller!.play();
                  }
                });
              },
              child: Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
            )
          : null,
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Video initialization failed:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Initializing video...')],
      );
    }

    return AspectRatio(aspectRatio: _controller!.value.aspectRatio, child: VideoPlayer(_controller!));
  }
}
