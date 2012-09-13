//
//  Move.m
//  QwopRobot
//
//  Created by Tanoy Sinha on 9/9/12.
//  Copyright (c) 2012 SNAP Interactive. All rights reserved.
//

#import "Move.h"

@implementation Move

@synthesize keys, time;

-(id)init {
    self = [super init];
    if (self) {
        NSString *rand = @"qwop";
        int l = arc4random() % [rand length];
        NSUInteger t = arc4random() % 1400000 + 100000;
        
        keys = [NSString stringWithFormat:@"%c",[rand characterAtIndex:l]];
        time = t;
    }
    return self;
}

-(id)initWithKeys:(NSString*)k andTime:(NSUInteger) t
{
    self = [super init];
    if (self) {
        keys = k;
        if (t < 100000){
            t = 100000;
        }
        if (t > 1500000) {
            t = 1500000;
        }
        time = t;
    }
    return self;
}

@end
