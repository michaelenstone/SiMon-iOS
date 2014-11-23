//
//  Projects.m
//  SIMon
//
//  Created by Michael Enstone on 08/07/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import "Projects.h"
#import "Locations.h"


@implementation Projects

@dynamic cloudID;
@dynamic projectName;
@dynamic projectNumber;
@dynamic locations;
@dynamic reports;

- (void) FromDictionary:(NSDictionary *)project {
    self.cloudID = [NSNumber numberWithInteger:[[project objectForKey:@"cloudID"] integerValue]];
    self.projectName = [project objectForKey:@"Project"];
    self.projectNumber = [project objectForKey:@"ProjectNumber"];
}

- (BOOL)isTheSame:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToWidget:other];
}

- (BOOL)isEqualToWidget:(Projects *)project {
    if (self == project)
        return YES;
    if (![(id)[self cloudID] isEqual:[project cloudID]])
        return NO;
    if (![[self projectName] isEqual:[project projectName]])
        return NO;
    if (![[self projectNumber] isEqual:[project projectNumber]])
        return NO;
    return YES;
}

@end
