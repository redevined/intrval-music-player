package com.redevined.intrval_music_player

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.os.Process

/**
 * Guarantees the whole app process - including the in-process mpv playback
 * engine owned by `mpv_audio_kit` - actually dies when the user swipes the
 * app away from Recents, instead of continuing to play silently detached
 * from any UI/notification (see GitHub issue #3).
 *
 * `mpv_audio_kit`'s own `MpvMediaSessionService.onTaskRemoved()` only tears
 * down the OS media session/notification; it has no way to reach into the
 * Dart-owned mpv engine to stop it, so playback can keep going in the
 * background indefinitely (until force-stopped) even after the notification
 * is gone. Rather than patching that third-party plugin, this is a small,
 * independent service - started once at app launch - whose only job is to
 * catch `onTaskRemoved` and kill the process outright, exactly like the OS
 * would if the user force-closed the app.
 */
class TaskRemovedKillService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    // The default Service.onStartCommand() returns START_STICKY, which
    // makes ActivityManager treat our own killProcess() call below as a
    // crash and repeatedly relaunch the whole app in the background to
    // restart this service. START_NOT_STICKY opts out of that respawn loop.
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)
        return START_NOT_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        // Tell ActivityManager this service is intentionally stopping before
        // killing the process - otherwise it treats the SIGKILL below as a
        // crash and repeatedly relaunches the app in the background just to
        // restart this service.
        stopSelf()
        Process.killProcess(Process.myPid())
    }
}
