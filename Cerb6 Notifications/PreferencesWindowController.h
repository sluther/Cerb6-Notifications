//
//  PreferencesWindowController.h
//  Cerb6 Notifications
//
//  Created by Scott Luther on 8/7/12.
//  Copyright (c) 2012 WebGroup Media. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesWindowController : NSWindowController

@property (weak) IBOutlet NSString *url;
@property (weak) IBOutlet NSString *accessKey;
@property (weak) IBOutlet NSString *secretKey;
@property (weak) IBOutlet NSNumber *prettyURLs;

- (void)controlTextDidChange:(NSNotification *)notification;
- (IBAction)togglePrettyURLs:(id)sender;
@end