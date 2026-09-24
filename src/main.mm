#import <Cocoa/Cocoa.h>

#import "AppDelegate.h"

int main(int argc, const char* argv[])
{
    @autoreleasepool
    {
        NSString* initialPath = nil;
        if (argc > 1 && argv[1] != nullptr)
        {
            initialPath = [NSString stringWithUTF8String:argv[1]];
        }

        NSApplication* app = [NSApplication sharedApplication];
        app.activationPolicy = NSApplicationActivationPolicyRegular;
        FLAAppDelegate* delegate = [[FLAAppDelegate alloc] initWithInitialPath:initialPath];
        app.delegate = delegate;
        [app run];
        return EXIT_SUCCESS;
    }
}
