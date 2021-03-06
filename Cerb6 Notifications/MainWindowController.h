//
//  MainWindowController.h
//  Cerb6 Notifications
//
//  Created by Scott on 8/14/12.
//  Copyright (c) 2012 WebGroup Media. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Notification.h"

@class AppDelegate;

@interface MainWindowController : NSWindowController  {
	AppDelegate <NSApplicationDelegate> *appDelegate;
}

@property (weak) IBOutlet NSTableView *notificationsTable;
@property (weak) IBOutlet NSArrayController *notificationsController;

@end
