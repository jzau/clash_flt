// Objective-C API for talking to ClashKit/clash Go package.
//   gobind -lang=objc ClashKit/clash
//
// File is generated by gobind. Do not edit.

#ifndef __Clash_H__
#define __Clash_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"


@protocol ClashClient;
@class ClashClient;

@protocol ClashClient <NSObject>
- (void)log:(NSString* _Nullable)level message:(NSString* _Nullable)message;
- (void)traffic:(int64_t)up down:(int64_t)down;
@end

FOUNDATION_EXPORT void ClashCloseAllConnections(void);

FOUNDATION_EXPORT NSData* _Nullable ClashGetConfigGeneral(void);

FOUNDATION_EXPORT NSString* _Nonnull ClashGetTunnelMode(void);

FOUNDATION_EXPORT NSData* _Nullable ClashHealthCheck(NSString* _Nullable name, NSString* _Nullable url);

FOUNDATION_EXPORT BOOL ClashPatchSelector(NSData* _Nullable data);

FOUNDATION_EXPORT NSData* _Nullable ClashProvidersData(void);

FOUNDATION_EXPORT NSData* _Nullable ClashProxiesData(void);

FOUNDATION_EXPORT BOOL ClashSetConfig(NSString* _Nullable uuid, NSError* _Nullable* _Nullable error);

FOUNDATION_EXPORT void ClashSetLogLevel(NSString* _Nullable level);

FOUNDATION_EXPORT void ClashSetTunnelMode(NSString* _Nullable mode);

FOUNDATION_EXPORT void ClashSetup(NSString* _Nullable homeDir, NSString* _Nullable config, id<ClashClient> _Nullable c);

@class ClashClient;

@interface ClashClient : NSObject <goSeqRefInterface, ClashClient> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (void)log:(NSString* _Nullable)level message:(NSString* _Nullable)message;
- (void)traffic:(int64_t)up down:(int64_t)down;
@end

#endif