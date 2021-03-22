#import "LokinetLibPlugin.h"
#if __has_include(<lokinet_lib/lokinet_lib-Swift.h>)
#import <lokinet_lib/lokinet_lib-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "lokinet_lib-Swift.h"
#endif

@implementation LokinetLibPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLokinetLibPlugin registerWithRegistrar:registrar];
}
@end
