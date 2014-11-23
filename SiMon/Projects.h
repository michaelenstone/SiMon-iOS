//
//  Projects.h
//  SIMon
//
//  Created by Michael Enstone on 08/07/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Locations;

@interface Projects : NSManagedObject

@property (nonatomic, retain) NSNumber * cloudID;
@property (nonatomic, retain) NSString * projectName;
@property (nonatomic, retain) NSString * projectNumber;
@property (nonatomic, retain) NSSet *locations;
@property (nonatomic, retain) NSSet *reports;
@end

@interface Projects (CoreDataGeneratedAccessors)

- (void) FromDictionary:(NSDictionary *)project;

- (void)addLocationsObject:(Locations *)value;
- (void)removeLocationsObject:(Locations *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;

- (void)addReportsObject:(NSManagedObject *)value;
- (void)removeReportsObject:(NSManagedObject *)value;
- (void)addReports:(NSSet *)values;
- (void)removeReports:(NSSet *)values;

- (BOOL)isTheSame:(id)other;

@end
