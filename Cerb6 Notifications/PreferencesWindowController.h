//
//  PreferencesWindowController.h
//  Cerb6 Notifications
//
//  Created by Scott Luther on 8/7/12.
//  Copyright (c) 2012 WebGroup Media. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesWindowController : NSWindowController {
	IBOutlet NSPanel *siteSheet;
}

- (void)controlTextDidChange:(NSNotification *)notification;

- (IBAction) closeSiteSheet:(id)sender;
- (IBAction) showSiteSheet:(id)sender;

@end
