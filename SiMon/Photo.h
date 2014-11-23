//
//  Photo.h
//  SIMon
//
//  Created by Michael Enstone on 08/07/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Locations, ReportItems;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * photoPath;
@property (nonatomic, retain) NSNumber * cloudID;
@property (nonatomic, retain) ReportItems *reportItem;
@property (nonatomic, retain) Locations *location;

@end
