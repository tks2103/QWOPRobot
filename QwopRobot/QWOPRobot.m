//
//  QWOPRobot.m
//  QwopRobot
//
//  Created by Tanoy Sinha on 9/7/12.
//  Copyright 2012 SNAP Interactive. All rights reserved.
//

#import "QWOPRobot.h"
#define IMG_BASE_X          250
#define IMG_BASE_Y          30
#define IMG_BASE_CROP_X     200
#define IMG_BASE_CROP_Y     673

#define IMG_FINISH_X          5
#define IMG_FINISH_Y          5
#define IMG_FINISH_CROP_X     150
#define IMG_FINISH_CROP_Y     582

#define IMG_CHKS2d_X          17
#define IMG_CHKS2d_Y          25
#define IMG_CHKS2d_CROP_X     172
#define IMG_CHKSn2d_CROP_X    178
#define IMG_CHKS1d_CROP_X     159
#define IMG_CHKSn1d_CROP_X    165
#define IMG_CHKS2d_CROP_Y     0

#define PVAL_S              7

#define KEY_COOLDOWN            500000

@implementation QWOPRobot

@synthesize ws, nc, qdown, qup, wdown, wup, odown, oup, pdown, pup, mousedown, mouseup, mouseclosedown, mousecloseup, rdown, rup, spacedown, spaceup, distImage, algos, step;

- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"Made a QWOPRobot");
        ws = [NSWorkspace sharedWorkspace];
        nc = [ws notificationCenter];
        algos = [[NSMutableDictionary alloc] init];
        
        [self initAlgos];
    
        qdown = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)12, true);
        qup = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)12, false);
        
        wdown = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)13, true);
        wup = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)13, false);
        
        odown = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)31, true);
        oup = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)31, false);
        
        pdown = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)35, true);
        pup = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)35, false);
        
        rdown = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)15, true);
        rup = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)15, false);

        spacedown = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)49, true);
        spaceup = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)49, false);
        
        mousedown = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, CGPointMake(50, 50), kCGMouseButtonLeft);
        mouseup = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, CGPointMake(50, 50), kCGMouseButtonLeft);

        mouseclosedown = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, CGPointMake(18, 32), kCGMouseButtonLeft);
        mousecloseup = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, CGPointMake(18, 32), kCGMouseButtonLeft);
        
        [self launchQWOP];
        sleep(1);
        CGEventPost(kCGHIDEventTap, mousedown);
        CGEventPost(kCGHIDEventTap, mouseup);
        [self writeImages];
    }
    
    return self;
}

- (void)dealloc
{
    [algos release];
    [ws release];
    [nc release];
    [distImage release];
    CGEventPost(kCGHIDEventTap, mouseclosedown);
    CGEventPost(kCGHIDEventTap, mousecloseup);
    [super dealloc];
}

- (void)launchQWOP
{
    [[NSWorkspace sharedWorkspace] openFile:@"/Users/tsinha/Downloads/qwop.swf" withApplication:@"/Applications/Flash Player.app"];
}

- (void)runQWOP
{
    int iter = 0;
    while (iter < 5000) {
        for (id key in algos) {
            id algo = [algos objectForKey:key];
            [algo log];
            [self writeImages];
            [self iterateWithAlgo:algo];
            usleep(100000);
        }
        [self rankAlgos];
        [self breedAlgos];
        [self mutateAlgos];
        
        NSLog(@"iter: %d", iter);
        iter++;
    }

}

-(void)screenGrab 
{
//    NSLog(@"Trying to ScreenGrab");
    CGImageRef screenShot = CGWindowListCreateImage( CGRectInfinite,
                                                    kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
    
    CFStringRef file = CFSTR("/Users/tsinha/temp/baseImage.jpg");
    CFStringRef type = CFSTR("public.jpeg");
    CFURLRef urlRef = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, file, kCFURLPOSIXPathStyle, false);
    CGImageDestinationRef idst = CGImageDestinationCreateWithURL( urlRef, type, 1, NULL );
    CGImageDestinationAddImage( idst, screenShot, NULL );
    CGImageDestinationFinalize( idst );
    
    CFRelease(screenShot);
    CFRelease(idst);
    CFRelease(file);
    CFRelease(type);
    CFRelease(urlRef);
}

