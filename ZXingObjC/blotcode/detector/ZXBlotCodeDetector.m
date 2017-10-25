//
//  ZXBlotCodeDetector.m
//  ZXingObjC
//
//  Created by Ping Lam on 16/10/2017.
//  Copyright © 2017 zxing. All rights reserved.
//

#import "ZXBitMatrix.h"
#import "ZXDecodeHints.h"
#import "ZXDetectorResult.h"
#import "ZXErrors.h"
#import "ZXGridSampler.h"
#import "ZXIntArray.h"
#import "ZXMathUtils.h"
#import "ZXPerspectiveTransform.h"
#import "ZXResultPoint.h"
#import "ZXResultPointCallback.h"

#import "ZXBlotCodeDetector.h"
#import "ZXBlotCodeBull.h"
#import "ZXBlotCodeBullFinder.h"
#import "ZXBlotCodeBullInfo.h"

const float ZX_BLOT_CODE_MODULE_OVERLAP = 0.134f;

@interface ZXBlotCodeDetector ()

@property (nonatomic, weak) id<ZXResultPointCallback> resultPointCallback;

@end

@implementation ZXBlotCodeDetector

- (id)initWithImage:(ZXBitMatrix *)image {
    if (self = [super init]) {
        _image = image;
    }

    return self;
}

- (ZXDetectorResult *)detectWithError:(NSError **)error {
    return [self detect:nil error:error];
}

- (ZXDetectorResult *)detect:(ZXDecodeHints *)hints error:(NSError **)error {
    self.resultPointCallback = hints == nil ? nil : hints.resultPointCallback;

    ZXBlotCodeBullFinder *finder = [[ZXBlotCodeBullFinder alloc] initWithImage:self.image resultPointCallback:self.resultPointCallback];
    ZXBlotCodeBullInfo *info = [finder find:hints error:error];
    if (!info) {
        return nil;
    }

    ZXBlotCodeBull *bull = info.bull;
    float moduleSize = bull.estimatedModuleSize;
    NSLog(@"Module Size: %f", moduleSize);
    if (moduleSize < 1.0f) {
        NSLog(@"Per module pixel too small (%f)", moduleSize);
        return nil;
    }

    // Check if the whole blotcode is visible
    float width = moduleSize * 36;
    float height = moduleSize * 36 - ZX_BLOT_CODE_MODULE_OVERLAP * moduleSize * 4 * 8;
    float left = bull.x - width / 2;
    float top = bull.y - height / 2;
    if (left < 0 ||
        top < 0 ||
        (left + width) >= self.image.width ||
        (top + height) >= self.image.height) {
        NSLog(@"Failed to see the whole blotcode");
        return nil;
    }

    ZXResultPoint *topLeft = [[ZXResultPoint alloc] initWithX:left y:top];

    // Check if the orientation bits match [0 0 1 1 0 1]
    /*
    NSLog(@"[%d %d %d %d %d %d]",
          [self extractBit:topLeft x:3 y:2 moduleSize:moduleSize] ? 1 : 0,
          [self extractBit:topLeft x:5 y:2 moduleSize:moduleSize] ? 1 : 0,
          [self extractBit:topLeft x:2 y:4 moduleSize:moduleSize] ? 1 : 0,
          [self extractBit:topLeft x:6 y:4 moduleSize:moduleSize] ? 1 : 0,
          [self extractBit:topLeft x:3 y:6 moduleSize:moduleSize] ? 1 : 0,
          [self extractBit:topLeft x:5 y:6 moduleSize:moduleSize] ? 1 : 0);
    */
    if (!(![self extractBit:topLeft x:3 y:2 moduleSize:moduleSize] &&
          ![self extractBit:topLeft x:5 y:2 moduleSize:moduleSize] &&
           [self extractBit:topLeft x:2 y:4 moduleSize:moduleSize] &&
           [self extractBit:topLeft x:6 y:4 moduleSize:moduleSize] &&
          ![self extractBit:topLeft x:3 y:6 moduleSize:moduleSize] &&
           [self extractBit:topLeft x:5 y:6 moduleSize:moduleSize])) {
        NSLog(@"Failed to check orientation bits");
        return nil;

        /*
        ZXBitMatrix *bits = [[ZXBitMatrix alloc] initWithWidth:9 height:9];
        return [[ZXDetectorResult alloc] initWithBits:bits points:@[
            bull,
            [self toPoint:topLeft x:3 y:2 moduleSize:moduleSize],
            [self toPoint:topLeft x:5 y:2 moduleSize:moduleSize],
            [self toPoint:topLeft x:2 y:4 moduleSize:moduleSize],
            [self toPoint:topLeft x:6 y:4 moduleSize:moduleSize],
            [self toPoint:topLeft x:3 y:6 moduleSize:moduleSize],
            [self toPoint:topLeft x:5 y:6 moduleSize:moduleSize]
        ]];
        */
    }

    ZXBitMatrix *bits = [[ZXBitMatrix alloc] initWithWidth:9 height:9];
    for (int x = 0; x < 9; x++) {
        for (int y = 0; y < 9; y++) {
            if ([self extractBit:topLeft x:x y:y moduleSize:moduleSize]) {
                [bits setX:x y:y];
            }
        }
    }

    return [[ZXDetectorResult alloc] initWithBits:bits points:@[
        bull,
        [self toPoint:topLeft x:3 y:2 moduleSize:moduleSize],
        [self toPoint:topLeft x:5 y:2 moduleSize:moduleSize],
        [self toPoint:topLeft x:2 y:4 moduleSize:moduleSize],
        [self toPoint:topLeft x:6 y:4 moduleSize:moduleSize],
        [self toPoint:topLeft x:3 y:6 moduleSize:moduleSize],
        [self toPoint:topLeft x:5 y:6 moduleSize:moduleSize]
    ]];
}

- (ZXResultPoint *)toPoint:(ZXResultPoint *)origin x:(int)mx y:(int)my moduleSize:(float)moduleSize {
    int x = origin.x + moduleSize * 2 + mx * moduleSize * 4 + moduleSize * 2 * (my & 0x01);
    int y = origin.y + moduleSize * 2 + my * moduleSize * 4 - my * moduleSize * 4 * ZX_BLOT_CODE_MODULE_OVERLAP;
    return [[ZXResultPoint alloc] initWithX:x y:y];
}

- (BOOL)extractBit:(ZXResultPoint *)origin x:(int)mx y:(int)my moduleSize:(float)moduleSize {
    int x = origin.x + moduleSize * 2 + mx * moduleSize * 4 + moduleSize * 2 * (my & 0x01);
    int y = origin.y + moduleSize * 2 + my * moduleSize * 4 - my * moduleSize * 4 * ZX_BLOT_CODE_MODULE_OVERLAP;
    return [self.image getX:x y:y];
}

@end

