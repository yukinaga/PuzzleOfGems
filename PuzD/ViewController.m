//
//  ViewController.m
//  PuzD
//
//  Created by Yukinaga Azuma on 2015/03/23.
//  Copyright (c) 2015年 Yukinaga Azuma. All rights reserved.
//

#import "ViewController.h"
#import "Gem.h"
#import "Definisions.h"

@interface ViewController()<GemDelegate>
{
    NSMutableArray *gemArray;
    IBOutlet UISegmentedControl *gameTypeControl;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    gemArray = [NSMutableArray new];

    [self arrangeGems];
    [self removeVanishingGems];
}

-(void)arrangeGems{
    for (int i=0; i<HORIZONTAL_COUNT*VERTICAL_COUNT; i++) {
        Gem *gem = [Gem new];
        gem.frame = CGRectMake(0, 0, GEM_SIZE, GEM_SIZE);
        gem.center = CGPointMake([self xPositionFromIndex:i],
                                 [self yPositionFromIndex:i]);
        gem.delegate = self;
        [self.view addSubview:gem];
        [gemArray addObject:gem];
    }
}

-(void)removeVanishingGems{
    while (1) {
        NSSet *vanishingGems;
        if (gameTypeControl.selectedSegmentIndex == 0) {
            vanishingGems = [self detectLinedGems];
        }else{
            vanishingGems = [self detecLinkedGems];
        }
        
        if ([vanishingGems count] == 0) {
            break;
        }
        for (Gem *gem in vanishingGems) {
            [gem resetGem];
        }
    }
}

-(void)gemMoved:(Gem *)gem{
    for (Gem *gm in gemArray) {
        if (gm == gem) {
            continue;
        }
        CGFloat dx = gm.center.x - gem.center.x;
        CGFloat dy = gm.center.y - gem.center.y;
        CGFloat distance2 = dx*dx + dy*dy;
        if (distance2 < EXCHANGE_DISTANCE*EXCHANGE_DISTANCE) {
            int gemIndex = (int)[gemArray indexOfObject:gem];
            int gmIndex = (int)[gemArray indexOfObject:gm];
            
            //for-in構文の中で配列の要素を入れ替えるために必要
            dispatch_async(dispatch_get_main_queue(), ^{
                [gemArray replaceObjectAtIndex:gemIndex withObject:gm];
                [gemArray replaceObjectAtIndex:gmIndex withObject:gem];
            });
         
            [UIView animateWithDuration:0.2
                             animations:^{
                                 gm.center = CGPointMake([self xPositionFromIndex:gemIndex],
                                                         [self yPositionFromIndex:gemIndex]);
                             } completion:^(BOOL finished) {

                             }];
        }
    }
}

-(void)gemTouchEnd:(Gem *)gem{
    int gemIndex = (int)[gemArray indexOfObject:gem];
    [UIView animateWithDuration:0.2
                     animations:^{
                         gem.center = CGPointMake([self xPositionFromIndex:gemIndex],
                                                  [self yPositionFromIndex:gemIndex]);
                     } completion:^(BOOL finished) {
                         [self vanishGems];
                     }];
}

-(NSSet *)detectLinedGems{
    NSMutableSet *linedGem = [NSMutableSet new];
    //横方向の探索
    for (int i=VERTICAL_COUNT; i<[gemArray count]-VERTICAL_COUNT; i++) {
        Gem *previousGem = gemArray[i-VERTICAL_COUNT];
        Gem *gem = gemArray[i];
        Gem *nextGem = gemArray[i+VERTICAL_COUNT];
        if ([gem.text isEqualToString:previousGem.text] &&
            [gem.text isEqualToString:nextGem.text]) {
            [linedGem  addObject:previousGem];
            [linedGem addObject:gem];
            [linedGem addObject:nextGem];
        }
    }
    //縦方向の探索
    for (int i=0; i<[gemArray count]; i++) {
        if (i%VERTICAL_COUNT ==0 || i%VERTICAL_COUNT == VERTICAL_COUNT-1) {
            continue;
        }
        Gem *previousGem = gemArray[i-1];
        Gem *gem = gemArray[i];
        Gem *nextGem = gemArray[i+1];
        if ([gem.text isEqualToString:previousGem.text] &&
            [gem.text isEqualToString:nextGem.text]) {
            [linedGem  addObject:previousGem];
            [linedGem addObject:gem];
            [linedGem addObject:nextGem];
        }
    }
    return linedGem;
}

