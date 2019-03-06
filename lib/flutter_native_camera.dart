import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

typedef void NativeCameraViewCreatedCallback(NativeCameraController controller);

enum FlashMode {
  on,
  off,
  auto,
}

class NativeCameraView extends StatefulWidget {
  const NativeCameraView(
      {Key key, this.onNativeCameraViewCreated, this.flashMode = FlashMode.off})
      : super(key: key);

  final NativeCameraViewCreatedCallback onNativeCameraViewCreated;

  final FlashMode flashMode;

  @override
  State<StatefulWidget> createState() {
    return new _NativeCameraViewState();
  }
}

class _NativeCameraViewState extends State<NativeCameraView> {
  final Completer<NativeCameraController> _controller =
      Completer<NativeCameraController>();

  _NativeCameraSettings _settings;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'plugins.vizmo.com/nativecameraview',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: _CreationParams.fromWidget(widget).toMap(),
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'plugins.vizmo.com/nativecameraview',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: _CreationParams.fromWidget(widget).toMap(),
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the flutter_native_camera plugin');
  }

  @override
  void didUpdateWidget(NativeCameraView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateConfiguration(_NativeCameraSettings.fromWidget(widget));
  }

  Future<void> _updateConfiguration(_NativeCameraSettings settings) async {
    _settings = settings;
    final NativeCameraController controller = await _controller.future;
    controller._updateSettings(settings);
  }

  void _onPlatformViewCreated(int id) {
    final NativeCameraController controller =
        NativeCameraController._(id, _NativeCameraSettings.fromWidget(widget));
    _controller.complete(controller);
    if (widget.onNativeCameraViewCreated != null) {
      widget.onNativeCameraViewCreated(controller);
    }
  }
}

class _CreationParams {
  _CreationParams({this.settings});

  static _CreationParams fromWidget(NativeCameraView widget) {
    return _CreationParams(
      settings: _NativeCameraSettings.fromWidget(widget),
    );
  }

  final _NativeCameraSettings settings;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'settings': settings.toMap(),
    };
  }
}

class _NativeCameraSettings {
  _NativeCameraSettings({
    this.flashMode,
  });

  static _NativeCameraSettings fromWidget(NativeCameraView widget) {
    return _NativeCameraSettings(flashMode: widget.flashMode);
  }

  final FlashMode flashMode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'flashMode': flashMode.index,
    };
  }

  Map<String, dynamic> updatesMap(_NativeCameraSettings newSettings) {
    if (flashMode == newSettings.flashMode) {
      return null;
    }
    return <String, dynamic>{
      'flashMode': newSettings.flashMode.index,
    };
  }
}

class NativeCameraController {
  NativeCameraController._(int id, this._settings)
      : _channel = MethodChannel('plugins.vizmo.com/nativecameraview_$id') {
    _channel.setMethodCallHandler(_onMethodCall);
  }

  final MethodChannel _channel;

  _NativeCameraSettings _settings;

  Future<void> _onMethodCall(MethodCall call) async {
    switch (call.method) {
    }
  }

  Future<void> _updateSettings(_NativeCameraSettings setting) async {
    final Map<String, dynamic> updateMap = _settings.updatesMap(setting);
    if (updateMap == null) {
      return null;
    }
    _settings = setting;
    return _channel.invokeMethod('updateSettings', updateMap);
  }

  Future<Uint8List> takePhoto() async {
    return _channel.invokeMethod('takePhoto');
  }
}
