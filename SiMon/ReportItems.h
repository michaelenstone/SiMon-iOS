//
//  ReportItems.h
//  SIMon
//
//  Created by Michael Enstone on 08/07/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Locations;

@interface ReportItems : NSManagedObject

@property (nonatomic, retain) NSString * activityOrItem;
@property (nonatomic, retain) NSDecimalNumber * progress;
@property (nonatomic, retain) NSString * itemDescription;
@property (nonatomic, retain) NSString * onTime;
@property (nonatomic, retain) NSNumber * cloudID;
@property (nonatomic, retain) NSManagedObject *report;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) Locations *location;
@end

@interface ReportItems (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(NSManagedObject *)value;
- (void)removePhotosObject:(NSManagedObject *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
