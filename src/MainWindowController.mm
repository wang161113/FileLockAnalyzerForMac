#import "MainWindowController.h"

#import "LockAnalyzer.h"

@interface FLAMainWindowController () <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) NSTextField* pathField;
@property (nonatomic, strong) NSTableView* tableView;
@property (nonatomic, strong) NSTextField* statusLabel;
@property (nonatomic, strong) NSArray<FLALockRecord*>* locks;
@property (nonatomic, strong) FLALockAnalyzer* analyzer;

@end

@implementation FLAMainWindowController

- (instancetype)init
{
    NSRect frame = NSMakeRect(0.0, 0.0, 1040.0, 680.0);
    NSWindow* window = [[NSWindow alloc] initWithContentRect:frame
                                                   styleMask:(NSWindowStyleMaskTitled |
                                                              NSWindowStyleMaskClosable |
                                                              NSWindowStyleMaskMiniaturizable |
                                                              NSWindowStyleMaskResizable)
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
    self = [super initWithWindow:window];
    if (self != nil)
    {
        _locks = @[];
        _analyzer = [[FLALockAnalyzer alloc] init];
        [self buildUi];
    }
    return self;
}

- (void)buildUi
{
    self.window.title = @"File Lock Analyzer (macOS)";
    self.window.minSize = NSMakeSize(860.0, 520.0);

    NSView* contentView = self.window.contentView;
    contentView.wantsLayer = YES;

    NSTextField* pathLabel = [self makeLabel:@"Path:"];
    self.pathField = [[NSTextField alloc] initWithFrame:NSZeroRect];
    self.pathField.translatesAutoresizingMaskIntoConstraints = NO;
    self.pathField.placeholderString = @"Select a file or folder";
    self.pathField.target = self;
    self.pathField.action = @selector(analyzeAction:);

    NSButton* fileButton = [self makeButton:@"File..." action:@selector(browseFileAction:)];
    NSButton* folderButton = [self makeButton:@"Folder..." action:@selector(browseFolderAction:)];
    NSButton* analyzeButton = [self makeButton:@"Analyze" action:@selector(analyzeAction:)];
    NSButton* terminateButton = [self makeButton:@"Terminate Process" action:@selector(terminateAction:)];
    NSButton* refreshButton = [self makeButton:@"Refresh" action:@selector(refreshAction:)];
    NSButton* revealButton = [self makeButton:@"Reveal In Finder" action:@selector(revealAction:)];

    NSScrollView* scrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.hasVerticalScroller = YES;
    scrollView.hasHorizontalScroller = YES;
    scrollView.borderType = NSBezelBorder;

    self.tableView = [[NSTableView alloc] initWithFrame:NSZeroRect];
    self.tableView.usesAlternatingRowBackgroundColors = YES;
    self.tableView.allowsEmptySelection = YES;
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self addColumnWithIdentifier:@"pid" title:@"PID" width:90.0];
    [self addColumnWithIdentifier:@"process" title:@"Process" width:170.0];
    [self addColumnWithIdentifier:@"processPath" title:@"Process Path" width:300.0];
    [self addColumnWithIdentifier:@"lockedPath" title:@"Locked Path" width:320.0];
    [self addColumnWithIdentifier:@"source" title:@"Source" width:120.0];
    scrollView.documentView = self.tableView;

    self.statusLabel = [self makeLabel:@"Ready"];
    self.statusLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    [contentView addSubview:pathLabel];
    [contentView addSubview:self.pathField];
    [contentView addSubview:fileButton];
    [contentView addSubview:folderButton];
    [contentView addSubview:analyzeButton];
    [contentView addSubview:scrollView];
    [contentView addSubview:terminateButton];
    [contentView addSubview:refreshButton];
    [contentView addSubview:revealButton];
    [contentView addSubview:self.statusLabel];

    NSDictionary* views = @{
        @"pathLabel": pathLabel,
        @"pathField": self.pathField,
        @"fileButton": fileButton,
        @"folderButton": folderButton,
        @"analyzeButton": analyzeButton,
        @"scrollView": scrollView,
        @"terminateButton": terminateButton,
        @"refreshButton": refreshButton,
        @"revealButton": revealButton,
        @"statusLabel": self.statusLabel
    };

    [NSLayoutConstraint activateConstraints:@[
        [pathLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20.0],
        [pathLabel.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:20.0],

        [self.pathField.leadingAnchor constraintEqualToAnchor:pathLabel.trailingAnchor constant:8.0],
        [self.pathField.centerYAnchor constraintEqualToAnchor:pathLabel.centerYAnchor],

        [fileButton.leadingAnchor constraintEqualToAnchor:self.pathField.trailingAnchor constant:8.0],
        [fileButton.centerYAnchor constraintEqualToAnchor:self.pathField.centerYAnchor],

        [folderButton.leadingAnchor constraintEqualToAnchor:fileButton.trailingAnchor constant:8.0],
        [folderButton.centerYAnchor constraintEqualToAnchor:self.pathField.centerYAnchor],

        [analyzeButton.leadingAnchor constraintEqualToAnchor:folderButton.trailingAnchor constant:8.0],
        [analyzeButton.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20.0],
        [analyzeButton.centerYAnchor constraintEqualToAnchor:self.pathField.centerYAnchor],

        [scrollView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20.0],
        [scrollView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20.0],
        [scrollView.topAnchor constraintEqualToAnchor:self.pathField.bottomAnchor constant:16.0],

        [terminateButton.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20.0],
        [terminateButton.topAnchor constraintEqualToAnchor:scrollView.bottomAnchor constant:14.0],

        [refreshButton.leadingAnchor constraintEqualToAnchor:terminateButton.trailingAnchor constant:10.0],
        [refreshButton.centerYAnchor constraintEqualToAnchor:terminateButton.centerYAnchor],

        [revealButton.leadingAnchor constraintEqualToAnchor:refreshButton.trailingAnchor constant:10.0],
        [revealButton.centerYAnchor constraintEqualToAnchor:terminateButton.centerYAnchor],

        [self.statusLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20.0],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20.0],
        [self.statusLabel.topAnchor constraintEqualToAnchor:terminateButton.bottomAnchor constant:14.0],
        [self.statusLabel.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-16.0],

        [scrollView.bottomAnchor constraintEqualToAnchor:terminateButton.topAnchor constant:-14.0],
        [self.pathField.widthAnchor constraintGreaterThanOrEqualToConstant:260.0],
    ]];

    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[analyzeButton(>=88)]"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:views]];
}

