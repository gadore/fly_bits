import 'package:audio_service/audio_service.dart';

void myBackgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => MyBackgroundTask());
}

class MyBackgroundTask extends BackgroundAudioTask {
  @override
  Future<void> onStart() async {
    // Your custom dart code to start audio playback.
    // NOTE: The background audio task will shut down
    // as soon as this async function completes.
  }
  @override
  void onStop() {
    // Your custom dart code to stop audio playback.
  }
  @override
  void onPlay() {
    // Your custom dart code to resume audio playback.
  }
  @override
  void onPause() {
    // Your custom dart code to pause audio playback.
  }
  @override
  void onClick(MediaButton button) {
    // Your custom dart code to handle a media button click.
  }
}