# Video Player Bug Reproduction

A minimal Flutter app to test if an Android device has the hardware buffer defect that causes `MediaCodecVideoRenderer` errors.

## How to Test a Device

1. Run the app in **debug mode** on the target device
2. Try both videos from the dropdown menu

### Device HAS the defect (should return `true`)

Both videos fail with "Video initialization failed" and show a `PlatformException` with `MediaCodecVideoRenderer error`:

![Defect present - video fails to initialize](docs/defect_present.png)

In logcat, look for these key error lines:

```
E/ACodec: Failed to allocate buffers after transitioning to IDLE state (error 0xfffffc0e)
W/ACodec: [OMX.hisi.video.decoder.avc] setting nBufferCountActual to 12 failed: -1010
E/MediaCodecVideoRenderer: Video codec error
```

### Device does NOT have the defect (should return `false`)

Both videos play successfully:

![No defect - video plays normally](docs/no_defect.png)

**Note:** If only one video works and the other fails, this may indicate a different bug.

## Workaround Verification

To confirm the defect is related to hardware buffers, uncomment the following line in `MainActivity.kt`:

```kotlin
// FlutterRenderer.debugForceSurfaceProducerGlTextures = true
```

If setting this flag makes all videos play successfully, the device has the hardware buffer defect and `hasAndroidHardwareBufferDefect` should return `true`.
