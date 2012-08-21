//
//  AppDelegate.m
//  Cerb6 Notifications
//
//  Created by Scott Luther on 7/30/12.
//  Copyright (c) 2012 WebGroup Media. All rights reserved.
//
#import "AppDelegate.h"
#import "Notification.h"
#import "Utils.h"
#import "CJSONDeserializer.h"

@implementation AppDelegate

// Core Data
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

@synthesize queuedNotifications;

@synthesize dockIcon;

@synthesize statusItem;
@synthesize statusMenu;
@synthesize menuStatusItem;

- (IBAction) clearNotifications:(id)sender
{
	mainWindowController.userNotifications = [[NSMutableArray alloc] init];

	NSManagedObjectContext *context = [self managedObjectContext];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notification" inManagedObjectContext:context];

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entity];
	
	NSError *error = nil;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
    for (Notification *notification in items) {
        [context deleteObject:notification];
    }
	
	[self reloadTableFromStore];
}

- (IBAction) deleteNotification:(id)sender
{
	NSInteger selectedRow = [mainWindowController.notificationsTable selectedRow];
	if(selectedRow == -1) {
		return;
	}
	
	Notification *notification = [mainWindowController.userNotifications objectAtIndex:[mainWindowController.notificationsTable selectedRow]];
	
	NSManagedObjectContext *context = [self managedObjectContext];
	[context deleteObject:notification];
	[self reloadTableFromStore];
}

- (IBAction) openNotification:(id)sender
{
	NSInteger selectedRow = [mainWindowController.notificationsTable selectedRow];
	if(selectedRow == -1) {
		return;
	}
	
	Notification *selectedNotification = [mainWindowController.userNotifications objectAtIndex:[mainWindowController.notificationsTable selectedRow]];
	
	[self redirectToBrowser:selectedNotification];
}

- (IBAction) refresh:(id)sender
{
	[self refreshNotifications];
}

- (IBAction) showMainWindow:(id)sender
{
	[self openMainWindow];
}

- (IBAction) showPrefsWindow:(id)sender
{
	prefsWindowController = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindow"];
	[[prefsWindowController window] makeKeyAndOrderFront:self];
}

- (void) deliverQueuedNotifications
{
	NSInteger count = [queuedNotifications count];
	if(count != 0) {
		for(NSInteger i = 0; i < count; i++) {
			
			Notification *queuedNotification = [queuedNotifications objectAtIndex:i];
			
			NSInteger loc = [mainWindowController.userNotifications indexOfObject:queuedNotification];
			
			NSNumber *location = [NSNumber numberWithInteger:loc];
			NSDictionary *notificationInfo = [[NSDictionary alloc] initWithObjectsAndKeys:location, @"loc", nil];
			[self deliverNotificationWithTitle:@"Cerb6 Notification" message:queuedNotification.message notificationInfo:notificationInfo];
		}
		
		[queuedNotifications removeAllObjects];
	}
}

- (void) openMainWindow
{
	[[mainWindowController window] makeKeyAndOrderFront:self];
}

- (void) redirectToBrowser:(Notification *)notification
{
	NSManagedObjectContext *context = [self managedObjectContext];
	
	NSError *error = nil;
	
	notification.isRead = [NSNumber numberWithInt:1];
	
	if(![context save:&error]) {
		NSLog(@"%@", error);
	}
	
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:notification.urlMarkRead]];
	
	[self reloadTableFromStore];
}

- (void) reloadTableFromStore
{
	NSManagedObjectContext *context = [self managedObjectContext];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notification" inManagedObjectContext:context];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSError *error = nil;
	
	[fetchRequest setEntity:entity];
	
	NSMutableArray *userNotifications = [NSMutableArray arrayWithArray:[context executeFetchRequest:fetchRequest error:&error]];
	
	NSInteger unreadNotifications = 0;
	NSInteger totalnotifications = [userNotifications count];
	
	// Count unread notifications for dock icon/status menu item
	for(NSInteger i = 0; i < totalnotifications; i++) {
		Notification *notification = [userNotifications objectAtIndex:i];
		if([notification.isRead boolValue] == NO) {
			unreadNotifications++;
		}
	}
	
	NSString *badgeLabel = [[NSString alloc] initWithFormat:@"%ld", unreadNotifications];
	[[self dockIcon] setBadgeLabel:badgeLabel];
	mainWindowController.userNotifications = userNotifications;
	[mainWindowController.notificationsTable reloadData];
}

