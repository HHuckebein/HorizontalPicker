//
//  RCReceptionist.m
//  HorizontalPickerView
//
//  Created by Bernd Rabe on 08.08.13.
//  Copyright (c) 2013 RABE_IT Services. All rights reserved.
//

#import "RCReceptionist.h"

@interface RCReceptionist()
@property (nonatomic, weak  ) id                observedObject;
@property (nonatomic, copy  ) NSString          *observedKeyPath;
@property (nonatomic, strong) NSOperationQueue  *queue;
@property (nonatomic, copy  ) RCTaskBlock       task;
@end


@implementation RCReceptionist

+ (id)receptionistForKeyPath:(NSString *)path object:(id)obj queue:(NSOperationQueue *)queue task:(RCTaskBlock)task
{
    RCReceptionist *receptionist = [RCReceptionist new];
    receptionist.task = task;
    receptionist.observedKeyPath = path;
    receptionist.observedObject = obj;
    receptionist.queue = queue;
    
    [obj addObserver:receptionist forKeyPath:path options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:0];
    
    return receptionist;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.queue addOperationWithBlock:^{
        if (self.task) self.task(keyPath, object, change);
    }];
}

@end
