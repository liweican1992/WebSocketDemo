//
//  NSObject+SRSocket.m
//  socketTest
//
//  Created by CC on 17/2/15.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "NSObject+SRSocket.h"
#import <objc/runtime.h>
static const void *sockteTagKey = &sockteTagKey;

@implementation NSObject (SRSocket)
- (void)setSockteTag:(NSString *)sockteTag{
    objc_setAssociatedObject(self, sockteTagKey, sockteTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}
- (NSString *)sockteTag{
    return objc_getAssociatedObject(self, sockteTagKey);
}
@end
