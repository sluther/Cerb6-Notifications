//
//  AppDelegate.h
//  Cerb6 Notifications
//
//  Created by Scott Luther on 7/30/12.
//  Copyright (c) 2012 WebGroup Media. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindowController.h"
#import "PreferencesWindowController.h"



@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate> {
	MainWindowController *mainWindowController;
	PreferencesWindowController *prefsWindowController;
}

// Core Data
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property NSMutableArray *queuedNotifications;

@property NSMutableArray *sites;

@property NSDockTile *dockIcon;

@property NSStatusItem *statusItem;

@property (weak) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSMenuItem *menuStatusItem;

- (IBAction) clearNotifications:(id)sender;
- (IBAction) deleteNotification:(id)sender;
- (IBAction) openNotification:(id)sender;
- (IBAction) showPrefsWindow:(id)sender;
- (IBAction) refresh:(id)sender;

//- (void) refreshNotifications;
- (void) reloadTableFromStore;
- (void) redirectToBrowser:(Notification *)clickedNotification;

@end
