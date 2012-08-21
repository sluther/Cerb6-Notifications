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

@interface MainWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate> {
	AppDelegate <NSApplicationDelegate> *appDelegate;
}

@property NSMutableArray *userNotifications;

@property (weak) IBOutlet NSTableView *notificationsTable;

@end
