package com.connectax.expert_professional

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.Color
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat

class ConnectaXForegroundService : Service() {

    private var wakeLock: PowerManager.WakeLock? = null

    companion object {
        const val CHANNEL_ID = "connectax_online_channel"
        const val CALL_CHANNEL_ID = "connectax_call_channel"
        const val NOTIFICATION_ID = 9001
        const val CALL_NOTIFICATION_ID = 9002

        const val ACTION_START = "ACTION_START_ONLINE"
        const val ACTION_STOP = "ACTION_STOP_ONLINE"
        const val ACTION_INCOMING_CALL = "ACTION_INCOMING_CALL"

        const val EXTRA_CALLER_NAME = "EXTRA_CALLER_NAME"
        const val EXTRA_CALL_ID = "EXTRA_CALL_ID"
        const val EXTRA_CHANNEL_NAME = "EXTRA_CHANNEL_NAME"
        const val EXTRA_PRICE = "EXTRA_PRICE"
        const val EXTRA_CALL_TYPE = "EXTRA_CALL_TYPE"

        @Volatile
        var isRunning = false
            private set
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannels()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                startOnlineService()
            }
            ACTION_STOP -> {
                stopOnlineService()
            }
            ACTION_INCOMING_CALL -> {
                handleIncomingCall(intent)
            }
        }
        return START_STICKY
    }

    private fun startOnlineService() {
        isRunning = true
        acquireWakeLock()

        val notificationIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notificationIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("ConnectaX Creator: Online & Ready")
            .setContentText("You are online. Incoming customer calls will ring instantly.")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun handleIncomingCall(intent: Intent) {
        val callerName = intent.getStringExtra(EXTRA_CALLER_NAME) ?: "Customer"
        val callId = intent.getStringExtra(EXTRA_CALL_ID) ?: ""
        val channelName = intent.getStringExtra(EXTRA_CHANNEL_NAME) ?: ""
        val price = intent.getDoubleExtra(EXTRA_PRICE, 3.0)
        val callType = intent.getStringExtra(EXTRA_CALL_TYPE) ?: "video"

        // Wake screen
        wakeUpScreen()

        // Fullscreen launch intent to MainActivity
        val fullScreenIntent = Intent(this, MainActivity::class.java).apply {
            this.action = ACTION_INCOMING_CALL
            this.flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra(EXTRA_CALLER_NAME, callerName)
            putExtra(EXTRA_CALL_ID, callId)
            putExtra(EXTRA_CHANNEL_NAME, channelName)
            putExtra(EXTRA_PRICE, price)
            putExtra(EXTRA_CALL_TYPE, callType)
        }

        val fullScreenPendingIntent = PendingIntent.getActivity(
            this,
            1,
            fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val callNotification = NotificationCompat.Builder(this, CALL_CHANNEL_ID)
            .setContentTitle("Incoming $callType Call")
            .setContentText("$callerName is calling you...")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setAutoCancel(true)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .setContentIntent(fullScreenPendingIntent)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(CALL_NOTIFICATION_ID, callNotification)

        // Attempt direct launch of the activity if screen was locked or backgrounded
        try {
            startActivity(fullScreenIntent)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun stopOnlineService() {
        isRunning = false
        releaseWakeLock()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun acquireWakeLock() {
        if (wakeLock == null) {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = powerManager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "ConnectaX:KeepAliveWakeLock"
            ).apply {
                acquire(24 * 60 * 60 * 1000L) // 24-hour safeguard
            }
        }
    }

    private fun wakeUpScreen() {
        try {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            @Suppress("DEPRECATION")
            val screenWakeLock = powerManager.newWakeLock(
                PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
                "ConnectaX:CallScreenWakeLock"
            )
            screenWakeLock.acquire(15000L) // 15 seconds to wake up screen
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun releaseWakeLock() {
        try {
            if (wakeLock?.isHeld == true) {
                wakeLock?.release()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            wakeLock = null
        }
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            // 1. Channel for persistent online notification
            val onlineChannel = NotificationChannel(
                CHANNEL_ID,
                "ConnectaX Online Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows creator online presence for incoming calls"
                setShowBadge(false)
            }
            notificationManager.createNotificationChannel(onlineChannel)

            // 2. Channel for high-priority incoming call notification
            val callChannel = NotificationChannel(
                CALL_CHANNEL_ID,
                "ConnectaX Incoming Calls",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Urgent incoming call alerts"
                enableLights(true)
                lightColor = Color.YELLOW
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 250, 500, 250, 500)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            notificationManager.createNotificationChannel(callChannel)
        }
    }

    override fun onDestroy() {
        releaseWakeLock()
        super.onDestroy()
    }
}
