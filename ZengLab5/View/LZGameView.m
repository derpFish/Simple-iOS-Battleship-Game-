//
//  LZGameView.m
//  ZengLab5
//
//  Created by Li Zeng on 3/29/14.
//  Copyright (c) 2014 LZ. All rights reserved.
//

#import "LZGameView.h"
#import "LZGameViewController.h"

@interface LZGameView()
{
    CFURLRef missSoundFileRef;
    CFURLRef hitSoundFileRef;
    CFURLRef victorSoundFileRef;
    SystemSoundID missSoundFile;
    SystemSoundID hitSoundFile;
    SystemSoundID victorSoundFile;
}
@end

@implementation LZGameView

-(void)initSound
{
    NSURL *missSoundURL = [[NSBundle mainBundle] URLForResource: @"miss"
                                                  withExtension: @"mp3"];
    NSURL *hitSoundURL = [[NSBundle mainBundle] URLForResource: @"hit"
                                                 withExtension: @"mp3"];
    NSURL *victorSoundURL = [[NSBundle mainBundle] URLForResource: @"victor"
                                                 withExtension: @"mp3"];
    
    missSoundFileRef = (CFURLRef)CFBridgingRetain(missSoundURL);
    hitSoundFileRef = (CFURLRef)CFBridgingRetain(hitSoundURL);
    victorSoundFileRef = (CFURLRef)CFBridgingRetain(victorSoundURL);
    
    AudioServicesCreateSystemSoundID(
        missSoundFileRef,
        &missSoundFile
    );
    AudioServicesCreateSystemSoundID(
        hitSoundFileRef,
        &hitSoundFile
    );
    AudioServicesCreateSystemSoundID(
        victorSoundFileRef,
        &victorSoundFile
    );
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(contextRef);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [[UIColor blueColor] setStroke];
    
    NSInteger cellWidth = CELLSIZE;
    NSInteger cellHeight = CELLSIZE;
    
    // Draw vertical lines
    for (int i = 0; i <= 10; i++) {
        NSInteger xPos = i * cellWidth;
        [bezierPath moveToPoint:CGPointMake(xPos, rect.origin.y)];
        [bezierPath addLineToPoint:CGPointMake(xPos, rect.size.height)];
        [bezierPath stroke];
        [bezierPath removeAllPoints];
    }
    
    // Draw horizontal lines
    for (int i = 0; i <= 10; i++) {
        NSInteger yPos = i * cellHeight;
        [bezierPath moveToPoint:CGPointMake(rect.origin.x, yPos)];
        [bezierPath addLineToPoint:CGPointMake(rect.size.width, yPos)];
        [bezierPath stroke];
        [bezierPath removeAllPoints];
    }
    
    CGContextRestoreGState(contextRef);
    
    [self initSound];
}

#pragma Capture Tap Gesture

- (void)doTap:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:self];
    // Avoid Trigger when game is over
    if ([[(LZGameViewController*)[self delegate] game] gameState] == GameStatePlaying) {
        [self addTargetViewAtPoint:tapPoint];
    }
}

#pragma Pass Gesture Event To Game

- (BOOL)addTargetViewAtPoint:(CGPoint)point
{
    PlayerNumber currentPlayer = [(LZGameViewController*)[self delegate] currentPlayer];
    LZGameView *locationView = [(LZGameViewController*)[self delegate] shipLocationView];
    
    BOOL hit_f = [[(LZGameViewController*)[self delegate] game] handleGridTapPoint: point ForPlayer: currentPlayer];
    
    NSInteger xIndex = point.x / CELLSIZE;
    NSInteger yIndex = point.y / CELLSIZE;
    
    // draw circle or X by ret
    if (hit_f == NO) {
        UIView *targetView = [[UIView alloc] initWithFrame:CGRectMake(xIndex * CELLSIZE, yIndex * CELLSIZE, CELLSIZE, CELLSIZE)];
        targetView.alpha = 0.6;
        targetView.layer.cornerRadius = CELLSIZE/2.0;
        [targetView setBackgroundColor:[UIColor grayColor]];
        if (currentPlayer == PlayerOne) {
            [targetView setTag: 10];
        } else {
            [targetView setTag: 11];
        }
        [self addSubview:targetView];
        [targetView setUserInteractionEnabled: NO];
        // Play a clip to show miss
        AudioServicesPlaySystemSound(missSoundFile);
    } else {
        // Add hit mark at location view
        UIView *targetView = [[UIView alloc] initWithFrame:CGRectMake(xIndex * CELLSIZE, yIndex * CELLSIZE, CELLSIZE, CELLSIZE)];
        targetView.alpha = 0.6;
        targetView.backgroundColor = [UIColor orangeColor];
        if (currentPlayer == PlayerOne) {
            [targetView setTag: 11];
        } else {
            [targetView setTag: 10];
        }
        [locationView addSubview: targetView];
        [targetView setHidden: YES];
        // Add hit mark at hit view
        LZLineView *lines = [[LZLineView alloc] initWithFrame:CGRectMake(xIndex * CELLSIZE, yIndex * CELLSIZE, CELLSIZE, CELLSIZE)];
        if (currentPlayer == PlayerOne) {
            [lines setTag: 10];
        } else {
            [lines setTag: 11];
        }
        [lines setBackgroundColor:[self backgroundColor]];
        [self addSubview: lines];
        [lines setUserInteractionEnabled: NO];
        // Play a clip to show hit
        AudioServicesPlaySystemSound(hitSoundFile);
    }
    if (!hit_f) {
        [(LZGameViewController*)[self delegate] lockupGridView];
        [[(LZGameViewController*)[self delegate] navigationItem] setRightBarButtonItem: [[UIBarButtonItem alloc] initWithTitle:@"Next Move" style:UIBarButtonItemStylePlain target:[self delegate] action: @selector(nextMove)]];
    }
    // If Someone wins?
    else {
        // Play a clip to show someone wins
        if ([[(LZGameViewController*)[self delegate] game] isWin]) {
            AudioServicesPlaySystemSound(victorSoundFile);
            [(LZGameViewController*)[self delegate] GameQuitWithReason: GameOver];
        }
    }
    return hit_f;
}

@end
