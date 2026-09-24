#import "LockAnalyzer.h"

#import <libproc.h>
#import <signal.h>

namespace
{
NSString* TrimmedPath(NSString* path)
{
    NSString* normalized = [[path stringByStandardizingPath] copy];
    while (normalized.length > 1 && [normalized hasSuffix:@"/"])
    {
        normalized = [normalized substringToIndex:normalized.length - 1];
    }
    return normalized;
}

NSArray<NSString*>* SplitWhitespaceColumns(NSString* line)
{
    NSArray<NSString*>* rawParts = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSPredicate* nonEmpty = [NSPredicate predicateWithBlock:^BOOL(NSString* value, NSDictionary* _) {
        return value.length > 0;
    }];
    return [rawParts filteredArrayUsingPredicate:nonEmpty];
}
}

@implementation FLALockRecord

- (instancetype)initWithPid:(pid_t)pid
                processName:(NSString*)processName
                processPath:(NSString*)processPath
                 lockedPath:(NSString*)lockedPath
                     source:(NSString*)source
{
    self = [super init];
    if (self != nil)
    {
        _pid = pid;
        _processName = [processName copy];
        _processPath = [processPath copy];
        _lockedPath = [lockedPath copy];
        _source = [source copy];
    }
    return self;
}

- (id)copyWithZone:(NSZone*)zone
{
    return [[FLALockRecord allocWithZone:zone] initWithPid:self.pid
                                               processName:self.processName
                                               processPath:self.processPath
                                                lockedPath:self.lockedPath
                                                    source:self.source];
}

@end

@interface FLALockAnalyzer ()

- (NSString*)processPathForPid:(pid_t)pid;
- (NSArray<FLALockRecord*>*)analyzeFileSystemPath:(NSString*)path isDirectory:(BOOL)isDirectory error:(NSString* _Nullable * _Nullable)errorMessage;

@end

@implementation FLALockAnalyzer

- (NSString*)normalizedPath:(NSString*)path
{
    return TrimmedPath(path);
}

- (NSArray<FLALockRecord*>*)analyzePath:(NSString*)path error:(NSString* _Nullable * _Nullable)errorMessage
{
    NSString* normalized = [self normalizedPath:path];
    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:normalized isDirectory:&isDirectory])
    {
        if (errorMessage != nullptr)
        {
            *errorMessage = [NSString stringWithFormat:@"Path does not exist: %@", normalized];
        }
        return @[];
    }

    return [self analyzeFileSystemPath:normalized isDirectory:isDirectory error:errorMessage];
}

- (BOOL)terminateProcess:(pid_t)pid error:(NSString* _Nullable * _Nullable)errorMessage
{
    if (kill(pid, SIGTERM) == 0)
    {
        return YES;
    }

    if (errorMessage != nullptr)
    {
        *errorMessage = [NSString stringWithFormat:@"Failed to terminate PID %d.", pid];
    }
    return NO;
}

- (NSArray<FLALockRecord*>*)analyzeFileSystemPath:(NSString*)path isDirectory:(BOOL)isDirectory error:(NSString* _Nullable * _Nullable)errorMessage
{
    NSString* lsofPath = [[NSFileManager defaultManager] isExecutableFileAtPath:@"/usr/sbin/lsof"] ? @"/usr/sbin/lsof" : @"/usr/bin/lsof";

    NSTask* task = [[NSTask alloc] init];
    task.launchPath = lsofPath;
    if (isDirectory)
    {
        task.arguments = @[ @"+D", path ];
    }
    else
    {
        task.arguments = @[ path ];
    }

    NSPipe* stdoutPipe = [NSPipe pipe];
    NSPipe* stderrPipe = [NSPipe pipe];
    task.standardOutput = stdoutPipe;
    task.standardError = stderrPipe;

    @try
    {
        [task launch];
        [task waitUntilExit];
    }
    @catch (NSException* exception)
    {
        if (errorMessage != nullptr)
        {
            *errorMessage = [NSString stringWithFormat:@"Failed to launch lsof: %@", exception.reason ?: @"unknown error"];
        }
        return @[];
    }

    NSData* stdoutData = [[stdoutPipe fileHandleForReading] readDataToEndOfFile];
    NSData* stderrData = [[stderrPipe fileHandleForReading] readDataToEndOfFile];
    NSString* stdoutText = [[NSString alloc] initWithData:stdoutData encoding:NSUTF8StringEncoding] ?: @"";
    NSString* stderrText = [[NSString alloc] initWithData:stderrData encoding:NSUTF8StringEncoding] ?: @"";

    if (task.terminationStatus != 0 && stdoutText.length == 0)
    {
        if (errorMessage != nullptr)
        {
            NSString* message = stderrText.length > 0 ? stderrText : @"lsof failed.";
            *errorMessage = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        return @[];
    }

    NSMutableArray<FLALockRecord*>* locks = [NSMutableArray array];
    NSMutableSet<NSString*>* dedup = [NSMutableSet set];
    NSArray<NSString*>* lines = [stdoutText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    for (NSUInteger i = 1; i < lines.count; ++i)
    {
        NSString* line = [lines[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (line.length == 0)
        {
            continue;
        }

        NSArray<NSString*>* columns = SplitWhitespaceColumns(line);
        if (columns.count < 9)
        {
            continue;
        }

        pid_t pid = (pid_t)[columns[1] intValue];
        NSString* lockedPath = [[columns subarrayWithRange:NSMakeRange(8, columns.count - 8)] componentsJoinedByString:@" "];
        NSString* key = [NSString stringWithFormat:@"%d|%@", pid, lockedPath];
        if ([dedup containsObject:key])
        {
            continue;
        }

        [dedup addObject:key];
        FLALockRecord* record = [[FLALockRecord alloc] initWithPid:pid
                                                       processName:columns[0]
                                                       processPath:[self processPathForPid:pid]
                                                        lockedPath:lockedPath
                                                            source:@"lsof"];
        [locks addObject:record];
    }

    if (errorMessage != nullptr)
    {
        *errorMessage = nil;
    }
    return locks;
}

- (NSString*)processPathForPid:(pid_t)pid
{
    char buffer[PROC_PIDPATHINFO_MAXSIZE] = {};
    const int result = proc_pidpath(pid, buffer, sizeof(buffer));
    if (result <= 0)
    {
        return @"";
    }
    return [NSString stringWithUTF8String:buffer] ?: @"";
}

@end
