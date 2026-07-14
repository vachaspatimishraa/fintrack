package com.example.fintrack

import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.fintrack.app/security"
    private var pendingResult: MethodChannel.Result? = null
    private val REQUEST_CODE_CONFIRM_DEVICE_CREDENTIAL = 1001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setScreenshotProtection") {
                val enabled = call.argument<Boolean>("enabled") ?: false
                if (enabled) {
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                } else {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
                result.success(null)
            } else if (call.method == "authenticateDeviceCredential") {
                val title = call.argument<String>("title") ?: "Authentication Required"
                val description = call.argument<String>("description") ?: "Confirm your device credentials"
                val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
                if (keyguardManager.isDeviceSecure) {
                    val intent = keyguardManager.createConfirmDeviceCredentialIntent(title, description)
                    if (intent != null) {
                        pendingResult = result
                        startActivityForResult(intent, REQUEST_CODE_CONFIRM_DEVICE_CREDENTIAL)
                    } else {
                        result.success(false)
                    }
                } else {
                    result.success(false)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_CONFIRM_DEVICE_CREDENTIAL) {
            if (resultCode == Activity.RESULT_OK) {
                pendingResult?.success(true)
            } else {
                pendingResult?.success(false)
            }
            pendingResult = null
        }
    }
}
