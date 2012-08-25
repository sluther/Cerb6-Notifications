//
//  Site.h
//  Cerb6 Notifications
//
//  Created by Scott on 8/20/12.
//  Copyright (c) 2012 WebGroup Media. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Site : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *accessKey;
@property (nonatomic, retain) NSString *secretKey;
@property (nonatomic, retain) NSSet *notifications;

@end
