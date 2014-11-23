//
//  simonXMLRPCInterface.m
//  SIMon
//
//  Created by Michael Enstone on 08/09/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import "simonXMLRPCInterface.h"

@implementation simonXMLRPCInterface

#define kWordpressBaseURL @"http://www.simon-app.com/xmlrpc.php"

- (BOOL)AuthenticateUser:(BOOL) getData {
	BOOL result = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (getData) {
        NSMutableArray *userInfoArray = [self simonInterface:nil method:@"SiMon.getSiMonUserInfo"];
        NSMutableDictionary *userInfo = [userInfoArray objectAtIndex:0];
        if (userInfo) {
            [defaults setObject:[userInfo objectForKey:@"userid"] forKey:@"User_ID"];
            [defaults setObject:[userInfo objectForKey:@"photoStorage"] forKey:@"photoStorage"];
            [defaults setObject:[userInfo objectForKey:@"nickname"] forKey:@"nickname"];
            [defaults setObject:[userInfo objectForKey:@"url"] forKey:@"url"];
            [defaults setObject:[userInfo objectForKey:@"lastname"] forKey:@"lastname"];
            [defaults setObject:[userInfo objectForKey:@"firstname"] forKey:@"firstname"];
            [defaults setObject:[NSString stringWithFormat:@"%@ %@",[userInfo objectForKey:@"firstname"], [userInfo objectForKey:@"lastname"]] forKey:@"Name_simon"];
            result = YES;
        }
    } else if ([self simonInterface:nil method:@"SiMon.getSiMonUserInfo"] != nil)
        {
        result = YES;
        }
	return result;
}

- (BOOL)SyncProjects {
    simonProjectsDataSource *projectsDataSource = [[simonProjectsDataSource alloc] init];
    NSMutableArray *projectsArray = [self simonInterface:nil method:@"SiMon.getProjects"];
    BOOL result = false;
    if (projectsArray != Nil  && projectsDataSource.projects == Nil) {
        for (NSDictionary *project in projectsArray) {
            if (![[project objectForKey:@"cloudID"] isEqualToString:@"-1"]) {
                Projects *convertProject = [[Projects alloc] initWithEntity:[NSEntityDescription entityForName:@"Projects" inManagedObjectContext:projectsDataSource.coreDataInterface.context] insertIntoManagedObjectContext:projectsDataSource.coreDataInterface.context];
                [convertProject FromDictionary:project];
                result = [self SyncLocations:convertProject Locations:convertProject.locations Datasource:projectsDataSource.coreDataInterface];
                [projectsDataSource.projects addObject:convertProject];
            }
        }
        result = result * true;
    } else if (projectsArray != Nil) {
        for (NSDictionary *project in projectsArray) {
            if (![[project objectForKey:@"cloudID"] isEqualToString:@"-1"]) {
                NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Projects" inManagedObjectContext:projectsDataSource.coreDataInterface.context];
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                [request setEntity:entityDescription];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                          @"(cloudID = %@)", [project objectForKey:@"cloudID"]];
                [request setPredicate:predicate];
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                                    initWithKey:@"cloudID" ascending:YES];
                [request setSortDescriptors:@[sortDescriptor]];
                
                NSError *error;
                NSArray *resultsArray = [projectsDataSource.coreDataInterface.context executeFetchRequest:request error:&error];
                if (resultsArray != nil) {
                    Projects *updateProject = [resultsArray objectAtIndex:0];
                    updateProject.projectName = [project valueForKey:@"Project"];
                    updateProject.projectNumber = [project valueForKey:@"ProjectNumber"];
                    result = [self SyncLocations:updateProject Locations:updateProject.locations Datasource:projectsDataSource.coreDataInterface];
                } else {
                    Projects *convertProject = [[Projects alloc] initWithEntity:[NSEntityDescription entityForName:@"Projects" inManagedObjectContext:projectsDataSource.coreDataInterface.context] insertIntoManagedObjectContext:projectsDataSource.coreDataInterface.context];
                    [convertProject FromDictionary:project];
                    [projectsDataSource.projects addObject:project];
                    result = [self SyncLocations:convertProject Locations:convertProject.locations Datasource:projectsDataSource.coreDataInterface];
                }
            }
        }
        result = result * true;
    }
    [projectsDataSource.coreDataInterface savetoDB];
    return result;
}

