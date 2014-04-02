//
//  LZGame.m
//  ZengLab5
//
//  Created by Li Zeng on 3/29/14.
//  Copyright (c) 2014 LZ. All rights reserved.
//

#import "LZGame.h"

#define dirty_point CGPointMake(-1, -1)

typedef enum
{
    zero_latch,
    up_latch,
    down_latch,
    left_latch,
    right_latch,
    all_latch_used,
    latch_slot_expired,
    latch_slot_active
}LatchState;

@interface LZGame()
{
    NSMutableArray *up;
    NSMutableArray *down;
    NSMutableArray *left;
    NSMutableArray *right;
    
    int latch[4];
    
    NSMutableArray *usedPoint;
}
@end

@implementation LZGame

// Return If it's a hit;
// Store Data

- (BOOL)handleGridTapPoint:(CGPoint)point ForPlayer:(int)player
{
    LZPlayer *oppPlayer = player == 0? _playerTwo : _playerOne;
    
    NSInteger xIndex = point.x / CELLSIZE;
    NSInteger yIndex = point.y / CELLSIZE;
    
    NSInteger segment = yIndex * 10 + xIndex;
    
    NSNumber *segmentObj = [NSNumber numberWithInteger: segment];
    
    BOOL hit_f = NO;
    
    for (LZShip* ship in [oppPlayer ships]) {
        BOOL isContained = NO;
        for (NSNumber *number in [ship segments]) {
            if ([number intValue] == [segmentObj intValue]) {
                isContained = YES;
                hit_f = YES;
                for (NSNumber *_number in [ship hitSegments]) {
                    if ([_number intValue] == [segmentObj intValue]) {
                        isContained = NO;
                        break;
                    }
                }
                break;
            }
        }
        if (isContained) {
            [[ship hitSegments] addObject: segmentObj];
            break;
        }
    }
    return hit_f;
}

- (BOOL)isWin
{
    BOOL playerOneWin = YES;
    BOOL playerTwoWin = YES;
    
    for (LZShip* ship in [_playerOne ships]) {
        if ([[ship segments] count] != [[ship hitSegments] count]) {
            playerTwoWin = NO;
            break;
        }
    }
    
    for (LZShip* ship in [_playerTwo ships]) {
        if ([[ship segments] count] != [[ship hitSegments] count]) {
            playerOneWin = NO;
            break;
        }
    }
    if (playerOneWin | playerTwoWin) {
        _winner = playerOneWin? 0 : 1;
    }
    return playerOneWin | playerTwoWin;
}

// AI logic

- (CGPoint)calculateAIHitPoint: (BOOL) hit_f
{
    // init
    if (!up) {
        [self resetLatch];
        up = [[NSMutableArray alloc] init];
        down = [[NSMutableArray alloc] init];
        left = [[NSMutableArray alloc] init];
        right = [[NSMutableArray alloc] init];
        usedPoint = [[NSMutableArray alloc] init];
    }
    
    // Create new node
    if (!hit_f && [self isLatched] == NO) {
        return [self regeneratePoint];
    }
    // latched but not hit, try the other directions
    else if ([self isLatched] == YES && !hit_f) {
        CGPoint currentPoint;
        // check reverse dir if possible
        currentPoint = [self usePointWithReverseLatch];
        if (CGPointEqualToPoint(currentPoint, dirty_point) == NO) {
            return currentPoint;
        }
        // if not check other dir
        currentPoint = [self usePointWithAvailableLatch];
        if (CGPointEqualToPoint(currentPoint, dirty_point) == NO) {
            return currentPoint;
        }
        // if all used then regenerate
        if ([self latchState] == all_latch_used) {
            return [self regeneratePoint];
        }
    }
    // just hit
    else if (hit_f) {
        if ([self isLatched] == YES) {
            return [self usePointWithSameLatch];
        }
        // NO latch use available latch at will
        else {
            return [self usePointWithAvailableLatch];
        }
    }
    return CGPointZero; // return to avoid warning
}

- (BOOL)isLatched
{
    BOOL is_latched = NO;
    for (int i = 0; i < 4; i++) {
        if (latch[i] == 1) {
            is_latched = YES;
            break;
        }
    }
    return is_latched;
}

- (void)resetLatch
{
    memset(latch, 0, sizeof(latch));
    [up removeAllObjects];
    [down removeAllObjects];
    [left removeAllObjects];
    [right removeAllObjects];
}

- (LatchState)latchState
{
    LatchState state = zero_latch;
    int slot =  -1;
    for (int i = 0; i < 4; i++) {
        if (latch[i] == 1) {
            slot = i;
            break;
        }
        else if (latch[i] == 0) {
            slot = 5;
        } else if(latch[i] == 2) {
            slot = 6;
        }
    }
    switch (slot) {
        case 0:
            state = up_latch;
            break;
        case 1:
            state = down_latch;
            break;
        case 2:
            state = left_latch;
            break;
        case 3:
            state = right_latch;
            break;
        case 5:
            state = zero_latch;
            break;
        case 6:
            state = all_latch_used;
            break;
    }
    return state;
}

- (LatchState)latchStateWithState:(LatchState) state
{
    if (state == up_latch) {
        return latch[0] == 2? latch_slot_expired : latch_slot_active;
    } else if (state == down_latch ) {
        return latch[1] == 2? latch_slot_expired : latch_slot_active;
    } else if (state == left_latch) {
        return latch[2] == 2? latch_slot_expired : latch_slot_active;;
    } else if (state == right_latch) {
        return latch[3] == 2? latch_slot_expired : latch_slot_active;;
    }
    return latch_slot_expired; // dfault is expired
}

