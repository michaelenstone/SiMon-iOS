//
//  simonProjectsDataSource.h
//  SIMon
//
//  Created by Michael Enstone on 02/03/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Projects.h"
#import "simonCoreDataInterface.h"

@interface simonProjectsDataSource : NSObject

@property NSMutableArray *projects;
@property simonCoreDataInterface *coreDataInterface;

- (id) init;
- (void)loadInitialData;
- (Projects *)projectOnPhone:(id) project;

@end