- (BOOL)SyncLocations:(Projects *)project Locations:(NSSet *)locations Datasource:(simonCoreDataInterface *)coreDataInterface {
    NSArray *args = [NSArray arrayWithObjects:project.cloudID, nil];
    NSMutableArray *locationsArray = [self simonInterface:args method:@"SiMon.getLocations"];
    BOOL result = false;
    if (locations.count > 0  && locationsArray != nil) {
        for (NSDictionary *location in locationsArray) {
            if (![[location objectForKey:@"cloudID"] isEqualToString:@"-1"]) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cloudID == %@", [location valueForKey:@"cloudID"]];
                NSSet *filteredSet = [locations filteredSetUsingPredicate:predicate];
                if (!filteredSet) {
                    Locations *newLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Locations" inManagedObjectContext:coreDataInterface.context];
                    [newLocation FromDictionary:location];
                    newLocation.project = project;
                    [coreDataInterface savetoDB];
                }
            }
        }
        for (Locations *location in locations) {
            if ([location.cloudID intValue]<1){
                NSArray *uploadargs = [NSArray arrayWithObjects:@"0", location.locationName, project.cloudID, nil];
                location.cloudID = [[[self simonInterface:uploadargs method:@"SiMon.uploadLocation"] objectAtIndex:0] objectForKey:@"integer"];
            }
        }
        result = true;
    } else if (locationsArray != nil) {
        for (NSDictionary *location in locationsArray) {
            if (![[location objectForKey:@"cloudID"] isEqualToString:@"-1"]) {
                Locations *newLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Locations" inManagedObjectContext:coreDataInterface.context];
                [newLocation FromDictionary:location];
                newLocation.project = project;
                [coreDataInterface savetoDB];
            }
        }
        result = true;
    } else if (locations.count > 0) {
        for (Locations *location in locations) {
            NSArray *uploadargs = [NSArray arrayWithObjects:@"0", location.locationName, project.cloudID, nil];
            location.cloudID = [[[self simonInterface:uploadargs method:@"SiMon.uploadLocation"] objectAtIndex:0] objectForKey:@"integer"];
        }
        result = true;
    } else {
        result = false;
    }
    return result;
}

- (BOOL)UploadReport:(Reports *)report Project:(Projects *)project Datasource:(simonReportsDataSource *)reportsDataSource{
    BOOL result = false;
    [self SyncLocations:project Locations:project.locations Datasource:reportsDataSource.coreDataInterface];
    NSDate *myDate = report.reportDate;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSString *prettyVersion = [dateFormat stringFromDate:myDate];
    NSArray *uploadargs = [NSArray arrayWithObjects:report.cloudID, project.cloudID, prettyVersion, report.reportType, report.supervisor, report.reportRef, report.weather, report.temp, report.tempType, nil];
    report.cloudID = [[[self simonInterface:uploadargs method:@"SiMon.uploadReport"] objectAtIndex:0] objectForKey:@"integer"];
    if (report.reportPDF.length > 0) {
        [self uploadPDF:report];
    }
    if (report.cloudID) {
        result = true;
        result = result * [self UploadReportItems:report Project:project Datasource:reportsDataSource];
    }
    [reportsDataSource.coreDataInterface savetoDB];
    return result;
}

- (BOOL)UploadReportItems:(Reports *)report Project:(Projects *)project Datasource:(simonReportsDataSource *)reportsDataSource {
    BOOL result = true;
    for (ReportItems *reportItem in report.reportItems) {
        Locations *location = reportItem.location;
        NSArray *uploadargs = [NSArray arrayWithObjects:reportItem.cloudID, project.cloudID, report.cloudID, location.cloudID, reportItem.activityOrItem, reportItem.progress, reportItem.itemDescription, reportItem.onTime, nil];
        reportItem.cloudID = [[[self simonInterface:uploadargs method:@"SiMon.uploadReportItem"] objectAtIndex:0] objectForKey:@"integer"];
        if (!reportItem.cloudID) result = false;
        for (Photo *photo in reportItem.photos) {
            if (photo.cloudID > 0) {
                [self uploadPhoto:photo Project:report.project locationID:[location.cloudID stringValue]];
            }
        }
    }
    return result;
}

