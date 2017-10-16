//
//  ZXBlotCodeBullFinder.m
//  ZXingObjC
//
//  Created by Ping Lam on 16/10/2017.
//  Copyright © 2017 zxing. All rights reserved.
//

#import "ZXBitMatrix.h"
#import "ZXDecodeHints.h"
#import "ZXErrors.h"
#import "ZXBlotCodeBull.h"
#import "ZXBlotCodeBullInfo.h"
#import "ZXBlotCodeBullFinder.h"
#import "ZXResultPoint.h"
#import "ZXResultPointCallback.h"

@interface ZXBlotCodeBullFinder ()

@property (nonatomic, weak, readonly) id<ZXResultPointCallback> resultPointCallback;
@property (nonatomic, strong) NSMutableArray *possibleBulls;

@end

@implementation ZXBlotCodeBullFinder

- (id)initWithImage:(ZXBitMatrix *)image {
    return [self initWithImage:image resultPointCallback:nil];
}

- (id)initWithImage:(ZXBitMatrix *)image resultPointCallback:(id<ZXResultPointCallback>)resultPointCallback {
    if (self = [super init]) {
        _image = image;
        _possibleBulls = [NSMutableArray array];
        _resultPointCallback = resultPointCallback;
    }

    return self;
}

- (ZXBlotCodeBullInfo *)find:(ZXDecodeHints *)hints error:(NSError **)error {
    int maxI = self.image.height;
    int maxJ = self.image.width;

    int jSkip = 3;

    BOOL done = NO;
    int stateCount[5];
    for (int j = jSkip - 1; j < maxJ && !done; j += jSkip) {
        stateCount[0] = 0;
        stateCount[1] = 0;
        stateCount[2] = 0;
        stateCount[3] = 0;
        stateCount[4] = 0;
        int currentState = 0;

        for (int i = 0; i < maxI; i++) {
            if ([self.image getX:j y:i]) {
                if ((currentState & 1) == 1) {
                    currentState++;
                }
                stateCount[currentState]++;
            } else {
                if ((currentState & 1) == 0) {
                    if (currentState == 4) {
                        NSLog(@"State Count: [%d, %d, %d, %d, %d]", stateCount[0], stateCount[1], stateCount[2], stateCount[3], stateCount[4]);
                        if (stateCount[0] > 20 && [ZXBlotCodeBullFinder foundBull:stateCount]) {
                            NSLog(@"Found Bull");
                            [self handlePossibleBull:stateCount i:i j:j];
                            BOOL confirmed = YES;
                            if (confirmed) {
                                done = YES;
                            } else {
                                stateCount[0] = stateCount[2];
                                stateCount[1] = stateCount[3];
                                stateCount[2] = stateCount[4];
                                stateCount[3] = 1;
                                stateCount[4] = 0;
                                currentState = 3;
                                continue;
                            }
                            currentState = 0;
                            stateCount[0] = 0;
                            stateCount[1] = 0;
                            stateCount[2] = 0;
                            stateCount[3] = 0;
                            stateCount[4] = 0;
                        } else {
                            stateCount[0] = stateCount[2];
                            stateCount[1] = stateCount[3];
                            stateCount[2] = stateCount[4];
                            stateCount[3] = 1;
                            stateCount[4] = 0;
                            currentState = 3;
                        }
                    } else {
                        stateCount[++currentState]++;
                    }
                } else {
                    stateCount[currentState]++;
                }
            }
        }

        if ([ZXBlotCodeBullFinder foundBull:stateCount]) {
            // BOOL confirmed = YES;
            [self handlePossibleBull:stateCount i:maxI j:j];
            done = YES;
        }
    }

    ZXBlotCodeBull *bull = [self selectBull];
    if (!bull) {
        if (error) *error = ZXNotFoundErrorInstance();
        return nil;
    }

    return [[ZXBlotCodeBullInfo alloc] initWithBull:bull];
}

- (float)centerFromEnd:(const int[])stateCount end:(int)end {
    return (float)(end - stateCount[4] - stateCount[3]) - stateCount[2] / 2.0f;
}

+ (BOOL)foundBull:(const int[])stateCount {
    int totalModuleSize = 0;
    for (int i = 0; i < 5; i++) {
        int count = stateCount[i];
        if (count == 0) {
            return NO;
        }
        totalModuleSize += count;
    }
    if (totalModuleSize < 10) {
        return NO;
    }
    float moduleSize = totalModuleSize / 10.0f;
    float maxVariance = moduleSize / 4.0f;
    // Allow less than 50% variance from 1-2-4-2-1 proportions
    return
    ABS(moduleSize - stateCount[0]) < maxVariance &&
    ABS(2.0f * moduleSize - stateCount[1]) < 2 * maxVariance &&
    ABS(4.0f * moduleSize - stateCount[2]) < 4 * maxVariance &&
    ABS(2.0f * moduleSize - stateCount[3]) < 2 * maxVariance &&
    ABS(moduleSize - stateCount[4]) < maxVariance;
}

- (BOOL)handlePossibleBull:(const int[])stateCount i:(int)i j:(int)j {
    int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2] + stateCount[3] + stateCount[4];
    float centerJ = [self centerFromEnd:stateCount end:j];
    float centerI = i;
    float estimatedModuleSize = (float)stateCountTotal / 10.0f;

    ZXResultPoint *point = [[ZXBlotCodeBull alloc] initWithPosX:centerJ posY:centerI estimatedModuleSize:estimatedModuleSize];
    [self.possibleBulls addObject:point];
    if (self.resultPointCallback != nil) {
        [self.resultPointCallback foundPossibleResultPoint:point];
    }
    return YES;
}

- (ZXBlotCodeBull *)selectBull {
    return [self.possibleBulls firstObject];
}
@end
