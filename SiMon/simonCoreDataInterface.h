//
//  simonCoreDataInterface.h
//  SIMon
//
//  Created by Michael Enstone on 22/06/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface simonCoreDataInterface : NSObject

@property NSManagedObjectContext *context;
- (void)savetoDB;

@end