- (NSTextField*)makeLabel:(NSString*)text
{
    NSTextField* label = [[NSTextField alloc] initWithFrame:NSZeroRect];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.bezeled = NO;
    label.drawsBackground = NO;
    label.editable = NO;
    label.selectable = NO;
    label.stringValue = text;
    return label;
}

- (NSButton*)makeButton:(NSString*)title action:(SEL)action
{
    NSButton* button = [NSButton buttonWithTitle:title target:self action:action];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.bezelStyle = NSBezelStyleRounded;
    return button;
}

- (void)addColumnWithIdentifier:(NSString*)identifier title:(NSString*)title width:(CGFloat)width
{
    NSTableColumn* column = [[NSTableColumn alloc] initWithIdentifier:identifier];
    column.title = title;
    column.width = width;
    column.minWidth = 80.0;
    [self.tableView addTableColumn:column];
}

- (void)analyzeProvidedPath:(NSString*)path
{
    if (path.length > 0)
    {
        self.pathField.stringValue = path;
    }
    [self analyzeCurrentPath];
}

- (void)browseFileAction:(id)sender
{
    (void)sender;
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = YES;
    panel.canChooseDirectories = NO;
    panel.allowsMultipleSelection = NO;
    if ([panel runModal] == NSModalResponseOK)
    {
        self.pathField.stringValue = panel.URL.path ?: @"";
        [self analyzeCurrentPath];
    }
}

