//
//  Move.h
//  QwopRobot
//
//  Created by Tanoy Sinha on 9/9/12.
//  Copyright (c) 2012 SNAP Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Move : NSObject {
@private
    NSString* keys;
    NSUInteger time;
}

@property (nonatomic, retain) NSString* keys;
@property (nonatomic, assign) NSUInteger time;

-(id)initWithKeys:(NSString*) k andTime:(NSUInteger) t;

@end
