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
		appDelegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];
//		[notificationsTable reloadData];
	}
	return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
	NSSortDescriptor *sortNotifications = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
	[notificationsController setSortDescriptors:[NSArray arrayWithObject:sortNotifications]];
	[notificationsTable reloadData];
}

- (void)awakeFromNib
{
	[notificationsTable setTarget:self];
	[notificationsTable setDoubleAction:@selector(doubleClick:)];
}

@end
