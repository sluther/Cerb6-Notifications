//
//  RelativeDateTransformer.m
//  Cerb6 Notifications
//
//  Created by Scott on 8/29/12.
//  Copyright (c) 2012 WebGroup Media. All rights reserved.
//

#import "RelativeDateTransformer.h"

@implementation RelativeDateTransformer


- (id)transformedValue:(id)value
{	
	NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[value doubleValue]];
	int elapsed = [date timeIntervalSinceNow];
	
	NSString *out = @"";
	
	bool is_past = (elapsed < 0) ? TRUE : FALSE;
	elapsed = abs(elapsed);
	
	if(elapsed > 86400) {
		out = [NSString stringWithFormat:
			   @"%d day%@%@",
			   elapsed / 86400,
			   elapsed / 86400 > 1 ? @"s" : @"",
			   (is_past) ? @" ago" : @""
			   ];
	} else if(elapsed > 3600) {
		out = [NSString stringWithFormat:
			   @"%d hour%@%@",
			   elapsed / 3600,
			   elapsed / 3600 > 1 ? @"s" : @"",
			   (is_past) ? @" ago" : @""
			   ];
	} else if(elapsed > 60) {
		out = [NSString stringWithFormat:
			   @"%d minute%@%@",
			   elapsed / 60,
			   elapsed / 60 > 1 ? @"s" : @"",
			   (is_past) ? @" ago" : @""
			   ];
	} else {
		out = [NSString stringWithFormat:
			   @"%d second%@%@",
			   elapsed,
			   elapsed > 1 ? @"s" : @"",
			   (is_past) ? @" ago" : @""
			   ];
	}
	
	return out;
}

@end