-(void)writeImages
{
    [self screenGrab];
    [self writeDistChunkToFile];
    [self writeSChunksToFile];
    NSString *format = [self getSLoc];
    [self writeDistChunksToFile:format];
    [self writeFinishChunkToFile];
}

-(void)writeDistChunkToFile
{
    NSImage *baseImage = [[NSImage alloc]initWithContentsOfFile:@"/Users/tsinha/temp/baseImage.jpg"];
	[self writeImageChunkToFile:baseImage :CGPointMake(IMG_BASE_X, IMG_BASE_Y) :CGPointMake(IMG_BASE_CROP_X, IMG_BASE_CROP_Y) :@"/Users/tsinha/temp/distImage.jpg"];
    [baseImage release];
    distImage = [[[NSImage alloc]initWithContentsOfFile:@"/Users/tsinha/temp/distImage.jpg"] autorelease];
}

-(void)writeDistChunksToFile:(NSString*)format
{
    if ([format isEqualToString:@"2d"]) {
        [self writeImageChunkToFile:distImage :CGPointMake(IMG_CHKS2d_X, IMG_CHKS2d_Y-4) :CGPointMake(36, IMG_CHKS2d_CROP_Y+5) :@"/Users/tsinha/temp/num1.jpg"];
        [self writeImageChunkToFile:distImage :CGPointMake(IMG_CHKS2d_X, IMG_CHKS2d_Y-4) :CGPointMake(62, IMG_CHKS2d_CROP_Y+5) :@"/Users/tsinha/temp/num2.jpg"];
    }
    if ([format isEqualToString:@"n2d"]) {
        [self writeImageChunkToFile:distImage :CGPointMake(IMG_CHKS2d_X, IMG_CHKS2d_Y-4) :CGPointMake(42, IMG_CHKS2d_CROP_Y+5) :@"/Users/tsinha/temp/num1.jpg"];
        [self writeImageChunkToFile:distImage :CGPointMake(IMG_CHKS2d_X, IMG_CHKS2d_Y-4) :CGPointMake(70, IMG_CHKS2d_CROP_Y+5) :@"/Users/tsinha/temp/num2.jpg"];
    }
    if ([format isEqualToString:@"1d"]) {
        [self writeImageChunkToFile:distImage :CGPointMake(IMG_CHKS2d_X, IMG_CHKS2d_Y-4) :CGPointMake(49, IMG_CHKS2d_CROP_Y+5) :@"/Users/tsinha/temp/num1.jpg"];
    }
    if ([format isEqualToString:@"n1d"]) {
        [self writeImageChunkToFile:distImage :CGPointMake(IMG_CHKS2d_X, IMG_CHKS2d_Y-4) :CGPointMake(56, IMG_CHKS2d_CROP_Y+5) :@"/Users/tsinha/temp/num1.jpg"];
    }
}

-(void)writeSChunksToFile
{
    [self writeImageChunkToFile:distImage :CGPointMake(IMG_CHKS2d_X, IMG_CHKS2d_Y) :CGPointMake(IMG_CHKS2d_CROP_X, IMG_CHKS2d_CROP_Y) :@"/Users/tsinha/temp/sImage0.jpg"];
    [self writeImageChunkToFile:distImage :CGPointMake(IMG_CHKS2d_X, IMG_CHKS2d_Y) :CGPointMake(IMG_CHKSn2d_CROP_X, IMG_CHKS2d_CROP_Y) :@"/Users/tsinha/temp/sImage1.jpg"];
    [self writeImageChunkToFile:distImage :CGPointMake(IMG_CHKS2d_X, IMG_CHKS2d_Y) :CGPointMake(IMG_CHKS1d_CROP_X, IMG_CHKS2d_CROP_Y) :@"/Users/tsinha/temp/sImage2.jpg"];
    [self writeImageChunkToFile:distImage :CGPointMake(IMG_CHKS2d_X, IMG_CHKS2d_Y) :CGPointMake(IMG_CHKSn1d_CROP_X, IMG_CHKS2d_CROP_Y) :@"/Users/tsinha/temp/sImage3.jpg"];

}

