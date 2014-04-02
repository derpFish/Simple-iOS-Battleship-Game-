//
//  LZGameViewController.m
//  ZengLab5
//
//  Created by Li Zeng on 3/29/14.
//  Copyright (c) 2014 LZ. All rights reserved.
//

#import "LZGameViewController.h"

@interface LZGameViewController ()
{
    CGPoint lpStartPoint, lpEndPoint;
}

@end

@implementation LZGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle: nil];
    if (self) {
        _waitView = [[[NSBundle mainBundle] loadNibNamed:@"WaitView" owner:self options:nil] objectAtIndex:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self GamePreparation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.shipViewSubmarine setShipType: ShipTypeSubmarine];
    [self.shipViewBattleShip setShipType: ShipTypeBattleship];
    [self.shipViewCarrier setShipType: ShipTypeCarrier];
    [self.shipViewCruiser setShipType: ShipTypeCruiser];
    [self.shipViewPatrolBoat setShipType: ShipTypePatrolBoat];
    
    [self.shipViewSubmarine_ setShipType: ShipTypeSubmarine];
    [self.shipViewBattleship_ setShipType: ShipTypeBattleship];
    [self.shipViewCarrier_ setShipType: ShipTypeCarrier];
    [self.shipViewCruiser_ setShipType: ShipTypeCruiser];
    [self.shipViewPatrolBoat_ setShipType: ShipTypePatrolBoat];
    
    [self.shipViewSubmarine setPlayer: PlayerOne];
    [self.shipViewBattleShip setPlayer: PlayerOne];
    [self.shipViewCarrier setPlayer: PlayerOne];
    [self.shipViewCruiser setPlayer: PlayerOne];
    [self.shipViewPatrolBoat setPlayer: PlayerOne];
    
    [self.shipViewSubmarine_ setPlayer: PlayerTwo];
    [self.shipViewBattleship_ setPlayer: PlayerTwo];
    [self.shipViewCarrier_ setPlayer: PlayerTwo];
    [self.shipViewCruiser_ setPlayer: PlayerTwo];
    [self.shipViewPatrolBoat_ setPlayer: PlayerTwo];
    
    // store original data for restore
    
    [self.shipViewSubmarine store];
    [self.shipViewBattleShip store];
    [self.shipViewCarrier store];
    [self.shipViewCruiser store];
    [self.shipViewPatrolBoat store];
    
    [self.shipViewSubmarine_ store];
    [self.shipViewBattleship_ store];
    [self.shipViewCarrier_ store];
    [self.shipViewCruiser_ store];
    [self.shipViewPatrolBoat_ store];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma GameDelegate Methods

- (void)GamePreparation
{
    [[self game] setGameState: GameStatePreparation];
    _shipLocationView.delegate = self;
    _shipHitView.delegate = self;
    [[self shipHitView] setTapGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:[self shipHitView] action:@selector(doTap:)]];
    [[self shipHitView] addGestureRecognizer:[[self shipHitView] tapGestureRecognizer]];
    self.game = [[LZGame alloc] init];
    self.game.playerOne = [[LZPlayer alloc] init];
    self.game.playerTwo = [[LZPlayer alloc] init];
    [[self gameStateLabel] setText:@"Battleship"];
    
    // Show Alert View to choose play mode
    self.entryPopView = [[UIAlertView alloc] initWithTitle:@"Battleship" message:@"Welcome to play Battleship, this game is developed by Li Zeng. Please choose different play mode below." delegate: self cancelButtonTitle:nil otherButtonTitles:@"Human VS Human", @"Human VS Computer", nil];
    [[self entryPopView] show];
    
    [self setCurrentPlayer: PlayerOne]; // This is a initial State
    [self ShipPlacement];
}

- (void)ShipPlacement
{
    [[self game] setGameState: GameStatePlacing];
    [self restoreBoats:[self currentPlayer]];
    [[self gameStateLabel] setText:[NSString stringWithFormat:@"%@%d%@", @"Player ", self.currentPlayer + 1, @" is placing ships, long press ship to rotate"]];
}

