//
//  Gem.h
//  PuzD
//
//  Created by Yukinaga Azuma on 2015/03/23.
//  Copyright (c) 2015年 Yukinaga Azuma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Gem : UILabel

@property(nonatomic) id delegate;

-(void)resetGem;

@end

@protocol GemDelegate

-(void)gemMoved:(Gem *)gem;
-(void)gemTouchEnd:(Gem *)gem;

@end