- (void) refreshNotifications
{
//	printf("Refreshing notifications...\n");
	NSUserDefaults *site = [NSUserDefaults standardUserDefaults];
	
	NSURL *url = [NSURL URLWithString:[site objectForKey:@"url"]];
	NSString *accessKey = [site objectForKey:@"accessKey"];
	NSString *secretKey = [site objectForKey:@"secretKey"];
	
	if(url == nil || accessKey == nil || secretKey == nil) {
		return;
	}
	
	NSString *path = @"";
	
	if (![[[url path] substringFromIndex: [[url path] length] -1] isEqualToString:@"/"] ) {
		path = @"/rest/notifications/list.json";
	} else {
		path = @"rest/notifications/list.json";
	}
	
	NSString *query = @"unread=1";
	
	NSURL *fullUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?%@", url, path, query]];
	
	NSDictionary *request = [NSDictionary dictionaryWithObjectsAndKeys:fullUrl, @"url", accessKey, @"access_key", secretKey, @"secret_key", nil];
	
	NSError *error = nil;
	NSString *response = [self request:request];
	
	NSData *jsonString = [response dataUsingEncoding:NSUTF8StringEncoding];
	NSDictionary *jsonDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonString error:&error];
	//	NSLog(@"%@", response);
	
	// Not needed?
	//	NSString *resultCountString = (NSString *) [jsonDict objectForKey:@"count"];
	//	int resultCount = [resultCountString intValue];
	
	NSDictionary *results = [jsonDict objectForKey:@"results"];
	
	NSManagedObjectContext *context = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notification" inManagedObjectContext:context];
	
	[fetchRequest setEntity:entity];
	
	for (id key in results) {
		NSDictionary *notificationDict = [results objectForKey:key];
//		NSLog(@"%@", [results objectForKey:key]);
		
		NSNumber *notificationId = [[NSNumber alloc] initWithInteger:[[[NSString alloc] initWithString:[notificationDict objectForKey:@"id"]] integerValue]];
		NSString *message = [notificationDict objectForKey:@"message"];
		NSString *url = [notificationDict objectForKey:@"url"];
		NSString *urlMarkRead = [notificationDict objectForKey:@"url_markread"];
		NSNumber *isRead = [[NSNumber alloc] initWithBool:[[[NSString alloc] initWithString:[notificationDict objectForKey:@"is_read"]] integerValue]];
		NSNumber *created = [[NSNumber alloc] initWithInteger:[[[NSString alloc] initWithString: [notificationDict objectForKey:@"created"]] integerValue]];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"notificationId == %@", notificationId];
		[fetchRequest setPredicate:predicate];
		
		NSError *error = nil;
		NSArray *notificationResults = [context executeFetchRequest:fetchRequest error:&error];
		
//		NSLog(@"%@", notificationResults);
		// Does the notification already exist? If so, update it.
		if([notificationResults count] == 0) {
			Notification *notification = [NSEntityDescription insertNewObjectForEntityForName:@"Notification" inManagedObjectContext:context];
			
			notification.notificationId = notificationId;
			notification.message = message;
			notification.url = url;
			notification.urlMarkRead = urlMarkRead;
			notification.isRead = isRead;
			notification.created = created;
			
			[queuedNotifications addObject:notification];
			
//			NSLog(@"%@", notification);
		} else {
			// Only one notification per id, so grab the first one in the result set
			Notification *notification = [notificationResults objectAtIndex:0];
			
			// Update the isRead bit
			notification.isRead = isRead;
		}
		
		if(![context save:&error]) {
			NSLog(@"%@", error);
		}
	}
	
	[self reloadTableFromStore];
	[self deliverQueuedNotifications];
}