- (CGPoint)nextPointWithLatchState: (LatchState) state
{
    CGPoint currentPoint = dirty_point;
    if ([self latchStateWithState: state] == latch_slot_expired) {
        return currentPoint;
    }
    if (state == up_latch) {
        if ([up count] > 0) {
            currentPoint = [[up lastObject] CGPointValue];
            [up removeLastObject];
        } else {
            [self setDirtyBitAtLatchWithState: state];
        }
    }
    else if (state == down_latch) {
        if ([down count] > 0) {
            currentPoint = [[down lastObject] CGPointValue];
            [down removeLastObject];
        } else {
            [self setDirtyBitAtLatchWithState: state];
        }
    }
    else if (state == left_latch) {
        if ([left count] > 0) {
            currentPoint = [[left lastObject] CGPointValue];
            [left removeLastObject];
        } else {
            [self setDirtyBitAtLatchWithState: state];
        }
    }
    else if (state == right_latch) {
        if ([right count] > 0) {
            currentPoint = [[right lastObject] CGPointValue];
            [right removeLastObject];
        } else {
            [self setDirtyBitAtLatchWithState: state];
        }
    }
    [usedPoint addObject: [NSValue valueWithCGPoint: currentPoint]];
    return currentPoint;
}

- (void)setDirtyBitAtLatchWithState: (LatchState) state
{
    if (state == up_latch) {
        latch[0] = 2;
    }
    else if (state == down_latch) {
        latch[1] = 2;
    }
    else if (state == left_latch) {
        latch[2] = 2;
    }
    else if (state == right_latch) {
        latch[3] = 2;
    }

}

- (void)setActiveBitAtLatchWithState: (LatchState) state
{
    if (state == up_latch) {
        latch[0] = 1;
    }
    else if (state == down_latch) {
        latch[1] = 1;
    }
    else if (state == left_latch) {
        latch[2] = 1;
    }
    else if (state == right_latch) {
        latch[3] = 1;
    }
}

- (LatchState)reverseStateWithState: (LatchState) state
{
    if (state == up_latch) {
        return down_latch;
    } else if (state == down_latch) {
        return up_latch;
    } else if (state == left_latch) {
        return right_latch;
    } else if (state == right_latch) {
        return left_latch;
    }
    return all_latch_used;
}

- (CGPoint)usePointWithSameLatch
{
    LatchState state = [self latchState];
    return [self nextPointWithLatchState: state];
}


- (CGPoint)usePointWithReverseLatch
{
    LatchState state = [self latchState];
    [self setDirtyBitAtLatchWithState: state];
    LatchState reverseState = [self reverseStateWithState: state];
    if ([self latchStateWithState: reverseState] != latch_slot_expired) {
        [self setActiveBitAtLatchWithState: reverseState];
    }
    return [self nextPointWithLatchState: reverseState];
}

- (CGPoint)usePointWithAvailableLatch
{
    LatchState state = zero_latch;
    CGPoint currentPoint = dirty_point;
    for (int i = 0; i < 4; i++)
    {
        if (latch[i] == 0) {
            if (i == 0)
                state = up_latch;
            else if (i == 1)
                state = down_latch;
            else if (i == 2)
                state = left_latch;
            else if (i == 3)
                state = right_latch;
            [self setActiveBitAtLatchWithState: state];
            currentPoint = [self nextPointWithLatchState: state];
            break;
        }
    }
    [usedPoint addObject: [NSValue valueWithCGPoint: currentPoint]];
    return currentPoint;
}

- (BOOL)visitedStateWithPoint: (CGPoint) point
{
    for (NSValue *val in usedPoint) {
        if (CGPointEqualToPoint([val CGPointValue], point) == YES) {
            return YES;
        }
    }
    return NO;
}

- (CGPoint)regeneratePoint
{
    int cellX, cellY;
    
    cellX = 0;
    cellY = 0;

    BOOL loop = YES;
    CGPoint currentPoint;
    
    while (loop)
    {
        cellX = arc4random() % 8 + 1;
        cellY = arc4random() % 8 + 1;
        currentPoint = CGPointMake(cellX * CELLSIZE, cellY * CELLSIZE);
        
        loop = [self visitedStateWithPoint: currentPoint];
    }
    
    [self resetLatch];
    
    // Create new arrow array
    for (int i = 4; i >= 1; i--) {
        // up
        if (cellY - i >= 0) {
            CGPoint upPoint = CGPointMake(cellX * CELLSIZE, (cellY - i) * CELLSIZE);
            if ([self visitedStateWithPoint: upPoint] == NO) {
                [up addObject:[NSValue valueWithCGPoint: upPoint]];
            }
        }
        // down
        if (cellY + i < 10) {
            CGPoint downPoint = CGPointMake(cellX * CELLSIZE, (cellY + i) * CELLSIZE);
            if ([self visitedStateWithPoint: downPoint] == NO) {
                [down addObject:[NSValue valueWithCGPoint: downPoint]];
            }
        }
        // left
        if (cellX - i >= 0) {
            CGPoint leftPoint = CGPointMake((cellX - i) * CELLSIZE, cellY * CELLSIZE);
            if ([self visitedStateWithPoint: leftPoint] == NO) {
                [left addObject:[NSValue valueWithCGPoint: leftPoint]];
            }
        }
        // right
        if (cellX + i < 10) {
            CGPoint rightPoint = CGPointMake((cellX + i) * CELLSIZE, cellY * CELLSIZE);
            if ([self visitedStateWithPoint: rightPoint] == NO) {
                [right addObject:[NSValue valueWithCGPoint: rightPoint]];
            }
        }
    }
    [usedPoint addObject: [NSValue valueWithCGPoint: currentPoint]];
    return currentPoint;
}

@end









