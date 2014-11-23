//
//  simonXMLRPCInterface.h
//  SIMon
//
//  Created by Michael Enstone on 08/09/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import "XMLRPCResponse.h"
#import "XMLRPCRequest.h"
#import "XMLRPCConnection.h"
#import "simonProjectsDataSource.h"
#import "simonReportsDataSource.h"
#import "simonCoreDataInterface.h"
#import "Projects.h"
#import "Locations.h"
#import "Reports.h"
#import "ReportItems.h"
#import "Photo.h"

@interface simonXMLRPCInterface : NSObject

@property (nonatomic,retain) NSError *error;

- (BOOL)AuthenticateUser:(BOOL) getData;
- (id)executeXMLRPCRequest:(XMLRPCRequest *)req;
- (BOOL)SyncProjects;
- (BOOL)UploadReport:(Reports *)report Project:(Projects *)project Datasource:(simonReportsDataSource *)reportsDataSource;

@end