- (NSString *) request:(NSDictionary *)request
{
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[request objectForKey:@"url"]];
	[urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	[urlRequest addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	
	// Date (RFC822)
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEE, dd MMM yy HH:mm:ss Z"];
	[dateFormatter setTimeZone:[[NSTimeZone alloc] initWithName:@"GMT"]];
	NSString *strHttpDate = [dateFormatter stringFromDate:[NSDate date]];
	
	[urlRequest addValue:strHttpDate forHTTPHeaderField:@"Date"];
	
	NSString *accessKey = (NSString *) [request objectForKey:@"access_key"];
	NSString *secretKey = (NSString *) [request objectForKey:@"secret_key"];
	
	// Signature
	NSString *strToSign = [NSString stringWithFormat:
							   @"%@\n" // verb
							   @"%@\n" // date
							   @"%@\n" // url path
							   @"%@\n" // url query
							   @"%@\n" // payload
							   @"%@\n" // secret
							   ,
							   @"GET",
							   strHttpDate,
							   [[request objectForKey:@"url"] path],
							   [[request objectForKey:@"url"] query],
							   @"",
							   [Utils md5FromString: secretKey]
						   ];
	
	NSString *strHash = [NSString stringWithString: [Utils md5FromString:strToSign]];
	
	[urlRequest addValue:[NSString stringWithFormat:@"%@:%@",accessKey,strHash] forHTTPHeaderField:@"Cerb5-Auth"];
	
	// HTTP Connection
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
	
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	
	if(!urlData) {
		NSLog(@"There was an error with the JSON");
		//return;
	}
	return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}

//- (BOOL) applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
//{
//	if(flag==NO) {
//		[self openMainWindow];
//	}
//	return YES;
//}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	queuedNotifications = [[NSMutableArray alloc] init];
	dockIcon = [[NSDockTile alloc] init];
	mainWindowController = [[MainWindowController alloc] initWithWindowNibName:@"MainWindow"];
	
	// Register timer
	NSTimeInterval seconds = 300;
	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(refreshNotifications) userInfo:nil repeats:YES];
	[timer fire];
	
	// Register status bar
	NSStatusBar *statusBar = [[NSStatusBar alloc] init];
	
	// Make the status item
	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
	
	// Grab the image
	NSImage *statusIcon = [NSImage imageNamed:@"Cerby.png"];
	
	// Make a square based on the thickness of the statusBar
	NSSize statusItemSize = NSMakeSize(statusBar.thickness, statusBar.thickness-3);
	NSImage *statusImage = [statusIcon copy];
	[statusImage setScalesWhenResized: YES];
	[statusImage setSize: statusItemSize];
	
	// Setup the statusItem
	[statusItem setImage: statusImage];
	[statusItem setHighlightMode:YES];
	[statusItem setMenu:statusMenu];
	[self openMainWindow];
}

- (void)deliverNotificationWithTitle:(NSString *)title message:(NSString *)message notificationInfo:(NSDictionary *)notificationInfo
{
	NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
	NSUserNotification *userNotification = nil;
	
	userNotification = [NSUserNotification new];
	userNotification.title = title;
//	userNotification.subtitle = @"Test";
	userNotification.informativeText = message;
	userNotification.userInfo = notificationInfo;
	
	center.delegate = self;
	[center scheduleNotification:userNotification];
}

- (void) userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)clickedNotification
{
	[[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:clickedNotification];
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[[clickedNotification.userInfo objectForKey:@"loc"] integerValue]];
	
	
	[mainWindowController.notificationsTable selectRowIndexes:indexSet byExtendingSelection:NO];
}

- (BOOL) userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)userNotitification
{
	//	printf("* Notification presented.");
	return YES;
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.webgroupmedia.Cerb6_Notifications" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.webgroupmedia.Cerb6_Notifications"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Cerb6_Notifications" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Cerb6_Notifications.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
	
    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
		
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
		
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
		
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
	
    return NSTerminateNow;
}

@end