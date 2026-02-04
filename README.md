# Video Player Bug Reproduction

Minimal reproduction project for [flutter/flutter#166481](https://github.com/flutter/flutter/issues/166481).

## Bug Description

Video playback fails on Android 10 (API 29) devices with hardware decoder errors:

```
setPortMode on output to DynamicANWBuffer failed w/ err -2147483648
Failed to allocate output port buffers after port reconfiguration: (-1010)
Decoder failed: OMX.hisi.video.decoder.avc
MediaCodecVideoRenderer error - IllegalStateException
```

## Environment

- **Flutter**: 3.38.9 (stable)
- **video_player**: ^2.9.5
- **Target device**: Android 10 (API 29) - tested on HUAWEI SNE-LX1

## Reproduction Steps

1. Clone this project
2. Run on an Android 10 (API 29) device:
   ```bash
   flutter run
   ```
3. Observe video fails to play with hardware decoder errors in logcat

## Test with Different Renderers

### With Impeller (default on newer Flutter):
```bash
flutter run --enable-impeller
```

### With Skia:
```bash
flutter run --no-enable-impeller
```

## Expected Behavior

Video should play normally.

## Actual Behavior

Video fails to initialize/play. Hardware video decoder cannot allocate buffers.

## Logs

To capture logs:
```bash
adb logcat | grep -E "(video|MediaCodec|ExoPlayer|OMX)"
```
