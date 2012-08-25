//
//  PreferencesWindowController.m
//  Cerb6 Notifications
//
//  Created by Scott Luther on 8/7/12.
//  Copyright (c) 2012 WebGroup Media. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "AppDelegate.h"

@implementation PreferencesWindowController

@synthesize sitesTable;

@synthesize name;
@synthesize url;
@synthesize accessKey;
@synthesize secretKey;

- (IBAction) closeSiteSheet:(id)sender
{
	[self closeSheet];
}

- (IBAction) saveSite:(id)sender
{
	
	[self closeSheet];
}

- (IBAction) showSiteSheet:(id)sender
{
	[NSApp beginSheet:siteSheet modalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (void) closeSheet {
	[NSApp endSheet:siteSheet];
	[siteSheet orderOut:self];
}

- (void) doubleClick:(id)sender
{
	NSInteger row = [sitesTable clickedRow];
	
	Site *site = [[appDelegate sites] objectAtIndex:row];
	
	// edit site
}

- (id) initWithWindowNibName:(NSString *)windowNibName
{
	self = [super initWithWindowNibName:windowNibName];
    if (self) {
		appDelegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];
    }
	return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
	[sitesTable reloadData];
}

- (void)controlTextDidChange:(NSNotification *)notification
{

}

- (void)awakeFromNib
{
	[sitesTable setTarget:self];
	[sitesTable setDoubleAction:@selector(doubleClick:)];
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
	NSLog(@"%@", [appDelegate sites]);
	return [[appDelegate sites] count];
}

- (NSView *) tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	
	if([appDelegate sites] == nil) {
		return nil;
	}
	
	// Grab the column identifier
	NSString *identifier = tableColumn.identifier;
	NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
	
	Site *site = [[appDelegate sites] objectAtIndex:row];
	
	cellView.textField.stringValue = site.name;
//	if([identifier isEqualToString:@"site"]) {
//		Site *site = notification.site;
//		cellView.textField.stringValue = [[NSString alloc] initWithFormat:@"%@", site.name];
//	} else if([identifier isEqualToString:@"created"]) {
//		cellView.textField.stringValue = [Utils prettySecs:notification.created];
//	} else if ([identifier isEqualToString:@"message"]) {
//		cellView.textField.stringValue = notification.message;
//	}
	
	return cellView;
}

@end
