//
//  ReportssDataSource.m
//  SIMon
//
//  Created by Michael Enstone on 02/03/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import "simonReportsDataSource.h"

@implementation simonReportsDataSource

- (id)init {
    self = [super init];
    self.coreDataInterface = [[simonCoreDataInterface alloc] init ];
    self.reports = [[NSMutableArray alloc] init];
    [self loadInitialData];
    return self;
}

- (void)loadInitialData  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Reports"];
    self.reports = [[self.coreDataInterface.context executeFetchRequest:fetchRequest error:nil] mutableCopy];
}

@end