-(void)writeFinishChunkToFile
{
    NSImage *baseImage = [[NSImage alloc]initWithContentsOfFile:@"/Users/tsinha/temp/baseImage.jpg"];
	[self writeImageChunkToFile:baseImage :CGPointMake(IMG_FINISH_X, IMG_FINISH_Y) :CGPointMake(IMG_FINISH_CROP_X, IMG_FINISH_CROP_Y) :@"/Users/tsinha/temp/finishImage.jpg"];
    [baseImage release];
}


-(void)writeImageChunkToFile:(NSImage *)source :(CGPoint)imgSize :(CGPoint)cropSize :(NSString *)fileName 
{
    NSImage *target = [[NSImage alloc]initWithSize:NSMakeSize(imgSize.x, imgSize.y)];
    
    [target lockFocus];
    
    [source drawInRect:NSMakeRect(0,0,imgSize.x,imgSize.y) 
              fromRect:NSMakeRect(cropSize.x,cropSize.y,imgSize.x,imgSize.y) 
             operation:NSCompositeCopy
              fraction:1.0];
    
    [target unlockFocus];
    
    NSBitmapImageRep *bmpImageRep = [[NSBitmapImageRep alloc]initWithData:[target TIFFRepresentation]];
    [target addRepresentation:bmpImageRep];
    
	NSData *data = [bmpImageRep representationUsingType: NSPNGFileType
                                             properties: nil];
    
	[data writeToFile: fileName
           atomically: NO];
    [target release];
}

-(NSBitmapImageRep*)getImageRepFromFile:(NSString *)fileName
{
    NSImage *target = [[NSImage alloc]initWithContentsOfFile:fileName];
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc]initWithData:[target TIFFRepresentation]];
    [target release];
    return [imageRep autorelease];
}

-(void)iterateWithAlgo:(Algorithm *)algo
{
    NSDate *start = [NSDate date];
    while (![algo isComplete] && ![self checkGameOver]) {
//        NSLog(@"Executing step: %d for algorithm: %@. Next execution: %@.", [algo step], [algo algo], [algo nextOperation]);
        [self executeKeyPress:[algo nextOperation]];
        [self writeImages];
        if (![self checkSLoc]) {
            NSLog(@"Faulty SLOC");
            NSString* sLoc = [self getSLoc];
            NSLog(@"%@",sLoc);
            exit(0);
        }
        [algo setDistance:[self getDistance:[self getSLoc]]];
        [algo incrementAlgo];
//        NSLog(@"Algorithm: %@, Distance: %g", [algo algo], [algo distance]);
    }
    //NSLog([algo isComplete] ? @"T" : @"F");
    if ([algo distance]<0.5) {
        [algo setDistance:[algo distance]-20];
    }
    if ([self checkGameOver]) {
        [algo setDistance:[algo distance]-20];
    }
    NSTimeInterval timeInterval = -[start timeIntervalSinceNow];
    [algo setElapsedTime:timeInterval];
    [self resetGame];
    [algo resetAlgo];
}

-(void)executeKeyPress:(Move*)input
{
    NSString *keys = [input keys];
    useconds_t time = [input time];
    if ([keys isEqualToString:@"q"]) {
        CGEventPost(kCGHIDEventTap, qdown);
        usleep(time);
        CGEventPost(kCGHIDEventTap, qup);
    }
    if ([keys isEqualToString:@"w"]) {
        CGEventPost(kCGHIDEventTap, wdown);
        usleep(time);
        CGEventPost(kCGHIDEventTap, wup);
    }
    if ([keys isEqualToString:@"o"]) {
        CGEventPost(kCGHIDEventTap, odown);
        usleep(time);
        CGEventPost(kCGHIDEventTap, oup);
    }
    if ([keys isEqualToString:@"p"]) {
        CGEventPost(kCGHIDEventTap, pdown);
        usleep(time);
        CGEventPost(kCGHIDEventTap, pup);
    }
    usleep(150000);
}

