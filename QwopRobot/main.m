//
//  main.m
//  QwopRobot
//
//  Created by Tanoy Sinha on 9/7/12.
//  Copyright 2012 SNAP Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "QWOPRobot.h"


int main (int argc, const char * argv[])
{

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    // insert code here...
    NSLog(@"Hello, World!");

    QWOPRobot *robot = [[QWOPRobot alloc] init];
    [robot runQWOP];
    [robot release];
    [pool drain];
    return 0;
}

void launchQWOP() {
    
}