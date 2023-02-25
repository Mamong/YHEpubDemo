//
//  AppDelegate.m
//  YHEpubDemo
//
//  Created by survivors on 2019/3/1.
//  Copyright © 2019年 survivorsfyh. All rights reserved.
//

#import "AppDelegate.h"
#import "ReadEpubVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    UINavigationController *shelfNav = [[UINavigationController alloc] initWithRootViewController:[[ReadEpubVC alloc] init]];
    UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"书库" image:[UIImage systemImageNamed:@"books.vertical"] tag:0];
    item1.selectedImage = [UIImage systemImageNamed:@"books.vertical.fill"];
    shelfNav.tabBarItem = item1;


    UINavigationController *downloadNav = [[UINavigationController alloc] initWithRootViewController:[[UIViewController alloc] init]];
    downloadNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"下载" image:[UIImage systemImageNamed:@"books.vertical"] tag:1];

    UINavigationController *sourceNav = [[UINavigationController alloc] initWithRootViewController:[[UIViewController alloc] init]];
    sourceNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"书源" image:[UIImage systemImageNamed:@"books.vertical"] tag:1];

    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:[[UIViewController alloc] init]];
    settingsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"设置" image:[UIImage systemImageNamed:@"books.vertical"] tag:1];

    UITabBarController *tabVC = [[UITabBarController alloc] init];
    [tabVC setViewControllers:@[shelfNav, downloadNav, sourceNav, settingsNav]];

    self.window.rootViewController = tabVC;
    [self.window makeKeyAndVisible];
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if([[url absoluteString] hasPrefix:@"wuwuFQ_shareExtension"]) {
        return YES;
    }
    return NO;
}

//API_AVAILABLE(ios(9.0));
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if([[url absoluteString] hasPrefix:@"wuwuFQ_shareExtension"]) {
        return YES;
    }
    return NO;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"YHEpubDemo"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