-(NSString*) getSLoc
{
    for (int i=0 ; i<4; i++) {
        NSBitmapImageRep *imageRep = [self getImageRepFromFile:[NSString stringWithFormat:@"/Users/tsinha/temp/sImage%d.jpg",i]];
        if ([self isImgS:imageRep]) {
            return [self getFormatFromSLoc:i];
        }
    }
    return @"2d";
}

-(bool)checkSLoc
{
    for (int i=0 ; i<4; i++) {
        NSBitmapImageRep *imageRep = [self getImageRepFromFile:[NSString stringWithFormat:@"/Users/tsinha/temp/sImage%d.jpg",i]];
        if ([self isImgS:imageRep]) {
            return true;
        }
    }
    return false;
}

-(NSString*)getFormatFromSLoc:(int)loc
{
    switch (loc) {
        case 0:
            return @"2d";
            break;
        case 1:
            return @"n2d";
            break;
        case 2:
            return @"1d";
            break;
        case 3:
            return @"n1d";
            break;
        default:
            return @"2d";
            break;
    }
}

-(bool) checkGameOver
{
    NSBitmapImageRep *imageRep = [self getImageRepFromFile:@"/Users/tsinha/temp/finishImage.jpg"];
    return [self isImgFinish:imageRep];
}

-(void)resetGame
{
    CGEventPost(kCGHIDEventTap, rdown);
    CGEventPost(kCGHIDEventTap, rup);
}

-(double)getPValue:(NSBitmapImageRep *)imageRep:(NSBitmapImageRep *) compareRep
{
    int row;
    int column;
    int widthInPixels;
    int heightInPixels;
    double total =0;
    
    int bytesPerPixel = (int) [imageRep bitsPerPixel] / [imageRep bitsPerSample];
    
    // check if the source imageRep is valid
    
    widthInPixels = (int) [imageRep pixelsWide];
    heightInPixels = (int) [imageRep pixelsHigh];
    
    unsigned char *imgPixels = [imageRep bitmapData];
    unsigned char *compPixels = [compareRep bitmapData];
    for (row = 0; row < heightInPixels; row++){
        unsigned char *imgPixel = imgPixels + row*widthInPixels;
        unsigned char *compPixel = compPixels + row*widthInPixels;
        
        for (column = 0; column < widthInPixels; column++,
             imgPixel+= bytesPerPixel, compPixel+= bytesPerPixel){
            int rdiff = imgPixel[0] - compPixel[0];
            int gdiff = imgPixel[1] - compPixel[1];
            int bdiff = imgPixel[2] - compPixel[2];
            double diff = sqrt((rdiff*rdiff) + (gdiff*gdiff) + (bdiff*bdiff));
            total += diff;
        }
    }
    return total;
}

-(double)getDistance:(NSString *)format
{
    double dist = 0;
    if ([format isEqualToString:@"2d"]) {
        NSBitmapImageRep *imageRep = [self getImageRepFromFile:@"/Users/tsinha/temp/num1.jpg"];
        dist += [self getNumFromImgRep:imageRep];
        imageRep = [self getImageRepFromFile:@"/Users/tsinha/temp/num2.jpg"];
        dist += [self getNumFromImgRep:imageRep] /10.0;
    }
    if ([format isEqualToString:@"n2d"]) {
        NSBitmapImageRep *imageRep = [self getImageRepFromFile:@"/Users/tsinha/temp/num1.jpg"];
        dist += [self getNumFromImgRep:imageRep];
        imageRep = [self getImageRepFromFile:@"/Users/tsinha/temp/num2.jpg"];
        dist += [self getNumFromImgRep:imageRep] /10.0;
        dist = -dist;
    }
    if ([format isEqualToString:@"1d"]) {
        NSBitmapImageRep *imageRep = [self getImageRepFromFile:@"/Users/tsinha/temp/num1.jpg"];
        dist += [self getNumFromImgRep:imageRep];
    }
    if ([format isEqualToString:@"n1d"]) {
        NSBitmapImageRep *imageRep = [self getImageRepFromFile:@"/Users/tsinha/temp/num1.jpg"];
        dist -= [self getNumFromImgRep:imageRep];
    }
    return dist;
}

