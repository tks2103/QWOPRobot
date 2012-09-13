//
//  QWOPRobot.h
//  QwopRobot
//
//  Created by Tanoy Sinha on 9/7/12.
//  Copyright 2012 SNAP Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "Algorithm.h"

@interface QWOPRobot : NSObject {
@private
    NSWorkspace *ws;
    NSNotificationCenter *nc;
    CGEventRef qdown, qup, wdown, wup, odown, oup, pdown, pup;
    CGEventRef mousedown, mouseup, mouseclosedown, mousecloseup;
    CGEventRef rdown, rup;
    CGEventRef spacedown, spaceup;
    NSImage *distImage;
    NSMutableDictionary *algos;
    int step;
}

@property(nonatomic,retain) NSWorkspace *ws;
@property(nonatomic,retain) NSNotificationCenter *nc;
@property(nonatomic,assign) CGEventRef qdown;
@property(nonatomic,assign) CGEventRef qup;
@property(nonatomic,assign) CGEventRef wdown;
@property(nonatomic,assign) CGEventRef wup;
@property(nonatomic,assign) CGEventRef odown;
@property(nonatomic,assign) CGEventRef oup;
@property(nonatomic,assign) CGEventRef pdown;
@property(nonatomic,assign) CGEventRef pup;
@property(nonatomic,assign) CGEventRef mousedown;
@property(nonatomic,assign) CGEventRef mouseup;
@property(nonatomic,assign) CGEventRef mouseclosedown;
@property(nonatomic,assign) CGEventRef mousecloseup;
@property(nonatomic,assign) CGEventRef rdown;
@property(nonatomic,assign) CGEventRef rup;
@property(nonatomic,assign) CGEventRef spacedown;
@property(nonatomic,assign) CGEventRef spaceup;
@property(nonatomic,retain) NSImage *distImage;
@property(nonatomic,retain) NSMutableDictionary *algos;
@property(nonatomic,assign) int step;

-(void)launchQWOP;
-(void)runQWOP;
-(void)screenGrab;
-(void)writeImages;
-(void)writeDistChunkToFile;
-(void)writeDistChunksToFile:(NSString *)format;
-(void)writeSChunksToFile;
-(void)writeFinishChunkToFile;
-(void)writeImageChunkToFile:(NSImage*) source: (CGPoint) imgSize: (CGPoint) cropSize: (NSString*)fileName;
-(NSBitmapImageRep*)getImageRepFromFile:(NSString*)fileName;
-(void)iterateWithAlgo:(Algorithm*)algo;
-(void)executeKeyPress:(Move*)input;
-(bool)checkSLoc;
-(NSString*)getSLoc;
-(NSString*)getFormatFromSLoc:(int) loc;
-(bool)checkGameOver;
-(void)resetGame;
-(double)getPValue:(NSBitmapImageRep *)imageRep:(NSBitmapImageRep *) compareRep;
-(double)getDistance:(NSString*)format;
-(NSInteger)getNumFromImgRep:(NSBitmapImageRep*) imageRep;
-(bool)isImgS:(NSBitmapImageRep*) imageRep;
-(bool)isImgFinish:(NSBitmapImageRep*) imageRep;

-(void)initAlgos;
-(void)rankAlgos;
-(void)breedAlgos;
-(void)mutateAlgos;

@end
