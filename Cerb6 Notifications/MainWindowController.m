//
//  MainWindowController.m
//  Cerb6 Notifications
//
//  Created by Scott on 8/14/12.
//  Copyright (c) 2012 WebGroup Media. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"
#import "Utils.h"

@implementation MainWindowController

//@synthesize userNotifications;

@synthesize notificationsTable;
@synthesize notificationsController;

- (void) doubleClick:(id)sender
{
	NSInteger row = [notificationsTable clickedRow];
	
//	Notification *clickedNotification = [userNotifications objectAtIndex:row];
//	Notification *clickedNotification = 
	
//	[appDelegate redirectToBrowser:clickedNotification];
}

- (id) initWithWindowNibName:(NSString *)windowNibName
{
	self = [super initWithWindowNibName:windowNibName];
	if (self) {
//		[notificationsController setManagedObjectContext:[appDelegate managedObjectContext]];
//		[notificationsController setEntityName:@"Notification"];
//		[notificationsController setAutomaticallyPreparesContent:YES];
//		
//		[notificationsController fetchWithRequest:fetchRequest merge:NO error:&error];
//
//
		appDelegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];
		
		NSSortDescriptor *createdSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
		[notificationsController setSortDescriptors:[NSArray arrayWithObject:createdSortDescriptor]];
//		NSLog(@"%@", appDelegate);

//		NSManagedObjectContext *context = [appDelegate managedObjectContext];
//		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notification" inManagedObjectContext:context];
//		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//		NSError *error = nil;
//		
//		[fetchRequest setEntity:entity];
//		NSMutableArray *userNotifications = [NSMutableArray arrayWithArray:[context executeFetchRequest:fetchRequest error:&error]];
		
//		[notificationsTable reloadData];
	}
	return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
	
	[notificationsTable reloadData];
}

- (void)awakeFromNib
{
	[notificationsTable setTarget:self];
	[notificationsTable setDoubleAction:@selector(doubleClick:)];
}

@end
