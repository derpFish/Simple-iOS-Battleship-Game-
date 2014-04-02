//
//  LZShip.m
//  ZengLab5
//
//  Created by Li Zeng on 3/29/14.
//  Copyright (c) 2014 LZ. All rights reserved.
//

#import "LZShip.h"

@implementation LZShip

+ (id)shipWithType:(ShipType)shipType
{
    return [[[self class] alloc] initWithType:shipType];
}

- (id)initWithType:(ShipType)shipType
{
    self = [super init];
    if (self) {
        [self setType: shipType];
        
        switch (shipType) {
            case ShipTypePatrolBoat:
                [self setLength:2];
                break;
                
            case ShipTypeSubmarine:
                [self setLength:3];
                break;
                
            case ShipTypeCruiser:
                [self setLength:3];
                break;
                
            case ShipTypeBattleship:
                [self setLength:4];
                break;
                
            case ShipTypeCarrier:
                [self setLength:5];
                break;
                
            default:
                break;
        }
        
        [self setSegments:[NSMutableArray array]];
        [self setHitSegments:[NSMutableArray array]];

    }
    return self;
}

- (void)saveShipSegments:(UIView*) shipView
{
    // Basic Data Dump
    BOOL isRotated = [shipView frame].size.width < [shipView frame].size.height;
    NSInteger xIndex = [shipView frame].origin.x / CELLSIZE;
    NSInteger yIndex = [shipView frame].origin.y / CELLSIZE;
    
    NSInteger firstSegment = yIndex * 10 + xIndex;
    
    for (int i = 0; i < [self length]; i++) {
        
        // Add vertical segments
        if (isRotated) {
            [[self segments] addObject:[NSNumber numberWithInteger:firstSegment + (i * 10)]];
        }
        // Add horizontal segments
        else {
            [[self segments] addObject:[NSNumber numberWithInteger:firstSegment + i]];
        }
    }
}

@end
