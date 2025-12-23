import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:radio_app/controller/radio.dart';
import 'package:radio_app/widgets/player.dart';
// import 'package:radio_app/radio/widgets/about_section.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late RadioClass radioClass;
  bool isPlaying = false;
  final double _percentageOpen = 1.0;
  String radioTitle = '';
  String radioListener = '';
  String radioImageURL = '';
  dynamic currentlyPlaying;
  List<String>? metadata;
  bool isChannelInitialized = false;

  Timer? timer;
  Duration playDuration = Duration.zero;
  bool isLoading = true;
  StreamSubscription? _stateSubscription;
  StreamSubscription? _metadataSubscription;

  @override
  void initState() {
    super.initState();
    radioClass = RadioClass();
    loadStationAndPlay();
  }

  @override
  void reassemble() {
    super.reassemble();
    // Refresh subscriptions and station data on hot reload
    _reloadStation();
  }

  Future<void> _reloadStation() async {
    try {
      await _stateSubscription?.cancel();
      await _metadataSubscription?.cancel();
      timer?.cancel();

      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      // Reload current station and listeners
      await loadStationAndPlay();
    } catch (e) {
      print('Error during reload: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _metadataSubscription?.cancel();
    radioClass.stop();
    timer?.cancel();
    super.dispose();
  }

  Future<void> loadStationAndPlay() async {
    try {
      print('DEBUG: Loading station data...');

      // Load station data from JSON
      final String response =
          await rootBundle.loadString('assets/json/station.json');
      final List<dynamic> data = json.decode(response);

      if (data.isEmpty) {
        throw Exception('No stations found in station.json');
      }

      final station = data[0];
      print('DEBUG: ✅ Station loaded: ${station['name']}');

      // Set up listeners
      await _stateSubscription?.cancel();
      await _metadataSubscription?.cancel();

      _stateSubscription = radioClass.radioPlayer.stateStream.listen(
        (value) {
          print('DEBUG: Player state: $value');
          if (mounted) {
            setState(() {
              isPlaying = value;
            });
            if (value) {
              startTimer();
            } else {
              stopTimer();
            }
          }
        },
        onError: (error) => print('ERROR in state stream: $error'),
      );

      _metadataSubscription = radioClass.radioPlayer.metadataStream.listen(
        (value) {
          print('DEBUG: Metadata: $value');
          if (mounted) {
            setState(() {
              metadata = value;
            });
          }
        },
        onError: (error) => print('ERROR in metadata stream: $error'),
      );

      // Update UI with station data (but don't initialize channel yet)
      if (mounted) {
        setState(() {
          currentlyPlaying = station;
          radioTitle = station['name'] ?? 'Buddhist Radio';
          radioImageURL =
              station['imageURL'] ?? 'assets/images/buddhist_radio_logo.jpg';
          radioListener = 'Tap play to start';
          isLoading = false;
        });
        print('DEBUG: ✅ Ready! Tap play to start streaming');
      }
    } catch (e, stackTrace) {
      print('❌ ERROR loading station: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          isLoading = false;
          radioTitle = 'Buddhist Radio';
          radioListener = 'Station unavailable';
          radioImageURL = 'assets/images/buddhist_radio_logo.jpg';
        });

        // Show error in Snackbar instead of on UI
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load station. Please restart the app.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> initializeChannel() async {
    if (isChannelInitialized || currentlyPlaying == null) return;

    try {
      print('DEBUG: Initializing radio channel...');
      await radioClass.setChannel(currentlyPlaying);
      await Future.delayed(const Duration(milliseconds: 500));
      isChannelInitialized = true;
      print('DEBUG: ✅ Channel initialized successfully');
    } catch (e) {
      print('❌ ERROR initializing channel: $e');
      isChannelInitialized = false;
      rethrow;
    }
  }

  void startTimer() {
    timer?.cancel();
    playDuration = Duration.zero;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        playDuration += const Duration(seconds: 1);
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  Future<void> play() async {
    try {
      // Initialize channel on first play
      if (!isChannelInitialized) {
        setState(() {
          radioListener = 'Initializing...';
        });
        await initializeChannel();
        setState(() {
          radioListener = 'Loading stream...';
        });
      }

      radioClass.play();
      print('▶️ Play started');
    } catch (e) {
      print('❌ Play error: $e');
      if (mounted) {
        setState(() {
          radioListener = 'Tap to retry';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to play. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> pause() async {
    radioClass.pause();
    stopTimer();
  }

  // Removed playNext and playPrevious - not needed for single station

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF500),
          title: Text(
            'BUDDHIST FM',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF500),
          title: Text(
            'BUDDHIST FM',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Player(
                key: ValueKey('$radioTitle-$isPlaying-${metadata?.join("-")}'),
                title: radioTitle,
                listener: radioListener,
                imageURL: radioImageURL,
                percentageOpen: _percentageOpen,
                onTab: () => isPlaying ? pause() : play(),
                icon:
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                metadata: metadata,
                onNext: () {}, // Removed next functionality
                onPrevious: () {}, // Removed previous functionality
                timer: formatDuration(playDuration),
              ),
              // const AboutSection(),
            ],
          ),
        ),
      ),
    );
  }
}
