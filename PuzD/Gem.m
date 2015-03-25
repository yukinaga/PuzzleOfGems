//
//  Gem.m
//  PuzD
//
//  Created by Yukinaga Azuma on 2015/03/23.
//  Copyright (c) 2015年 Yukinaga Azuma. All rights reserved.
//

#import "Gem.h"
#import "Definisions.h"

@implementation Gem{
    NSArray *iconArray;
}

-(void)didMoveToSuperview{
    self.userInteractionEnabled = YES;
    iconArray = @[@"🍅", @"🍆", @"🍉", @"🍄", @"🍊"];
    int rand = arc4random() % [iconArray count];
    self.font = [UIFont fontWithName:nil size:GEM_SIZE];
    self.text = iconArray[rand];
    self.textAlignment = NSTextAlignmentCenter;
}

-(void)resetGem{
    int rand = arc4random() % [iconArray count];
    self.text = iconArray[rand];
    self.transform = CGAffineTransformIdentity;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.superview bringSubviewToFront:self];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    
    CGFloat dx = [touch locationInView:self.superview].x
    -[touch previousLocationInView:self.superview].x;
    CGFloat dy = [touch locationInView:self.superview].y
    -[touch previousLocationInView:self.superview].y;
    
    self.center = CGPointMake(self.center.x+dx,
                              self.center.y+dy);
    
    [self.delegate gemMoved:self];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.delegate gemTouchEnd:self];
}

@end
