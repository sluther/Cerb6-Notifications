//
//  Notification.h
//  Cerb6 Notifications
//
//  Created by Scott Luther on 8/6/12.
//  Copyright (c) 2012 WebGroup Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Notification : NSManagedObject

@property (nonatomic, retain) NSNumber *created;
@property (nonatomic, retain) NSNumber *isRead;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSNumber *notificationId;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *urlMarkRead;

@end