package com.redevined.intrval_music_player

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // See TaskRemovedKillService - started unconditionally (not just
        // while playing) so swiping the app away from Recents always kills
        // the process, matching a force-close (see GitHub issue #3).
        startService(Intent(this, TaskRemovedKillService::class.java))
    }
}