- (void)endShipPlacement
{
    LZPlayer *playerOne = [[self game] playerOne];
    LZPlayer *playerTwo = [[self game] playerTwo];
    BOOL playerOneReady = [[playerOne ships] count] == 5;
    BOOL playerTwoReady = [[playerTwo ships] count] == 5;
    if (playerOneReady && playerTwoReady) {
        PlayerNumber randomPlayer = arc4random() % 10 < 5? PlayerOne : PlayerTwo;
        [self GamePlaying: randomPlayer];
    } else if (!playerOneReady) {
        self.navigationItem.rightBarButtonItem = nil;
        [self setCurrentPlayer: PlayerOne];
        [self ShipPlacement];
    } else if (!playerTwoReady) {
        self.navigationItem.rightBarButtonItem = nil;
        // Handle Different Play Mode
        if ([[self game] gameMode] == HumanVSHuman) {
            [self setCurrentPlayer: PlayerTwo];
            [self ShipPlacement];
        } else {
            PlayerNumber randomPlayer = arc4random() % 10 < 5? PlayerOne : PlayerTwo;
            [self setCurrentPlayer: randomPlayer];
            [self AIShipPlacement];
            [self GamePlayWithAI];
        }
    }
}

- (void)GamePlaying:(int) player
{
    [[self game] setGameState: GameStatePlaying];
    [[self navigationItem] setRightBarButtonItem: nil];
    [self setCurrentPlayer: player];
    [[self gameStateLabel] setText:[NSString stringWithFormat:@"%@%d%@", @"Player ", self.currentPlayer + 1, @" is playing"]];
    // Re-draw with Player Data
    [self restoreBoats: player];
    [self restoreGridView: player];
}

- (void)GameQuitWithReason: (GameReason) reason
{
    // Show Alert View to glory
    NSString *msg = [NSString stringWithFormat:@"%@%d%@", @"Congratulation!!! Player ", [[self game] winner] + 1, @" wins the game! Want to play again?", nil];
    self.resultPopView = [[UIAlertView alloc] initWithTitle:@"Battleship" message:msg delegate: self cancelButtonTitle:nil otherButtonTitles:@"Play Again", nil];
    [[self resultPopView] show];
}

- (void)GameRestart
{
    [self restoreEverything];
    [self GamePreparation];
}

