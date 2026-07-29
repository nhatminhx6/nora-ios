#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "MistyForest" asset catalog image resource.
static NSString * const ACImageNameMistyForest AC_SWIFT_PRIVATE = @"MistyForest";

/// The "MoonlitCoast" asset catalog image resource.
static NSString * const ACImageNameMoonlitCoast AC_SWIFT_PRIVATE = @"MoonlitCoast";

/// The "MountainDusk" asset catalog image resource.
static NSString * const ACImageNameMountainDusk AC_SWIFT_PRIVATE = @"MountainDusk";

/// The "NoraColorIcon" asset catalog image resource.
static NSString * const ACImageNameNoraColorIcon AC_SWIFT_PRIVATE = @"NoraColorIcon";

/// The "WelcomeCity" asset catalog image resource.
static NSString * const ACImageNameWelcomeCity AC_SWIFT_PRIVATE = @"WelcomeCity";

#undef AC_SWIFT_PRIVATE
