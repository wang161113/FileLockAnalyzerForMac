#import "AppDelegate.h"

#import "MainWindowController.h"

@interface FLAAppDelegate ()

@property (nonatomic, copy, nullable) NSString* initialPath;
@property (nonatomic, strong) FLAMainWindowController* mainWindowController;

@end

@implementation FLAAppDelegate

- (instancetype)initWithInitialPath:(NSString*)initialPath
{
    self = [super init];
    if (self != nil)
    {
        _initialPath = [initialPath copy];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
    (void)notification;
    self.mainWindowController = [[FLAMainWindowController alloc] init];
    [self.mainWindowController showWindow:self];
    [NSApp activateIgnoringOtherApps:YES];

    if (self.initialPath.length > 0)
    {
        [self.mainWindowController analyzeProvidedPath:self.initialPath];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender
{
    (void)sender;
    return YES;
}

@end
