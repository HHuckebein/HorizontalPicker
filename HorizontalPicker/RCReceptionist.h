//
//  RCReceptionist.h
//  HorizontalPickerView
//
//  Created by Bernd Rabe on 08.08.13.
//  Copyright (c) 2013 RABE_IT Services. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RCTaskBlock)(NSString *keyPath, id object, NSDictionary *change);

@interface RCReceptionist : NSObject

+ (id)receptionistForKeyPath:(NSString *)path object:(id)obj queue:(NSOperationQueue *)queue task:(RCTaskBlock)task;

@end
