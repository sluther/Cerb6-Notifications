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

@synthesize userNotifications;
@synthesize notificationsTable;

- (IBAction) openPrefs:(id)sender
{
	prefsWindow = [[PreferencesWindowController alloc] initWithWindowNibName:@"Preferences"];
	[[prefsWindow window] makeKeyAndOrderFront:self];
}
- (IBAction) clearNotifications:(id)sender
{
	[_managedObjectContext reset];
	userNotifications = [[NSMutableArray alloc] init];
	[notificationsTable reloadData];
}
- (IBAction) refresh:(id)sender
{
	[self refreshNotifications];
}

- (IBAction) openNotification:(id)sender
{
	NSInteger selectedRow = [notificationsTable selectedRow];
	NSLog(@"%ld", selectedRow);
	if(selectedRow == -1) {
		return;
	}
	
	Notification *notification = [userNotifications objectAtIndex:[notificationsTable selectedRow]];
	NSLog(@"%@", notification);
	
	NSManagedObjectContext *context = [self managedObjectContext];
	
	NSError *error = nil;
	
	notification.isRead = [NSNumber numberWithInt:1];
	
	if(![context save:&error]) {
		NSLog(@"%@", error);
	}
	
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:notification.urlMarkRead]];
	[self refreshNotifications];
}
- (void) refreshNotifications
{
	printf("Refreshing notifications...\n");
	NSUserDefaults *site = [NSUserDefaults standardUserDefaults];
	
	NSURL *url = [NSURL URLWithString:[site objectForKey:@"url"]];
	NSString *accessKey = [site objectForKey:@"accessKey"];
	NSString *secretKey = [site objectForKey:@"secretKey"];
	
	if(url == nil || accessKey == nil || secretKey == nil)
	{
		return;
	}
	
	NSString *path = @"";
	
	if (![[[url path] substringFromIndex: [[url path] length] -1] isEqualToString:@"/"] )
	{
		path = @"/rest/notifications/list.json";
	} else {
		path = @"rest/notifications/list.json";
	}
	
	NSString *query = @"unread=1";
	
	NSURL *fullUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?%@", url, path, query]];
	
	NSLog(@"%@", fullUrl);
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
		
		NSLog(@"%@", notificationResults);
		// Does the notification already exist? If so, update it.
		if([notificationResults count] == 0) {
			Notification *notification = [NSEntityDescription insertNewObjectForEntityForName:@"Notification" inManagedObjectContext:context];
			
			notification.notificationId = notificationId;
			notification.message = message;
			notification.url = url;
			notification.urlMarkRead = urlMarkRead;
			notification.isRead = isRead;
			notification.created = created;

			[self deliverNotificationWithTitle:@"Cerb6" message:message];
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
	[fetchRequest setPredicate:nil];
	userNotifications = [NSMutableArray arrayWithArray:[context executeFetchRequest:fetchRequest error:&error]];
	
	[notificationsTable reloadData];
}

- (NSString *)request:(NSDictionary *)request
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


- (void)applicationDidFinishLaunching:(NSNotification *)clickedNotification
{
	
	userNotifications = [[NSMutableArray alloc] init];
	
	NSUserNotification *userNotification = clickedNotification.userInfo[NSApplicationLaunchUserNotificationKey];
	
	//	self.userNotifications = [NSMutableDictionary new];
	
	if(userNotification) {
		[self userActivatedNotification:userNotification];
	} else {
//		[self refreshNotifications];
		
		//		NSString *message = @"Test";
		//		NSNumber *notificationId = [NSNumber numberWithInt:1];
		//		for(int i = 1; i < 11; i++) {
		//			NSMutableDictionary *notification = [[NSMutableDictionary alloc] init];
		//			notificationId = [NSNumber numberWithInt:i];
		//			[notification setObject:notificationId forKey:@"notificationId"];
		//			[notification setObject:message forKey:@"message"];
		//			[userNotifications addObject:notification];
		//		}
		
		//	NSTimeInterval *seconds = [[NSNumber alloc] initWithInt:300];
		NSTimeInterval seconds = 300;
		NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(refreshNotifications) userInfo:nil repeats:YES];
		[timer fire];
	}

}

- (void)deliverNotificationWithTitle:(NSString *)title
							 message:(NSString *)message
{
	
	NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
	NSUserNotification *userNotification = nil;
	
	userNotification = [NSUserNotification new];
	userNotification.title = title;
	userNotification.informativeText = message;
	
	center.delegate = self;
	[center scheduleNotification:userNotification];
}

- (void)userActivatedNotification:(NSUserNotification *)userNotification
{
    //	[[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:userNotification];
	
	printf("* User activated notification:");
    //	NSLog(@"Title: %@", userNotification.title);just do it in
    //	NSLog(@"Message: %@", userNotification.informativeText);
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"https://www.google.com/"]];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
	 shouldPresentNotification:(NSUserNotification *)userNotitification
{
	//	printf("* Notification presented.");
	return YES;
}


- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
	return [userNotifications count];
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if(userNotifications == nil) {
		return @"empty";
	}
	
	// Grab the column identifier
	NSString *columnIdentifier = tableColumn.identifier;
//	NSString *key = [[[userNotifications keyEnumerator] allObjects] objectAtIndex:row];
	
	Notification *notification = [userNotifications objectAtIndex:row];
	
	NSString *cellData = @"";
//	NSLog(@"%@", columnIdentifier);
	if([columnIdentifier isEqualTo:@"created"]) {
		cellData = [Utils prettySecs:notification.created];
	} else if ([columnIdentifier isEqualTo:@"message"]) {
		cellData = notification.message;
	} else {
//		cellData = notification.url;
		cellData = @"empty";
	}

	return cellData;
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