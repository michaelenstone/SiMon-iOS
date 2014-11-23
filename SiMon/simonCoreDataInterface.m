//
//  simonCoreDataInterface.m
//  SIMon
//
//  Created by Michael Enstone on 22/06/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import "simonCoreDataInterface.h"

@implementation simonCoreDataInterface

- (id)init {
    self.context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        self.context = [delegate managedObjectContext];
    }
    return self;
}

- (void)savetoDB {
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![self.context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

@end
