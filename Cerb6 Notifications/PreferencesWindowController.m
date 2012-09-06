//
//  PreferencesWindowController.m
//  Cerb6 Notifications
//
//  Created by Scott Luther on 8/7/12.
//  Copyright (c) 2012 WebGroup Media. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "AppDelegate.h"
#import "Site.h"

@implementation PreferencesWindowController

@synthesize sitesTable;
@synthesize sitesController;

@synthesize name;
@synthesize url;
@synthesize accessKey;
@synthesize secretKey;

- (IBAction) closeSiteSheet:(id)sender
{
	[self closeSheet];
}

- (IBAction) addSite:(id)sender
{
	name.stringValue = @"";
	url.stringValue = @"";
	accessKey.stringValue = @"";
	secretKey.stringValue = @"";
	
	[self showSiteSheet:self];
}

- (IBAction) editSite:(id)sender
{
	NSArray *selectedSites = [sitesController selectedObjects];
	
	if([selectedSites count] > 0) {
		Site *site = [selectedSites objectAtIndex:0];
		
		name.stringValue = site.name;
		url.stringValue = site.url;
		accessKey.stringValue = site.accessKey;
		secretKey.stringValue = site.secretKey;
		
		[self showSiteSheet:self];
	}
}

- (IBAction) deleteSite:(id)sender
{
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	
	NSArray *selectedSites = [sitesController selectedObjects];
	Site *site = [selectedSites objectAtIndex:0];
	[context deleteObject:site];
	
	[sitesTable reloadData];
	[appDelegate reloadSitesFromStore];
}

- (IBAction) saveSite:(id)sender
{
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Site" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", url.stringValue];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *siteResults = [context executeFetchRequest:fetchRequest error:&error];
	
	// Does the notification already exist? If so, update it.
	if([siteResults count] == 0) {
		Site *site = [NSEntityDescription insertNewObjectForEntityForName:@"Site" inManagedObjectContext:context];
		
		site.url = [url stringValue];
		site.name = [name stringValue];
		site.accessKey = [accessKey stringValue];
		site.secretKey = [secretKey stringValue];
	} else {
		Site *site = [siteResults objectAtIndex:0];
		
		site.url = [url stringValue];
		site.name = [name stringValue];
		site.accessKey = [accessKey stringValue];
		site.secretKey = [secretKey stringValue];
	}
	
	if(![context save:&error]) {
		NSLog(@"%@", error);
	}
	[self closeSheet];
	[sitesTable reloadData];
}

- (void) showSiteSheet:(id)sender
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
	NSSortDescriptor *sortSites = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
	[sitesController setSortDescriptors:[NSArray arrayWithObject:sortSites]];
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

@end
