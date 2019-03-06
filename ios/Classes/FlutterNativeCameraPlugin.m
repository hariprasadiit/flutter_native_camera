#import "FlutterNativeCameraPlugin.h"
#import <flutter_native_camera/flutter_native_camera-Swift.h>

@implementation FlutterNativeCameraPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterNativeCameraPlugin registerWithRegistrar:registrar];
}
@end