-(NSInteger)getNumFromImgRep:(NSBitmapImageRep *)imageRep
{
    double min = 65536;
    int ret = 0;
    for (int i=0; i<=9; i++) {
//        NSString *p = [NSString stringWithFormat:@"/Users/tsinha/temp/%d.jpg", i];
        NSBitmapImageRep *compareRep = [self getImageRepFromFile:[NSString stringWithFormat:@"/Users/tsinha/temp/%d.jpg", i]];
        double diff = [self getPValue:imageRep :compareRep];
        if (diff < min) {
            min = diff;
            ret = i;
        }
    }
    return ret;
}

-(bool)isImgS:(NSBitmapImageRep *)imageRep
{
    NSBitmapImageRep *compareRep = [self getImageRepFromFile:[NSString stringWithFormat:@"/Users/tsinha/temp/s.jpg"]];
    return [self getPValue:imageRep :compareRep] < 3000;
}

-(bool)isImgFinish:(NSBitmapImageRep *)imageRep
{
    NSBitmapImageRep *compareRep = [self getImageRepFromFile:[NSString stringWithFormat:@"/Users/tsinha/temp/finish.jpg"]];
    return [self getPValue:imageRep :compareRep] < 50;
}

-(void)initAlgos
{
    for (int i = 1; i <= 9 ; i++) {
        NSMutableArray *addAlgoArray = [[NSMutableArray alloc]init];
        for (int j = 0; j < 8; j++) {
            Move *addMove = [[Move alloc]init];
            [addAlgoArray addObject:addMove];
        }
        Algorithm *addAlgo = [[Algorithm alloc]initWithArray:addAlgoArray];
        [algos setObject:addAlgo forKey:[NSString stringWithFormat:@"%d",i]];
    }
}

-(void)rankAlgos
{
    NSArray *values = [algos allValues];
    NSArray *sortedValues = [values sortedArrayUsingSelector:@selector(compare:)];
    [algos removeAllObjects];
    for (int i = 0; i < [sortedValues count] && i < 3; i++) {
        [algos setObject:[sortedValues objectAtIndex:i] forKey:[NSString stringWithFormat:@"%d",i]];
    }
    
    for (id key in algos) {
        id algo = [algos valueForKey:key];
        NSLog(@"Key: %@ Distance: %g Elapsed Time: %g", key, [algo distance], [algo elapsedTime]);
    //    [algo log];
    }
    
}

-(void)breedAlgos
{
    NSArray *values = [algos allValues];
    [algos removeAllObjects];
    int iter = 0;
    
    for (id algo1 in values) {
        for (id algo2 in values) {
            iter++;
            [algos setObject:[algo1 breedWith:algo2] forKey:[NSString stringWithFormat:@"%d",iter]];
        }
    }
    for (id algo1 in values) {
        iter++;
        [algos setObject:algo1 forKey:[NSString stringWithFormat:@"%d",iter]];
    }
    /*
    for (id key in algos) {
        id algo = [algos valueForKey:key];
        NSLog(@"Key: %@", key);
        [algo log];
    } 
    */
}

-(void)mutateAlgos
{
    NSArray *values = [algos allValues];
    [algos removeAllObjects];
    int iter = 0;
    
    for (id algo1 in values) {
        iter++;
        algo1 = [algo1 mutateAlgo];
        [algos setObject:[algo1 mutateAlgo] forKey:[NSString stringWithFormat:@"%d",iter]];
    }
    /*
    for (id key in algos) {
        id algo = [algos valueForKey:key];
        NSLog(@"Key: %@", key);
        [algo log];
    }
    */
}

@end
