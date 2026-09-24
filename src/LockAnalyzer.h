#import <Foundation/Foundation.h>

#import "LockInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface FLALockAnalyzer : NSObject

- (NSArray<FLALockRecord*>*)analyzePath:(NSString*)path error:(NSString* _Nullable * _Nullable)errorMessage;
- (BOOL)terminateProcess:(pid_t)pid error:(NSString* _Nullable * _Nullable)errorMessage;
- (NSString*)normalizedPath:(NSString*)path;

@end

NS_ASSUME_NONNULL_END
