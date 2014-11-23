//
//  Reports.h
//  SIMon
//
//  Created by Michael Enstone on 08/07/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Projects, ReportItems;

@interface Reports : NSManagedObject

@property (nonatomic, retain) NSNumber * cloudID;
@property (nonatomic, retain) NSDate * reportDate;
@property (nonatomic, retain) NSString * reportPDF;
@property (nonatomic, retain) NSString * reportRef;
@property (nonatomic, retain) NSNumber * reportType;
@property (nonatomic, retain) NSString * supervisor;
@property (nonatomic, retain) NSDecimalNumber * temp;
@property (nonatomic, retain) NSNumber * tempType;
@property (nonatomic, retain) NSString * weather;
@property (nonatomic, retain) Projects *project;
@property (nonatomic, retain) NSSet *reportItems;
@end

@interface Reports (CoreDataGeneratedAccessors)

- (void)addReportItemsObject:(ReportItems *)value;
- (void)removeReportItemsObject:(ReportItems *)value;
- (void)addReportItems:(NSSet *)values;
- (void)removeReportItems:(NSSet *)values;

@end
