#import "SdkPlugin.h"
#if __has_include(<sdk/sdk-Swift.h>)
#import <sdk/sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "sdk-Swift.h"
#endif

@implementation SdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSdkPlugin registerWithRegistrar:registrar];
}
@end
