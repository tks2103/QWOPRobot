//
//  Algorithm.h
//  QwopRobot
//
//  Created by Tanoy Sinha on 9/9/12.
//  Copyright (c) 2012 SNAP Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Move.h"

@interface Algorithm : NSObject {
@private
    NSMutableArray *algo;
    double distance;
    double elapsedTime;
    int step;
    int runtime;
}

@property (nonatomic, retain) NSMutableArray *algo;
@property (nonatomic, assign) double distance;
@property (nonatomic, assign) double elapsedTime;
@property (nonatomic, assign) int step;
@property (nonatomic, assign) int runtime;

-(id)initWithArray:(NSMutableArray *) moves;
-(bool)isComplete;
-(void)resetAlgo;
-(Move*)nextOperation;
-(void)incrementAlgo;
-(NSComparisonResult)compare:(Algorithm *)otherAlgo;
-(Algorithm*)breedWith:(Algorithm*)otherAlgo;
-(Algorithm*)mutateAlgo;
-(void)log;

@end
