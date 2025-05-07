#import <Foundation/Foundation.h>

#define HOOK_FUNCTION(return_type, name, ...) \
static return_type (*_orig_##name)(__VA_ARGS__); \
static return_type _##name(__VA_ARGS__)

%hook WAMainEncryptor
- (void)encryptMessage:(id)arg1 forUserJID:(id)arg2 pendingDevices:(id)arg3 deviceJID:(id)arg4 allowPrimaryIdentityChangesForOtherDevices:(BOOL)arg5 useDeprecatedSessionsOrSenderKeys:(BOOL)arg6 retryCount:(unsigned long long)arg7 completion:(id)arg8 {
    %orig(arg1, arg2, arg3, arg4, arg5, NO, arg7, arg8);
}
%end

%hook WARootViewController
- (BOOL)isBuildExpired { return NO; }
%end

%hook WAPBClientPayload_UserAgent_AppVersion
- (unsigned int)primary { return 2; }
- (unsigned int)secondary { return 25; }
- (unsigned int)tertiary { return 14; }
- (unsigned int)quaternary { return 7; }
- (unsigned int)quinary { return 7; }
%end

HOOK_FUNCTION(BOOL, WAIsPlatformDeprecated) {
    return NO;
}

HOOK_FUNCTION(void, WAShouldShowPlatformDeprecationNags) {
    return;
}

HOOK_FUNCTION(NSDate *, WABuildDate) {
    // return [NSDate dateWithTimeIntervalSinceNow:1746224449]; //25.14.7
    return [NSDate date];
}

HOOK_FUNCTION(NSDate *, WAAppExpirationDate) {
    return [NSDate dateWithTimeIntervalSinceNow:3981301200];
}

HOOK_FUNCTION(NSDate *, WADeprecatedPlatformCutOffDate) {
    return [NSDate dateWithTimeIntervalSinceNow:3981301200];
}

HOOK_FUNCTION(NSString *, WABuildVersion, void *arg1, void *arg2) {
    return @"2.25.14.77";
}

HOOK_FUNCTION(NSString *, WABuildHash) {
    return @"92f8142b7ed3045ef6f332ee34348a63";
}

%ctor {
    NSString *frameworkPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Frameworks/SharedModules.framework/SharedModules"];
    MSImageRef image = MSGetImageByName([frameworkPath UTF8String]);

    if (!image) return;

    struct {
        const char *name;
        void *replacement;
        void **original;
    } hooks[] = {
        {"_WAIsPlatformDeprecated", (void *)&_WAIsPlatformDeprecated, (void **)&_orig_WAIsPlatformDeprecated},
        {"_WAShouldShowPlatformDeprecationNags", (void *)&_WAShouldShowPlatformDeprecationNags, (void **)&_orig_WAShouldShowPlatformDeprecationNags},
        {"_WABuildDate", (void *)&_WABuildDate, (void **)&_orig_WABuildDate},
        {"_WAAppExpirationDate", (void *)&_WAAppExpirationDate, (void **)&_orig_WAAppExpirationDate},
        {"_WADeprecatedPlatformCutOffDate", (void *)&_WADeprecatedPlatformCutOffDate, (void **)&_orig_WADeprecatedPlatformCutOffDate},
        {"_WABuildVersion", (void *)&_WABuildVersion, (void **)&_orig_WABuildVersion},
        {"_WABuildHash", (void *)&_WABuildHash, (void **)&_orig_WABuildHash},
    };

    for (size_t i = 0; i < sizeof(hooks)/sizeof(hooks[0]); i++) {
        void *symbol = MSFindSymbol(image, hooks[i].name);
        if (symbol) {
            MSHookFunction(symbol, hooks[i].replacement, hooks[i].original);
        }
    }
}