- (void)browseFolderAction:(id)sender
{
    (void)sender;
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = NO;
    panel.canChooseDirectories = YES;
    panel.allowsMultipleSelection = NO;
    if ([panel runModal] == NSModalResponseOK)
    {
        self.pathField.stringValue = panel.URL.path ?: @"";
        [self analyzeCurrentPath];
    }
}

- (void)analyzeAction:(id)sender
{
    (void)sender;
    [self analyzeCurrentPath];
}

- (void)refreshAction:(id)sender
{
    (void)sender;
    [self analyzeCurrentPath];
}

- (void)revealAction:(id)sender
{
    (void)sender;
    NSString* path = [self.pathField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (path.length == 0)
    {
        [self showAlertWithMessage:@"Please choose a file or folder first." informativeText:@""];
        return;
    }

    NSURL* url = [NSURL fileURLWithPath:path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[ url ]];
    }
}

- (void)terminateAction:(id)sender
{
    (void)sender;
    NSInteger row = self.tableView.selectedRow;
    if (row < 0 || row >= (NSInteger)self.locks.count)
    {
        [self showAlertWithMessage:@"Please select one process row first." informativeText:@""];
        return;
    }

    FLALockRecord* record = self.locks[(NSUInteger)row];
    NSAlert* confirm = [[NSAlert alloc] init];
    confirm.messageText = [NSString stringWithFormat:@"Terminate %@ (PID %d)?", record.processName, record.pid];
    [confirm addButtonWithTitle:@"Terminate"];
    [confirm addButtonWithTitle:@"Cancel"];
    if ([confirm runModal] != NSAlertFirstButtonReturn)
    {
        return;
    }

    NSString* errorMessage = nil;
    if (![self.analyzer terminateProcess:record.pid error:&errorMessage])
    {
        [self showAlertWithMessage:errorMessage ?: @"Failed to terminate process." informativeText:@""];
        return;
    }

    [self analyzeCurrentPath];
}

- (void)analyzeCurrentPath
{
    NSString* inputPath = [self.pathField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (inputPath.length == 0)
    {
        [self showAlertWithMessage:@"Please choose a file or folder first." informativeText:@""];
        return;
    }

    self.statusLabel.stringValue = @"Analyzing...";
    [self.statusLabel display];

    NSString* errorMessage = nil;
    self.locks = [self.analyzer analyzePath:inputPath error:&errorMessage];
    [self.tableView reloadData];

    if (errorMessage.length > 0)
    {
        self.statusLabel.stringValue = errorMessage;
        [self showAlertWithMessage:errorMessage informativeText:inputPath];
        return;
    }

    self.statusLabel.stringValue = [NSString stringWithFormat:@"Detected %lu lock owner(s).", (unsigned long)self.locks.count];
    if (self.locks.count == 0)
    {
        [self showAlertWithMessage:@"No locks detected." informativeText:inputPath];
    }
}

- (void)showAlertWithMessage:(NSString*)message informativeText:(NSString*)informativeText
{
    NSAlert* alert = [[NSAlert alloc] init];
    alert.messageText = message ?: @"";
    alert.informativeText = informativeText ?: @"";
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView*)tableView
{
    (void)tableView;
    return (NSInteger)self.locks.count;
}

- (nullable id)tableView:(NSTableView*)tableView
 objectValueForTableColumn:(nullable NSTableColumn*)tableColumn
                      row:(NSInteger)row
{
    (void)tableView;
    if (tableColumn == nil || row < 0 || row >= (NSInteger)self.locks.count)
    {
        return @"";
    }

    FLALockRecord* record = self.locks[(NSUInteger)row];
    NSString* identifier = tableColumn.identifier;
    if ([identifier isEqualToString:@"pid"])
    {
        return @(record.pid);
    }
    if ([identifier isEqualToString:@"process"])
    {
        return record.processName;
    }
    if ([identifier isEqualToString:@"processPath"])
    {
        return record.processPath;
    }
    if ([identifier isEqualToString:@"lockedPath"])
    {
        return record.lockedPath;
    }
    if ([identifier isEqualToString:@"source"])
    {
        return record.source;
    }
    return @"";
}

@end
