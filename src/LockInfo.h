#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLALockRecord : NSObject <NSCopying>

@property (nonatomic, assign) pid_t pid;
@property (nonatomic, copy) NSString* processName;
@property (nonatomic, copy) NSString* processPath;
@property (nonatomic, copy) NSString* lockedPath;
@property (nonatomic, copy) NSString* source;

- (instancetype)initWithPid:(pid_t)pid
                processName:(NSString*)processName
                processPath:(NSString*)processPath
                 lockedPath:(NSString*)lockedPath
                     source:(NSString*)source NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
