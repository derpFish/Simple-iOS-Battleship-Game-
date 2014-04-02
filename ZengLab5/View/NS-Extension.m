//
//  NS-Extension.m
//  ZengLab5
//
//  Created by Li Zeng on 3/31/14.
//  Copyright (c) 2014 LZ. All rights reserved.
//

#import "NS-Extension.h"

@implementation UIView (Copy)

- (UIView*)newDuplicate {
    
    UIView *v = [[[self class] alloc] initWithFrame:self.frame];
    v.autoresizingMask = self.autoresizingMask;
    
    for (UIView *v1 in self.subviews) {
        UIView *v2 = [[[v1 class] alloc] initWithFrame:v1.frame];
        v2.autoresizingMask = v1.autoresizingMask;
        [v addSubview:v2];
    }
    
    return v;
}

@end
