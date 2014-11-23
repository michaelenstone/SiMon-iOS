//
//  simonAppDelegate.h
//  SIMon
//
//  Created by Michael Enstone on 09/02/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface simonAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
