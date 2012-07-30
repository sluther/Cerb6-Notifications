//
//  Hasher.h
//  Cerb5_Monitor_OSX
//
//  Created by Jeff Standen on 4/21/10.
//

#import <CommonCrypto/CommonDigest.h>
#import <Foundation/Foundation.h>

@interface Utils : NSObject {
}

+(NSString *)md5FromString:(NSString *)source;
+(NSString *)prettySecs:(NSNumber *)timestamp;
@end