- (void)AIShipPlacement
{
    // Present Wait View
    [self.view addSubview: self.waitView];
    [self doPlacement: self.shipViewBattleship_];
    [self doPlacement: self.shipViewCarrier_];
    [self doPlacement: self.shipViewPatrolBoat_];
    [self doPlacement: self.shipViewSubmarine_];
    [self doPlacement: self.shipViewCruiser_];
    // remove Wait View
    [NSTimer scheduledTimerWithTimeInterval: 2.0f target:self.waitView selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
}

- (void)doPlacement:(LZShipView*) shipView
{
    while (true) {
        float x = arc4random() % 480 + 30;
        float y = arc4random() % 480 + 100;
        BOOL isRotated = arc4random() % 10 < 5? YES : NO;
        shipView.isRotated = isRotated;
        [shipView setCenter:CGPointMake(x, y)];
        if ([self moveShip:shipView toLocation: CGPointMake(x, y)]) {
            [self saveShipSegment:shipView ShipType:[shipView shipType] Player: PlayerTwo];
            break;
        }
    }
}

- (void)GamePlayWithAI
{
    [[self game] setGameState: GameStatePlaying];
    // AI Turn
    if ([self currentPlayer] == PlayerTwo) {
        // Present Wait View
        [self.view addSubview: self.waitView];
        // Calculate and perform click
        BOOL retCode = NO;
        while (true) {
            CGPoint aiPoint = [[self game] calculateAIHitPoint: retCode];

            retCode = [self.shipHitView addTargetViewAtPoint: aiPoint];
            if (retCode == NO) {
                break;
            }
        }
        // move onto next
        [self nextMove];
        // remove Wait View
        [NSTimer scheduledTimerWithTimeInterval: 2.0f target:self.waitView selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
    }
    // Human Turn
    else {
        // Always PlayerOne
        [self GamePlaying: PlayerOne];
    }
}

#pragma IBAction Gesture Reactors

// To Rotate the ship

- (IBAction)shipLongPressReactor:(id)sender
{
    // Get long Pressed View
    LZShipView *shipView = (LZShipView*)[sender view];
    
    if ([sender state] == UIGestureRecognizerStateBegan)
    {
        lpStartPoint = [shipView center];
    }
    
    if ([sender state] == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:0.3 animations:^{
            
            CGAffineTransform transform = [shipView transform];
           
            transform = [shipView isRotated]? CGAffineTransformIdentity : CGAffineTransformRotate(transform, M_PI_2);
            
            [shipView setTransform: transform];
            [shipView setIsRotated:![shipView isRotated]];
        }];
    }
    
    // Bring ship view to the front
    if ([[shipView superview] isEqual:[self view]]) {
        [shipView setCenter:[sender locationInView: [self view]]];
        [[self view] bringSubviewToFront: shipView];
    } else {
        [shipView setCenter:[sender locationInView:[self shipLocationView]]];
        [[self shipLocationView] bringSubviewToFront: shipView];
    }
    
    if ([sender state] == UIGestureRecognizerStateChanged) {
        shipView.center = [[shipView superview] isEqual: [self view]]? [sender locationInView:[self view]] : [sender locationInView:[self shipLocationView]];
    }
    
    if ([sender state] == UIGestureRecognizerStateEnded) {
        lpEndPoint = shipView.center;
        // move ship to the final point
        if (![self moveShip:shipView toLocation:lpEndPoint]) {
            [UIView animateWithDuration: 0.3 animations: ^{
               
                CGAffineTransform transform = [shipView transform];

                transform = [shipView isRotated]? CGAffineTransformIdentity : CGAffineTransformRotate(transform, M_PI_2);
                
                [shipView setTransform: transform];
                [shipView setIsRotated:![shipView isRotated]];
                
                [shipView setCenter: lpStartPoint];
                
            }];
        } else {
            // save position
            [self saveShipSegment:shipView ShipType:[shipView shipType] Player: [self currentPlayer]];
        }
    }
    
}

- (IBAction)shipPanGestureReactor:(id)sender
{
    // Get dragging View
    LZShipView *shipView = (LZShipView*)[sender view];
    
    if ([sender state] == UIGestureRecognizerStateBegan) {
        lpStartPoint = [shipView center];
    }
    
    // Bring ship in front of all other ships
    if ([[shipView superview] isEqual:[self view]]) {
        [[self view] bringSubviewToFront:shipView];
    } else {
        [[self shipLocationView] bringSubviewToFront:shipView];
    }
    
    // Get the translation of the gesture
    CGPoint translation = [sender translationInView:[shipView superview]];
    CGPoint effectiveTranslation = CGPointApplyAffineTransform(translation, CGAffineTransformIdentity);
    
    int newX = shipView.center.x + effectiveTranslation.x;
    int newY = shipView.center.y + effectiveTranslation.y;
    
    shipView.center = (CGPoint){newX, newY};
    
    [sender setTranslation:CGPointZero inView:shipView];
    
    if ([sender state] == UIGestureRecognizerStateEnded) {
        
        lpEndPoint = shipView.center;
        
        if (![self moveShip:shipView toLocation: lpEndPoint]) {
            [UIView animateWithDuration:0.5 animations:^{
                [shipView setCenter:lpStartPoint];
            }];
        } else {
            [self saveShipSegment:shipView ShipType:[shipView shipType] Player: [self currentPlayer]];
        }
    }
}

#pragma ship view movement method

- (BOOL)moveShip:(LZShipView*)shipView toLocation:(CGPoint)point
{
    // Already containig such ship
    CGPoint endPointOnBoard = [[self shipLocationView] convertPoint: point fromView: [shipView superview]];
    CGRect frameOnBoard = [[self shipLocationView] convertRect:[shipView frame] fromView:[shipView superview]];
    
    // see if in the board
    if (CGRectContainsPoint([[self shipLocationView] bounds], endPointOnBoard))
    {
        // check if overlap
        BOOL isOverlap = NO;
        for (LZShipView *subView in [[self shipLocationView] subviews])
        {
            if (![subView isEqual: shipView] && [subView player] == [shipView player]) {
                if (CGRectIntersectsRect(frameOnBoard, [subView frame]))
                    isOverlap = YES;
            }
        }
        
        if (isOverlap) {
            return NO;
        }
        
        // Check if ship place is out of bounds
        BOOL shipOdd = shipView.bounds.size.width > shipView.bounds.size.height?
        fmod(shipView.bounds.size.width / CELLSIZE, 2) == 1
        :
        fmod(shipView.bounds.size.height / CELLSIZE, 2) == 1;
        
        BOOL shipRotated = shipView.frame.size.width < shipView.frame.size.height;
        
        CGPoint nearestPoint = [self nearestPoint:endPointOnBoard isOdd:shipOdd isRotated:shipRotated];
        
        CGPoint translation = CGPointMake((nearestPoint.x - endPointOnBoard.x), (nearestPoint.y - endPointOnBoard.y));
        CGRect checkFrame = CGRectMake(frameOnBoard.origin.x + translation.x, frameOnBoard.origin.y + translation.y, frameOnBoard.size.width, frameOnBoard.size.height);
        
        if (!CGRectContainsRect([[self shipLocationView] bounds], checkFrame)) {
            return NO;
        }
        
        // Yep, Go ahead
        if (![[[self shipLocationView] subviews] containsObject:shipView]) {
            // IMPORTANT: To avoid misplacing in the previous superview.
            [shipView removeFromSuperview];
            [[self shipLocationView] addSubview: shipView];
            [shipView setFrame: frameOnBoard];
        }
        
        [UIView animateWithDuration:0.3f animations:^{
            [shipView setCenter: nearestPoint];
        }];
        
        return YES;
    }
    return NO;
}

// Method to Avoid Misplacing on the board

- (CGPoint) nearestPoint: (CGPoint) endPoint isOdd: (BOOL) isOdd isRotated: (BOOL) isRotated
{
    CGPoint newPoint;
    
    NSInteger xIndex = endPoint.x / CELLSIZE;
    NSInteger yIndex = endPoint.y / CELLSIZE;
    
    if (!isRotated)
    {
        if (isOdd) {
            newPoint.x = xIndex * CELLSIZE + (CELLSIZE / 2.0);
            newPoint.y = yIndex * CELLSIZE + (CELLSIZE / 2.0);
        } else {
            if (endPoint.x - (xIndex * CELLSIZE) < (CELLSIZE / 2.0)) {
                newPoint.x = xIndex * CELLSIZE;
            } else {
                newPoint.x = (xIndex + 1) * CELLSIZE;
            }
            
            newPoint.y = yIndex * CELLSIZE + (CELLSIZE / 2.0);
        }
    } else {
        if (isOdd) {
            newPoint.x = xIndex * CELLSIZE + (CELLSIZE / 2.0);
            newPoint.y = yIndex * CELLSIZE + (CELLSIZE / 2.0);
            
        } else {
            newPoint.x = xIndex * CELLSIZE + (CELLSIZE / 2.0);
            
            if (endPoint.y - (yIndex * CELLSIZE) < (CELLSIZE / 2.0)) {
                newPoint.y = yIndex * CELLSIZE;
            } else {
                newPoint.y = (yIndex + 1) * CELLSIZE;
            }
        }
    }
    return newPoint;
}

#pragma Save Ship Segment 

- (void)saveShipSegment:(LZShipView*)shipView ShipType:(ShipType)shipType Player:(PlayerNumber) playerNumber
{
    LZPlayer *player = playerNumber == PlayerOne? [[self game] playerOne] : [[self game] playerTwo];
    LZShip *ship = [self reuseShipWithType: shipType Player: playerNumber];
    [ship saveShipSegments: shipView];
    [[player ships] addObject: ship];
    // Time to "ready" and trigger next stage
    [shipView setUserInteractionEnabled: NO];
    if ([[player ships] count] == 5) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Ready" style:UIBarButtonItemStylePlain target:self action:@selector(endShipPlacement)];
    }
}

