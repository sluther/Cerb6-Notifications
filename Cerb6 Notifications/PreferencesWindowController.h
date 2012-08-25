//
//  PreferencesWindowController.h
//  Cerb6 Notifications
//
//  Created by Scott Luther on 8/7/12.
//  Copyright (c) 2012 WebGroup Media. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Site.h"

@class AppDelegate;

@interface PreferencesWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate> {
	AppDelegate <NSApplicationDelegate> *appDelegate;
	IBOutlet NSPanel *siteSheet;
}

//- (void)controlTextDidChange:(NSNotification *)notification;

@property IBOutlet NSTableView *sitesTable;

@property IBOutlet NSTextField *name;
@property IBOutlet NSTextField *url;
@property IBOutlet NSTextField *accessKey;
@property IBOutlet NSTextField *secretKey;

- (IBAction) closeSiteSheet:(id)sender;
- (IBAction) showSiteSheet:(id)sender;

@end
