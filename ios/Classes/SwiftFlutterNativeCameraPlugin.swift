import Flutter
import UIKit
import SwiftyCam

public class SwiftFlutterNativeCameraPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    
    let _cameraFactory = NativeCameraViewFactory.init(withMessenger: registrar.messenger())
    registrar.register(_cameraFactory, withId: "plugins.vizmo.com/nativecameraview")
    
  }
}

public class NativeCameraViewFactory: NSObject, FlutterPlatformViewFactory {
    var _messenger: FlutterBinaryMessenger
    
    public init(withMessenger messenger: FlutterBinaryMessenger) {
        self._messenger = messenger
        
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return NativeCameraViewController.init(withFrame: frame, viewIdentifier: viewId, arguments: args, binaryMessenger: _messenger)
    }
}

public class NativeCameraViewController: NSObject, FlutterPlatformView, SwiftyCamViewControllerDelegate {

    var _channel: FlutterMethodChannel
    var _camController: SwiftyCamViewController
    var _flutterResult: FlutterResult?
    
    public init(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger messenger: FlutterBinaryMessenger) {
        
        _camController = SwiftyCamViewController.init(nibName: nil, bundle: nil)
        _camController.defaultCamera = .front
        _camController.view.frame = frame
        
        let channelName = "plugins.vizmo.com/nativecameraview_\(viewId)"
        _channel = FlutterMethodChannel.init(name: channelName, binaryMessenger: messenger)
    
        super.init()
        
        _camController.cameraDelegate = self
        
        _channel.setMethodCallHandler(onMethodCall)
        
    }
    
    public func view() -> UIView {
        return _camController.view
    }
    
    public func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        let resized = photo.resizeWithWidth(width: 512)
        let jpegData = UIImageJPEGRepresentation(resized!, 0.7)
        _flutterResult?(jpegData)
    }
    
    func onMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        if method == "takePhoto" {
            _flutterResult = result
            _camController.takePhoto()
        }
    }
}

extension UIImage {
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
