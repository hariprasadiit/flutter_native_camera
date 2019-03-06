package com.vizmo.flutternativecamera

import android.Manifest
import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Bundle
import android.view.View
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.PluginRegistry
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.os.Build
import com.otaliastudios.cameraview.*
import java.io.ByteArrayOutputStream

class FlutterNativeCameraPlugin {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      if (registrar.activity() == null) {
        // When a background flutter view tries to register the plugin, the registrar has no activity.
        // We stop the registration process as this plugin is foreground only.
        return
      }

      registrar
          .platformViewRegistry()
          .registerViewFactory(
              "plugins.vizmo.com/nativecameraview", NativeCameraViewFactory(registrar
          ))
    }
  }
}

class NativeCameraViewFactory(private val registrar: Registrar) :
    PlatformViewFactory
    (StandardMessageCodec.INSTANCE) {

  override fun create(context: Context, id: Int, orgs: Any?): PlatformView {
    return NativeCameraView(context, registrar, id, orgs as Map<String, Any>)
  }
}

@Suppress("DEPRECATED_IDENTITY_EQUALS")
class NativeCameraView(context: Context, private val registrar: Registrar, id: Int,
                       params:
                       Map<String,
                           Any>) :
    PlatformView,
    MethodCallHandler,
    CameraListener(),
    Application.ActivityLifecycleCallbacks,
    PluginRegistry.RequestPermissionsResultListener {

  companion object {
    @JvmStatic
    val CAMERA_REQUEST_ID = 551802281
    val TAG = "NATIVE_CAMERA"
  }

  private val cameraView: CameraView = CameraView(context)
  private val methodChannel: MethodChannel
  private var flutterResult: Result? = null
  private val activity: Activity = registrar.activity()

  init {
    activity.application.registerActivityLifecycleCallbacks(this)
    registrar.addRequestPermissionsResultListener(this)

    cameraView.addCameraListener(this)
    cameraView.facing = Facing.FRONT
    cameraView.audio = Audio.OFF

    checkCameraPermission()

    methodChannel = MethodChannel(registrar.messenger(), "plugins.vizmo.com/nativecameraview_$id")
    methodChannel.setMethodCallHandler(this)
  }

  private fun checkCameraPermission() {
    if (hasCameraPermission() && !cameraView.isOpened) {
      cameraView.open()
    } else {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        registrar
            .activity()
            .requestPermissions(
                arrayOf(Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO),
                CAMERA_REQUEST_ID)
      }
    }
  }

  override fun getView(): View {
    return cameraView
  }

  override fun dispose() {
    cameraView.destroy()
    activity.application.unregisterActivityLifecycleCallbacks(this)
  }

  override fun onActivityPaused(p0: Activity?) {
    cameraView.close()
  }

  override fun onActivityResumed(p0: Activity?) {
    if (hasCameraPermission() && !cameraView.isOpened) {
      cameraView.open()
    }
  }

  override fun onActivityStarted(p0: Activity?) {
  }

  override fun onActivityDestroyed(p0: Activity?) {
  }

  override fun onActivitySaveInstanceState(p0: Activity?, p1: Bundle?) {
  }

  override fun onActivityStopped(p0: Activity?) {
    cameraView.close()
  }

  override fun onActivityCreated(p0: Activity?, p1: Bundle?) {
  }

  override fun onCameraOpened(options: CameraOptions) {
    if (options.isExposureCorrectionSupported) {
      cameraView.exposureCorrection = options.exposureCorrectionMaxValue / 2
    }
  }

  override fun onPictureTaken(pictureResult: PictureResult) {
    val maxWidth = 512
    val maxHeight = (maxWidth / pictureResult.size.width) * pictureResult.size.height
    pictureResult.toBitmap(maxWidth, maxHeight) {
      val bos = ByteArrayOutputStream()
      it!!.compress(Bitmap.CompressFormat.JPEG, 70, bos)
      val jpegData = bos.toByteArray()
      flutterResult?.success(jpegData)
    }
  }

  override fun onMethodCall(methodCall: MethodCall, result: Result) {
    val method = methodCall.method
    if(method == "takePhoto") {
      flutterResult = result
      cameraView.takePicture()
    }else {
      result.notImplemented()
    }
  }

  private fun hasCameraPermission(): Boolean {
    return Build.VERSION.SDK_INT < Build.VERSION_CODES.M || activity.checkSelfPermission(Manifest.permission.CAMERA) === PackageManager.PERMISSION_GRANTED
  }

  override fun onRequestPermissionsResult(id: Int, permissions: Array<String>, grantResults: IntArray): Boolean {
      if (id == CAMERA_REQUEST_ID) {
       if(!cameraView.isOpened) cameraView.open()
        return true
      }
      return false
    }
}
