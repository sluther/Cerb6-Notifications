//
//  PreferencesWindowController.m
//  Cerb6 Notifications
//
//  Created by Scott Luther on 8/7/12.
//  Copyright (c) 2012 WebGroup Media. All rights reserved.
//

#import "PreferencesWindowController.h"

@implementation PreferencesWindowController

@synthesize url;
@synthesize accessKey;
@synthesize secretKey;
@synthesize prettyURLs;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }

    return self;
}

- (void)windowDidLoad
{
	NSLog(@"%@", prettyURLs);
    [super windowDidLoad];

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (IBAction)togglePrettyURLs:(id)sender {
	NSLog(@"%@", sender);
}

- (void)controlTextDidChange:(NSNotification *)notification
{
	NSLog(@"%@", notification);
//	[portSelection selectCellAtRow:2 column:1];
//	[[NSUserDefaults standardUserDefaults] setValue:@"2" forKey:@"portSelection"];
	
	
}

@end