- (LZShip*)reuseShipWithType:(ShipType) shipType Player:(PlayerNumber) playerNumber
{
    LZPlayer *player = playerNumber == PlayerOne? [[self game] playerOne] : [[self game] playerTwo];
    for (LZShip *ship in [player ships]) {
        if ([ship type] == shipType) {
            return ship;
        }
    }
    LZShip *ship = [LZShip shipWithType: shipType];
    return ship;
}

#pragma UIAlertView Delegate Method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual: [self entryPopView]]) {
        if (buttonIndex == 0) {
            [[self game] setGameMode: HumanVSHuman];
        } else if (buttonIndex == 1) {
            [[self game] setGameMode: HumanVSComputer];
            [[[self game] playerOne] setType: PlayerHuman];
            [[[self game] playerTwo] setType: PlayerComputer];
        }
    } else if ([alertView isEqual: [self resultPopView]]) {
        if (buttonIndex == 0) {
            [self GameRestart];
        }
    }
}

#pragma UI Control Methods

// For Ships

- (void)restoreBoats:(PlayerNumber) playerNumber
{
    if (playerNumber == PlayerOne) {
        self.shipViewPatrolBoat.hidden = NO;
        self.shipViewCarrier.hidden = NO;
        self.shipViewCruiser.hidden = NO;
        self.shipViewSubmarine.hidden = NO;
        self.shipViewBattleShip.hidden = NO;
        
        self.shipViewPatrolBoat_.hidden = YES;
        self.shipViewCarrier_.hidden = YES;
        self.shipViewCruiser_.hidden = YES;
        self.shipViewSubmarine_.hidden = YES;
        self.shipViewBattleship_.hidden = YES;
    } else {
        self.shipViewPatrolBoat.hidden = YES;
        self.shipViewCarrier.hidden = YES;
        self.shipViewCruiser.hidden = YES;
        self.shipViewSubmarine.hidden = YES;
        self.shipViewBattleShip.hidden = YES;
    
        self.shipViewPatrolBoat_.hidden = NO;
        self.shipViewCarrier_.hidden = NO;
        self.shipViewCruiser_.hidden = NO;
        self.shipViewSubmarine_.hidden = NO;
        self.shipViewBattleship_.hidden = NO;
    }
}

