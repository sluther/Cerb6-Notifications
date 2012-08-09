//
//  AppDelegate.h
//  Cerb6 Notifications
//
//  Created by Scott Luther on 7/30/12.
//  Copyright (c) 2012 WebGroup Media. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, NSTableViewDataSource, NSTableViewDelegate> {
	
	PreferencesWindowController *prefsWindow;
}

// Core Data
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property NSMutableArray *userNotifications;
@property (weak) IBOutlet NSTableView *notificationsTable;

- (IBAction) refresh:(id)sender;
- (IBAction) clearNotifications:(id)sender;
- (IBAction) openPrefs:(id)sender;
- (IBAction) openNotification:(id)sender;
- (IBAction) deleteNotification:(id)sender;

@end