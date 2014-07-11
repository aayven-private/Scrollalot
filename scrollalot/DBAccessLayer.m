//
//  DBAccessLayer.m
//  PhonedeckMDM
//
//  Created by Ivan Borsa on 8/26/13.
//  Copyright (c) 2013 aayven. All rights reserved.
//

#import "DBAccessLayer.h"
#import "AppDelegate.h"

@implementation DBAccessLayer

+(NSManagedObjectContext *)createManagedObjectContext
{
    NSManagedObjectContext *resultContext = nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *parentContext = [appDelegate managedObjectContext];
    if (parentContext) {
        if ([[NSThread currentThread] isMainThread]) {
            NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            newContext.parentContext = parentContext;
            resultContext = newContext;
        } else {
            NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            newContext.parentContext = parentContext;
            resultContext = newContext;
        }
    }
    return resultContext;
}

+(void)saveContext:(NSManagedObjectContext *)context async:(BOOL)isAsync
{
    if (isAsync) {
        if (context) {
            [context performBlock:^{
                __block NSError *err = nil;
                [context save:&err];
                [context.parentContext performBlock:^{
                    [context.parentContext save:&err];
                }];
            }];
        }
    } else {
        if (context) {
            [context performBlockAndWait:^{
                __block NSError *err = nil;
                [context save:&err];
                [context.parentContext performBlockAndWait:^{
                    [context.parentContext save:&err];
                }];
            }];
        }
    }
}

@end
