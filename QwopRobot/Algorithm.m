//
//  Algorithm.m
//  QwopRobot
//
//  Created by Tanoy Sinha on 9/9/12.
//  Copyright (c) 2012 SNAP Interactive. All rights reserved.
//

#import "Algorithm.h"

@implementation Algorithm

@synthesize algo, distance, step, elapsedTime;

-(id)init {
    self = [super init];
    if (self) {
        algo = [NSString stringWithFormat:@"qwopqwop"];
        distance = 0;
        step = 0;
        elapsedTime = 0;
    }
    return self;
}

-(id)initWithArray:(NSMutableArray *)moves
{
    self = [super init];
    if (self) {
        algo = moves;
        distance = 0;
        step = 0;
        elapsedTime = 0;
    }
    
    return self;
}

-(bool)isComplete
{
    if (runtime >= 12) {
        return true;
    }
    return false;
}

-(void)resetAlgo
{
    step = 0;
    runtime = 0;
}

-(Move*)nextOperation
{
    if (step >= [algo count])
    {
        step = 0;
    }
    return [algo objectAtIndex:step];
}

-(void)incrementAlgo
{
    step++;
    runtime++;
    NSLog(@"%d", runtime);
}

-(NSComparisonResult)compare:(Algorithm *)otherAlgo
{
    double myDist = [self distance];
    double otherDist = [otherAlgo distance];
    double myTime = [self elapsedTime];
    double otherTime = [otherAlgo elapsedTime];
    
    double myCompare = myDist*5 + myTime;
    double otherCompare = otherDist*5 + otherTime;
    return myCompare < otherCompare;
}

-(Algorithm*)breedWith:(Algorithm *)otherAlgo
{
    NSArray *array1 = [self algo], *array2 = [otherAlgo algo];
    NSMutableArray *algoArray = [[NSMutableArray alloc] init];
    
    [algoArray addObjectsFromArray:[array1 subarrayWithRange:NSMakeRange(0, [array1 count]/2)]];
    [algoArray addObjectsFromArray:[array2 subarrayWithRange:NSMakeRange([array2 count]/2, [array2 count]/2)]];
    
    Algorithm *newAlgo = [[Algorithm alloc]initWithArray:algoArray];
    return newAlgo;
}

-(Algorithm*)mutateAlgo
{
    NSMutableArray *algoArray = [self algo];
    int i = arc4random() % [algoArray count];
    int p = arc4random() % 12;
    if (p >= 11) {
        return self;
    } else if (p >= 8) {
        //duplicate
        Move *addMove = [algoArray objectAtIndex:i];
        [algoArray insertObject:addMove atIndex:i];
    } else if (p >= 7) {
        //delete
        [algoArray removeObjectAtIndex:i];
    } else {
        //insertnew
        Move *addMove = [[Move alloc]init];
        [algoArray insertObject:addMove atIndex:i];
    }
    Algorithm *newAlgo = [[Algorithm alloc]initWithArray:algoArray];
    return [newAlgo autorelease];
}

-(void)log
{
    int iter = 0;
    NSLog(@"Algorithm:");
    for (id item in algo) {
        iter++;
        NSLog(@"Move %d: Keys: %@ Time: %lu", iter, [item keys], [item time]);
    }
}

@end
