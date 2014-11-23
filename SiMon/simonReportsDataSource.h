//
//  simonReportsDataSource.h
//  SIMon
//
//  Created by Michael Enstone on 02/03/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reports.h"
#import "simonCoreDataInterface.h"

@interface simonReportsDataSource : NSObject

@property NSMutableArray *reports;
@property simonCoreDataInterface *coreDataInterface;

- (void)loadInitialData;

@end
