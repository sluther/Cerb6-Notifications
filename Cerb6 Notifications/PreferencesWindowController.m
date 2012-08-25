//
//  PreferencesWindowController.m
//  Cerb6 Notifications
//
//  Created by Scott Luther on 8/7/12.
//  Copyright (c) 2012 WebGroup Media. All rights reserved.
//

#import "PreferencesWindowController.h"

@implementation PreferencesWindowController

- (IBAction) closeSiteSheet:(id)sender
{
	[NSApp endSheet:siteSheet];
	[siteSheet orderOut:sender];
}

- (IBAction) showSiteSheet:(id)sender
{
	[NSApp beginSheet:siteSheet modalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (id)initWithWindow:(NSWindow *)window
- (id) initWithWindowNibName:(NSString *)windowNibName
{
	self = [super initWithWindowNibName:windowNibName];
    if (self) {
        // Initialization code here.
    }
	return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)controlTextDidChange:(NSNotification *)notification
{
//	NSLog(@"%@", notification);
////	[portSelection selectCellAtRow:2 column:1];
////	[[NSUserDefaults standardUserDefaults] setValue:@"2" forKey:@"portSelection"];
//	
//	
}

@end
