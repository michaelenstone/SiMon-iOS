//
//  simonProjectsDataSource.m
//  SIMon
//
//  Created by Michael Enstone on 02/03/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import "simonProjectsDataSource.h"

@implementation simonProjectsDataSource

- (id)init {
    self = [super init];
    self.coreDataInterface = [[simonCoreDataInterface alloc] init];
    self.projects = [[NSMutableArray alloc] init];
    [self loadInitialData];
    return self;
}

- (void)loadInitialData {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Projects"];
    if ([self.coreDataInterface.context countForFetchRequest:fetchRequest error:nil] > 0) {
        self.projects = [[self.coreDataInterface.context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    } else {
        self.projects = nil;
    }
}

- (Projects *)projectOnPhone:(id) project {
    for (Projects *searchProject in self.projects) {
        if ([searchProject isTheSame:project]) return searchProject;
    }
    return nil;
}

@end
