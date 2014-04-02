//
//  LZGameView.h
//  ZengLab5
//
//  Created by Li Zeng on 3/29/14.
//  Copyright (c) 2014 LZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "LZGame.h"
#import "LZLineView.h"

@interface LZGameView : UIView

@property (nonatomic, strong) id  delegate;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

- (void)doTap:(UITapGestureRecognizer *)gestureRecognizer;
- (BOOL)addTargetViewAtPoint:(CGPoint)point;

@end
