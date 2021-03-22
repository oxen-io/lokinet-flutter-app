package io.oxen.lokinet_lib

import android.app.Activity.RESULT_OK
import android.content.Intent
import android.net.VpnService
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry
import network.loki.lokinet.LokinetDaemon

/** LokinetLibPlugin */
class LokinetLibPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var activityBinding: ActivityPluginBinding

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        System.loadLibrary("lokinet-android")

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "lokinet_lib")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {

        when (call.method) {
            "prepare" -> {
                val intent = VpnService.prepare(activityBinding.activity.applicationContext)
                if (intent != null) {
                    var listener: PluginRegistry.ActivityResultListener? = null
                    listener = PluginRegistry.ActivityResultListener { req, res, _ ->
                        if (req == 0 && res == RESULT_OK) {
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                        listener?.let { activityBinding.removeActivityResultListener(it) };
                        true
                    }
                    activityBinding.addActivityResultListener(listener)
                    activityBinding.activity.startActivityForResult(intent, 0)
                } else {
                    // If intent is null, already prepared
                    result.success(true)
                }
            }
            "prepared" -> {
                val intent = VpnService.prepare(activityBinding.activity.applicationContext)
                result.success(intent == null)
            }
            "connect" -> {
                val intent = VpnService.prepare(activityBinding.activity.applicationContext)
                if (intent != null) {
                    // Not prepared yet
                    result.success(false)
                    return
                }

                val lokinetIntent = Intent(activityBinding.activity.applicationContext, LokinetDaemon::class.java)
                lokinetIntent.action = LokinetDaemon.ACTION_CONNECT

                activityBinding.activity.applicationContext.startService(lokinetIntent)

                result.success(true);
            }
            "disconnect" -> {
                val lokinetIntent = Intent(activityBinding.activity.applicationContext, LokinetDaemon::class.java)
                lokinetIntent.action = LokinetDaemon.ACTION_DISCONNECT

                activityBinding.activity.applicationContext.startService(lokinetIntent)

                result.success(true);
            }
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivity() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {}
}
