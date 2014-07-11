//
//  DBAccessLayer.h
//  PhonedeckMDM
//
//  Created by Ivan Borsa on 8/26/13.
//  Copyright (c) 2013 aayven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DBAccessLayer : NSObject

+(NSManagedObjectContext *)createManagedObjectContext;
+(void)saveContext:(NSManagedObjectContext *)context async:(BOOL)isAsync;

@end