-(NSSet *)detecLinkedGems{
    //同じ表示のペアの検索
    NSMutableArray *linkedPairs = [NSMutableArray new];
    for (int i=0; i<[gemArray count]; i++) {
        Gem *gem = gemArray[i];
        if (i/VERTICAL_COUNT < HORIZONTAL_COUNT-1) {
            Gem *nextGem = gemArray[i+VERTICAL_COUNT];
            if ([gem.text isEqualToString:nextGem.text]) {
                [linkedPairs addObject:@[gem, nextGem]];
            }
        }
        if (i%VERTICAL_COUNT < VERTICAL_COUNT-1) {
            Gem *nextGem = gemArray[i+1];
            if ([gem.text isEqualToString:nextGem.text]) {
                [linkedPairs addObject:@[gem, nextGem]];
            }
        }
    }
    
    //ペアのグループ化
    NSMutableSet *linkedGems = [NSMutableSet new];
    while ([linkedPairs count]>0) {
        NSMutableSet *linkedSet = [NSMutableSet new];
        NSArray *aPair = linkedPairs[0];
        [linkedPairs removeObject:aPair];
        [linkedSet addObjectsFromArray:aPair];
        for (int i=0; i<[linkedPairs count]; i++) {
            NSArray *bPair = linkedPairs[i];
            for (Gem *gem in bPair) {
                if ([linkedSet containsObject:gem]) {
                    [linkedPairs removeObject:bPair];
                    [linkedSet addObjectsFromArray:bPair];
                    i=-1;
                    break;
                }
            }
        }

        if ([linkedSet count] >= 4) {
            [linkedGems unionSet:linkedSet];
        }
    }
    
    return linkedGems;
}

-(void)vanishGems{
    NSSet *targetGems;
    if (gameTypeControl.selectedSegmentIndex == 0) {
        targetGems = [self detectLinedGems];
    }else{
        targetGems = [self detecLinkedGems];
    }
    if ([targetGems count] == 0) {
        [self enableAllGems];
        return;
    }
    [self disableAllGems];
    [UIView animateWithDuration:0.5
                     animations:^{
                         for (Gem *gem in targetGems) {
                             gem.transform = CGAffineTransformMakeScale(0.01, 0.01);
                         }
                     } completion:^(BOOL finished) {
                         for (Gem *gem in targetGems) {
                             gem.text = @"";
                             gem.transform = CGAffineTransformIdentity;
                         }
                         [self fallGems];
                     }];
}

-(void)fallGems{
    for (int i=0; i<HORIZONTAL_COUNT; i++) {
        int startIndex = VERTICAL_COUNT*i;
        int endIndex = VERTICAL_COUNT*(i+1)-1;
        for (int j=startIndex; j<=endIndex; j++) {
            Gem *gem = gemArray[j];
            if ([gem.text isEqualToString:@""]) {
                for (int k=j; k>startIndex; k--) {
                    Gem *uGem = gemArray[k-1];
                    Gem *dGem = gemArray[k];
                    [gemArray replaceObjectAtIndex:k withObject:uGem];
                    [gemArray replaceObjectAtIndex:k-1 withObject:dGem];
                }
            }

        }
    }
    
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         for (int i=0; i<[gemArray count]; i++) {
                             Gem *gem = gemArray[i];
                             if (![gem.text isEqualToString:@""]) {
                                 gem.center = CGPointMake([self xPositionFromIndex:i],
                                                          [self yPositionFromIndex:i]);
                             }
                         }
                     } completion:^(BOOL finished){
                         [self fallNewGems];
                     }];
}

-(void)fallNewGems{
    NSMutableArray *newGems = [NSMutableArray new];
    for (int i=0; i<[gemArray count]; i++) {
        Gem *gem = gemArray[i];
        if ([gem.text isEqualToString:@""]) {
            gem.center = CGPointMake([self xPositionFromIndex:i],
                                     [self yPositionFromIndex:i]-GEM_SIZE*VERTICAL_COUNT);
            [gem resetGem];
            [newGems addObject:gem];
        }
    }
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         for (Gem *gem in newGems) {
                             gem.center = CGPointMake(gem.center.x,
                                                      gem.center.y+GEM_SIZE*VERTICAL_COUNT);
                         }
                     } completion:^(BOOL finished){
                         [self vanishGems];
                     }];
}

-(CGFloat)xPositionFromIndex:(int)index{
    return (self.view.frame.size.width
            - GEM_SIZE*HORIZONTAL_COUNT)/2
            + GEM_SIZE/2
            + GEM_SIZE*(index/VERTICAL_COUNT);
}

-(CGFloat)yPositionFromIndex:(int)index{
    return (self.view.frame.size.height
            - GEM_SIZE*HORIZONTAL_COUNT)/2
            + GEM_SIZE/2
            + GEM_SIZE*(index%VERTICAL_COUNT);
}

-(void)enableAllGems{
    for (Gem *gem in gemArray) {
        gem.userInteractionEnabled = YES;
    }
}

-(void)disableAllGems{
    for (Gem *gem in gemArray) {
        gem.userInteractionEnabled = NO;
    }
}

-(IBAction)gameTypeChanged:(UISegmentedControl *)sender{
    [self vanishGems];
}

@end
