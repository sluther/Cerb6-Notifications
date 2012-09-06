//
//  PreferencesWindowController.h
//  Cerb6 Notifications
//
//  Created by Scott Luther on 8/7/12.
//  Copyright (c) 2012 WebGroup Media. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppDelegate;

@interface PreferencesWindowController : NSWindowController {
	AppDelegate <NSApplicationDelegate> *appDelegate;
	IBOutlet NSPanel *siteSheet;
}

//- (void)controlTextDidChange:(NSNotification *)notification;

@property IBOutlet NSTableView *sitesTable;
@property (weak) IBOutlet NSArrayController *sitesController;

@property IBOutlet NSTextField *name;
@property IBOutlet NSTextField *url;
@property IBOutlet NSTextField *accessKey;
@property IBOutlet NSTextField *secretKey;

- (IBAction) closeSiteSheet:(id)sender;
- (IBAction) addSite:(id)sender;
- (IBAction) saveSite:(id)sender;
- (IBAction) editSite:(id)sender;
- (IBAction) deleteSite:(id)sender;
@end
