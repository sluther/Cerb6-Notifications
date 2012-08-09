//
//  Hasher.m
//  Cerb5_Monitor_OSX
//
//  Created by Jeff Standen on 4/21/10.
//

#import "Utils.h"

@implementation Utils
/*
 * Derived from: http://snipplr.com/view.php?codeview&id=18192
 */
+(NSString *)md5FromString:(NSString *)source {
	const char *src = [source UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(src, strlen(src), result);
	
    NSString *ret = [[NSString alloc] initWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
					  result[0], result[1], result[2], result[3],
					  result[4], result[5], result[6], result[7],
					  result[8], result[9], result[10], result[11],
					  result[12], result[13], result[14], result[15]
					  ];
    
    return [ret lowercaseString];
}

+(NSString *)prettySecs:(NSNumber *)timestamp {

	NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[timestamp doubleValue]];
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