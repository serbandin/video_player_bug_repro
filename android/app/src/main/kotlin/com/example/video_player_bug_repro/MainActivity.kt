package com.example.video_player_bug_repro

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.renderer.FlutterRenderer

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        // Uncomment to test workaround - if videos play with this enabled, the device has the hardware buffer defect
        // FlutterRenderer.debugForceSurfaceProducerGlTextures = true
        super.configureFlutterEngine(flutterEngine)
    }
}