- (void) uploadPhoto:(Photo *)photo Project:(Projects *)project locationID:(NSString *)locationID{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *urlString = @"http://www.simon-app.com/wp-content/plugins/SiMon%20Plugin/Upload.php?photo=set";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // file
    NSData *imageData = [NSData dataWithContentsOfFile:[docDirPath stringByAppendingPathComponent:photo.photoPath]];
    NSString *theFileName = [[NSFileManager defaultManager] displayNameAtPath:[docDirPath stringByAppendingPathComponent:photo.photoPath]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@\"\r\n", theFileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // UserID
    NSString *userID = [NSString stringWithFormat:@"%@", [defaults objectForKey:@"User_ID"]];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:userID] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // cloudID
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"cloud_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[photo.cloudID stringValue]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // reportItemID
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"report_item_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[photo.reportItem.cloudID stringValue]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // projectID
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"project_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[project.cloudID stringValue]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // locationID
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"location_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:locationID] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set request body
    [request setHTTPBody:body];
    
    //return and test
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    @try {
        photo.cloudID = [NSNumber numberWithInteger:[returnString integerValue]];
    }
    @catch (NSException *e) {
    }
}

- (void) uploadPDF:(Reports *)report {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *urlString = @"http://www.simon-app.com/wp-content/plugins/SiMon%20Plugin/Upload.php?pdf=set";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSMutableData *body = [NSMutableData data];
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // file
    NSData *imageData = [NSData dataWithContentsOfFile:[docDirPath stringByAppendingPathComponent:report.reportPDF]];
    NSString *theFileName = [[NSFileManager defaultManager] displayNameAtPath:[docDirPath stringByAppendingPathComponent:report.reportPDF]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"pdf\"; filename=\"%@\"\r\n", theFileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/pdf\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // UserID
    NSString *userID = [NSString stringWithFormat:@"%@", [defaults objectForKey:@"User_ID"]];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:userID] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // ReportID
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"report_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[report.cloudID stringValue]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set request body
    [request setHTTPBody:body];
    
    //return and test
    //NSData *returnData =
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
}

- (NSMutableArray *)simonInterface:(NSArray *)items method:(NSString *)method
{
	
    NSMutableArray *finalData = [[NSMutableArray alloc] init];
    NSString *server = kWordpressBaseURL;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults objectForKey:@"Username_simon"];
    NSString *password = [defaults objectForKey:@"Password_simon"];
    NSMutableArray *mutableargs = [NSMutableArray arrayWithObjects:username, password, nil];
    
    if (items != nil) {
        [mutableargs addObjectsFromArray:items];
    }
    
    NSArray *args = [NSArray arrayWithArray:mutableargs];
    
	@try {
        XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:server]];
        [request setMethod:method withObjects:args];
        
        id returnedData = [self executeXMLRPCRequest:request];
        
        if([returnedData isKindOfClass:[NSDictionary class]]) {
            finalData = [NSMutableArray arrayWithObjects:returnedData, nil];
		} else if ([returnedData isKindOfClass:[NSArray class]]) {
            finalData = [NSMutableArray arrayWithArray:returnedData];
        } else if ([returnedData isKindOfClass:[NSNumber class]]) {
            NSDictionary *finalDictionary = [NSDictionary dictionaryWithObject:returnedData forKey:@"integer"];
            finalData = [NSMutableArray arrayWithObjects:finalDictionary, nil];
        } else if([returnedData isKindOfClass:[NSError class]]) {
			self.error = (NSError *)returnedData;
			NSString *errorMessage = [self.error localizedDescription];
			
			finalData = nil;
			
			if([errorMessage isEqualToString:@"The operation couldn’t be completed. (NSXMLParserErrorDomain error 4.)"]) {
                errorMessage = @"Your blog's XML-RPC endpoint was found but it isn't communicating properly. Try disabling plugins or contacting your host.";
            } else if([errorMessage isEqualToString:@"Bad login/pass combination."]) {
                errorMessage = nil;
            }
            NSLog(@"Error: %@, Inputs: %@",errorMessage,args);
		}
		else {
			finalData = nil;
			NSLog(@"method failed: %@", returnedData);
		}
	}
	@catch (NSException * e) {
		finalData = nil;
		NSLog(@"method failed: %@", e);
	}
	return finalData;
}

- (id)executeXMLRPCRequest:(XMLRPCRequest *)req {
	XMLRPCResponse *userInfoResponse = [XMLRPCConnection sendSynchronousXMLRPCRequest:req];
	return [userInfoResponse object];
}
@end
