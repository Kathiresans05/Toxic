package com.connectax.expert_professional

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL_NAME = "com.connectax.expert_professional/foreground_service"
    private var methodChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableLockScreenFlags()
    }

    private fun enableLockScreenFlags() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Anti-Screenshot and Anti-Screen Recording protection for expert safety & privacy
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    startForegroundServiceNative()
                    result.success(true)
                }
                "stopService" -> {
                    stopForegroundServiceNative()
                    result.success(true)
                }
                "isServiceRunning" -> {
                    result.success(ConnectaXForegroundService.isRunning)
                }
                "triggerIncomingCall" -> {
                    val callerName = call.argument<String>("callerName") ?: "Customer"
                    val callId = call.argument<String>("callId") ?: ""
                    val channelName = call.argument<String>("channelName") ?: ""
                    val price = call.argument<Double>("price") ?: 3.0
                    val callType = call.argument<String>("callType") ?: "video"

                    triggerIncomingCallNative(callerName, callId, channelName, price, callType)
                    result.success(true)
                }
                "bringAppToForeground" -> {
                    bringAppToForegroundNative()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Check if activity was launched with an incoming call
        checkIncomingCallIntent(intent)
    }

    private fun startForegroundServiceNative() {
        val serviceIntent = Intent(this, ConnectaXForegroundService::class.java).apply {
            action = ConnectaXForegroundService.ACTION_START
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }

    private fun stopForegroundServiceNative() {
        val serviceIntent = Intent(this, ConnectaXForegroundService::class.java).apply {
            action = ConnectaXForegroundService.ACTION_STOP
        }
        startService(serviceIntent)
    }

    private fun triggerIncomingCallNative(
        callerName: String,
        callId: String,
        channelName: String,
        price: Double,
        callType: String
    ) {
        val serviceIntent = Intent(this, ConnectaXForegroundService::class.java).apply {
            action = ConnectaXForegroundService.ACTION_INCOMING_CALL
            putExtra(ConnectaXForegroundService.EXTRA_CALLER_NAME, callerName)
            putExtra(ConnectaXForegroundService.EXTRA_CALL_ID, callId)
            putExtra(ConnectaXForegroundService.EXTRA_CHANNEL_NAME, channelName)
            putExtra(ConnectaXForegroundService.EXTRA_PRICE, price)
            putExtra(ConnectaXForegroundService.EXTRA_CALL_TYPE, callType)
        }
        startService(serviceIntent)
    }

    private fun bringAppToForegroundNative() {
        enableLockScreenFlags()
        val bringIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        startActivity(bringIntent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        enableLockScreenFlags()
        checkIncomingCallIntent(intent)
    }

    private fun checkIncomingCallIntent(intent: Intent?) {
        if (intent?.action == ConnectaXForegroundService.ACTION_INCOMING_CALL) {
            val callData = mapOf(
                "callerName" to (intent.getStringExtra(ConnectaXForegroundService.EXTRA_CALLER_NAME) ?: "Customer"),
                "callId" to (intent.getStringExtra(ConnectaXForegroundService.EXTRA_CALL_ID) ?: ""),
                "channelName" to (intent.getStringExtra(ConnectaXForegroundService.EXTRA_CHANNEL_NAME) ?: ""),
                "price" to intent.getDoubleExtra(ConnectaXForegroundService.EXTRA_PRICE, 3.0),
                "callType" to (intent.getStringExtra(ConnectaXForegroundService.EXTRA_CALL_TYPE) ?: "video")
            )
            methodChannel?.invokeMethod("onIncomingCallFromNotification", callData)
        }
    }
}
