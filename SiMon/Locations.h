//
//  Locations.h
//  SIMon
//
//  Created by Michael Enstone on 08/07/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MLPAutoCompletionObject.h"

@class Projects, ReportItems;

@interface Locations : NSManagedObject <MLPAutoCompletionObject>

@property (nonatomic, retain) NSNumber * cloudID;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) Projects *project;
@property (nonatomic, retain) NSSet *locations;
@property (nonatomic, retain) NSSet *photos;
@end

@interface Locations (CoreDataGeneratedAccessors)

- (void) FromDictionary:(NSDictionary *)location;
- (NSDictionary *) toDictionary;

- (void)addLocationsObject:(ReportItems *)value;
- (void)removeLocationsObject:(ReportItems *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;

- (void)addPhotosObject:(NSManagedObject *)value;
- (void)removePhotosObject:(NSManagedObject *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (BOOL)isTheSame:(id)other;

@end