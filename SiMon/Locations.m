//
//  Locations.m
//  SIMon
//
//  Created by Michael Enstone on 08/07/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import "Locations.h"
#import "Projects.h"
#import "ReportItems.h"


@implementation Locations

@dynamic cloudID;
@dynamic locationName;
@dynamic project;
@dynamic locations;
@dynamic photos;

- (NSString *)autocompleteString {
    return self.locationName;
}

- (void) FromDictionary:(NSDictionary *)location {
    
    self.cloudID = [NSNumber numberWithInteger:[[location objectForKey:@"cloudID"] integerValue]];
    self.locationName = [location objectForKey:@"Location"];
}

- (NSDictionary *) toDictionary {
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:self.cloudID, @"cloudID", self.locationName, @"Location", nil];
    return result;
}

- (BOOL)isTheSame:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToWidget:other];
}

- (BOOL)isEqualToWidget:(Locations *)location {
    if (self == location)
        return YES;
    if (![(id)[self cloudID] isEqual:[location cloudID]])
        return NO;
    if (![[self locationName] isEqual:[location locationName]])
        return NO;
    return YES;
}

@end
