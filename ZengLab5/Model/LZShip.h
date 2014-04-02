//
//  LZShip.h
//  ZengLab5
//
//  Created by Li Zeng on 3/29/14.
//  Copyright (c) 2014 LZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    ShipTypePatrolBoat,
    ShipTypeSubmarine,
    ShipTypeCruiser,
    ShipTypeBattleship,
    ShipTypeCarrier
}ShipType;


@interface LZShip : NSObject

// Ship Properties

@property (nonatomic, assign)   ShipType type;
@property (nonatomic, assign)   NSInteger length;

// Ship States

@property (nonatomic, strong)   NSMutableArray *segments;
@property (nonatomic, strong)   NSMutableArray *hitSegments;

// Contructor

+ (id)shipWithType:(ShipType)shipType;

- (void)saveShipSegments:(UIView*) shipView;

@end
