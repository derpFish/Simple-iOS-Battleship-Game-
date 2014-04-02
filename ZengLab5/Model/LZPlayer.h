//
//  LZPlayer.h
//  ZengLab5
//
//  Created by Li Zeng on 3/29/14.
//  Copyright (c) 2014 LZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LZShipView.h"

typedef enum
{
	PlayerHuman,
	PlayerComputer,
    HumanVSHuman,
    HumanVSComputer,
}PlayerType;

@interface LZPlayer : NSObject

@property (nonatomic, assign)   PlayerType type;
@property (nonatomic, strong)   NSString *name;
@property (nonatomic)           NSInteger playerID;

@property (nonatomic, strong)   NSMutableArray *ships;

@end
