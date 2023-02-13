// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, must_be_immutable

import 'dart:async';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';

const theSource = AudioSource.microphone;

/// Example app.
class SoundRecorder extends StatefulWidget {
  SoundRecorder({super.key, required this.savePath});

  Function savePath;
  @override
  _SoundRecorderState createState() => _SoundRecorderState();
}

class _SoundRecorderState extends State<SoundRecorder> {
  Codec _codec = Codec.aacMP4;
  String _mPath = '';
  late Timer _timer;
  int counter = 0;
  String recordingTime = "";
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool isRecording = false;
  bool _mRecorderIsInited = false;
  bool showRecordedAudio = false;
  bool openedRecorder = false;
  @override
  void initState() {
    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _mRecorder!.closeRecorder();
    _mRecorder = null;
    super.dispose();
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    _mRecorder!.closeRecorder();

    setState(() {
      openedRecorder = false;
    });
    await _mRecorder!.openRecorder().then((value) => {openedRecorder = true});
    setState(() {});
    if (openedRecorder == false) return;
    if (kIsWeb) {
      _codec = Codec.opusWebM;
      _mPath = '${generateRandomFilename()}.webm';
    }
    if (await _mRecorder!.isEncoderSupported(_codec) && !kIsWeb) {
      var dir = await getExternalStorageDirectory();
      _mPath = '${dir?.path}/${generateRandomFilename()}.mp4';
      _mRecorderIsInited = true;
      return;
    }

    _mRecorderIsInited = true;
  }

  String twoDigits(int n) {
    return n.toString().padLeft(2, "0");
  }

  String convertSecondsToMMSS(int seconds) {
    int minutes = (seconds / 60).floor();
    seconds = seconds - (minutes * 60);
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  // ----------------------  Here is the code for recording and playback -------
  void startTimer() {
    setState(() {
      counter = 0;
    });
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        counter++;

        setState(() {});
      },
    );
  }

  String generateRandomFilename() {
    final random = Random();
    const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final randomString = String.fromCharCodes(Iterable.generate(
      10,
      (_) => characters.codeUnitAt(random.nextInt(characters.length)),
    ));
    return 'file-$randomString';
  }

  void record() {
    if (!_mRecorderIsInited) {
      return;
    }
    if (!openedRecorder) return;
    _mRecorder!
        .startRecorder(
      toFile: _mPath,
      codec: _codec,
      audioSource: theSource,
    )
        .then((value) {
      setState(() {
        isRecording = true;
        startTimer();
      });
    });
  }

  void stopRecorder() async {
    if (!_mRecorderIsInited) {
      return;
    }
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {
        isRecording = false;
        showRecordedAudio = true;
        widget.savePath(value);
        _timer.cancel();
      });
    });
  }

// ----------------------------- UI --------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        !isRecording
            ? InkWell(
                onTap: () {
                  record();
                },
                child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    width: 90,
                    height: 25,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue),
                    child: Row(
                      children: const [
                        SizedBox(width: 5),
                        Icon(
                          Icons.mic,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Record",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      ],
                    )))
            : InkWell(
                onTap: () {
                  stopRecorder();
                },
                child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    width: 158,
                    height: 35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.red),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.stop,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Recording ${convertSecondsToMMSS(counter)}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      ],
                    ))),
        const SizedBox(
          width: 10,
        ),
        if (!isRecording && showRecordedAudio)
          Container(
              height: 35,
              width: 80,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.audio_file,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                      onTap: () {
                        showRecordedAudio = false;
                        setState(() {});
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ))
                ],
              ))
      ],
    );
  }
}