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

@synthesize userNotifications;

@synthesize notificationsTable;

- (void) doubleClick:(id)sender
{
	NSInteger row = [notificationsTable clickedRow];
	
	Notification *clickedNotification = [userNotifications objectAtIndex:row];
	
	[appDelegate redirectToBrowser:clickedNotification];
}

- (id) initWithWindowNibName:(NSString *)windowNibName
{
	self = [super initWithWindowNibName:@"MainWindow"];
    if (self) {
		userNotifications = [[NSMutableArray alloc] init];
		appDelegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];
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

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
	return [userNotifications count];
}

- (NSView *) tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	
	if(userNotifications == nil) {
		return nil;
	}
	
	// Grab the column identifier
	NSString *identifier = tableColumn.identifier;
	NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
	
	Notification *notification = [userNotifications objectAtIndex:row];
	if([notification.isRead boolValue] == NO) {
		[[cellView textField] setFont:[NSFont boldSystemFontOfSize:12]];
	} else {
		[[cellView textField] setFont:[NSFont systemFontOfSize:12]];
	}
	
	if([identifier isEqualToString:@"site"]) {
		Site *site = notification.site;
		cellView.textField.stringValue = [[NSString alloc] initWithFormat:@"%@", site.name];
	} else if([identifier isEqualToString:@"created"]) {
		cellView.textField.stringValue = [Utils prettySecs:notification.created];
	} else if ([identifier isEqualToString:@"message"]) {
		cellView.textField.stringValue = notification.message;
	}
	
	return cellView;
}

@end