// For Grid View State

- (void)restoreGridView:(PlayerNumber) playerNumber
{
    [self unlockGridView];
    // update ship hit view
    for (UIView* subView in [self.shipHitView subviews]) {
        if (subView.tag == 10) {
            subView.hidden = (playerNumber != PlayerOne)? YES : NO;
        } else if (subView.tag == 11){
            subView.hidden = (playerNumber != PlayerTwo)? YES : NO;
        }
    }
    // update ship location view
    for (UIView *subView in [self.shipLocationView subviews]) {
        if (subView.tag == 10) {
            subView.hidden = (playerNumber != PlayerOne)? YES : NO;
        } else if (subView.tag == 11){
            subView.hidden = (playerNumber != PlayerTwo)? YES : NO;
        }
    }
}

// For Grid View

- (void)lockupGridView
{
    [_shipHitView setUserInteractionEnabled: NO];
    [_shipLocationView setUserInteractionEnabled: NO];
}

- (void)unlockGridView
{
    [_shipHitView setUserInteractionEnabled: YES];
    [_shipLocationView setUserInteractionEnabled: YES];
}

// A bit of logic

- (void)nextMove
{
    // If AI
    if ([[self game] gameMode] == HumanVSComputer)
    {
        [self setCurrentPlayer: self.currentPlayer == PlayerOne? PlayerTwo : PlayerOne];
        [self GamePlayWithAI];
    }
    // Handle Human VS Human
    else {
        // From Player One to Player Two
        if ([self currentPlayer] == PlayerOne) {
            [self GamePlaying: PlayerTwo];
        }
        // From Player Two To Player One
        else {
            [self GamePlaying: PlayerOne];
        }
    }
}

// Finally We would start over before doing so we need to get everyting back

- (void)restoreEverything
{
    // Remove all subviews
    for (UIView *subView in [[self shipLocationView] subviews]) {
        [subView removeFromSuperview];
    }
    for (UIView *subView in [[self shipHitView] subviews]) {
        [subView removeFromSuperview];
    }
    // Reset Ship View
    [self.shipViewBattleShip restore];
    [self.shipViewCarrier restore];
    [self.shipViewCruiser restore];
    [self.shipViewPatrolBoat restore];
    [self.shipViewSubmarine restore];
    
    [self.shipViewBattleship_ restore];
    [self.shipViewCarrier_ restore];
    [self.shipViewCruiser_ restore];
    [self.shipViewPatrolBoat_ restore];
    [self.shipViewSubmarine_ restore];
}

@end























