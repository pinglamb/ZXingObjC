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

const int ZX_BLOT_CODE_BULL_MODULES = 10;
const int ZX_BLOT_CODE_MAX_MODULES = 34;

@interface ZXBlotCodeBullFinder ()

@property (nonatomic, weak, readonly) id<ZXResultPointCallback> resultPointCallback;

@end

@implementation ZXBlotCodeBullFinder

- (id)initWithImage:(ZXBitMatrix *)image {
    return [self initWithImage:image resultPointCallback:nil];
}

- (id)initWithImage:(ZXBitMatrix *)image resultPointCallback:(id<ZXResultPointCallback>)resultPointCallback {
    if (self = [super init]) {
        _image = image;
        _resultPointCallback = resultPointCallback;
    }

    return self;
}

- (ZXBlotCodeBullInfo *)find:(ZXDecodeHints *)hints error:(NSError **)error {
    int maxX = self.image.width;
    int maxY = self.image.height;

    // Assume code takes up 1/4 of the image width
    int minPixelsPerModule = maxX / 4 / ZX_BLOT_CODE_MAX_MODULES;
    int xSkip = minPixelsPerModule;
    if (xSkip < 3) {
        xSkip = 3;
    }

    BOOL done = NO;
    int stateCount[5] = {0, 0, 0, 0, 0};
    for (int x = xSkip - 1; x < maxX && !done; x += xSkip) {
        stateCount[0] = 0;
        stateCount[1] = 0;
        stateCount[2] = 0;
        stateCount[3] = 0;
        stateCount[4] = 0;
        int currentState = 0;

        for (int y = 0; y < maxY; y++) {
            if ([self.image getX:x y:y]) {
                // It is a black pixel
                if ((currentState & 1) == 1) {
                    // currentState is counting white pixel, +1
                    currentState++;
                }
                stateCount[currentState]++;
            } else {
                // It is a white pixel
                if ((currentState & 1) == 0) {
                    // currentState is counting black pixel
                    if (currentState == 4) {
                        if ([self isBullCross:stateCount]) {
                            BOOL confirmed = [self handlePossibleBull:stateCount x:x y:y];
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

        if ([self isBullCross:stateCount]) {
            BOOL confirmed = [self handlePossibleBull:stateCount x:x y:maxY];
            if (confirmed) {
                done = YES;
            }
        }
    }

    if (!self.bull) {
        if (error) *error = ZXNotFoundErrorInstance();
        return nil;
    }

    return [[ZXBlotCodeBullInfo alloc] initWithBull:self.bull];
}

- (BOOL)isBullCross:(const int[])stateCount {
    int totalModuleSize = 0;
    for (int i = 0; i < 5; i++) {
        int count = stateCount[i];
        if (count == 0) {
            return NO;
        }
        totalModuleSize += count;
    }
    if (totalModuleSize < ZX_BLOT_CODE_BULL_MODULES) {
        return NO;
    }
    float moduleSize = totalModuleSize / (float)ZX_BLOT_CODE_BULL_MODULES;
    float maxVariance = moduleSize / 2.0f;
    // Allow less than 50% variance from 1-2-4-2-1 proportions
    return
    ABS(moduleSize - stateCount[0]) < maxVariance &&
    ABS(2.0f * moduleSize - stateCount[1]) < 2 * maxVariance &&
    ABS(4.0f * moduleSize - stateCount[2]) < 4 * maxVariance &&
    ABS(2.0f * moduleSize - stateCount[3]) < 2 * maxVariance &&
    ABS(moduleSize - stateCount[4]) < maxVariance;
}

- (BOOL)handlePossibleBull:(const int[])stateCount x:(int)x y:(int)y {
    int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2] + stateCount[3] + stateCount[4];
    float centerX = x;
    float centerY = (float)(y - stateCount[4] - stateCount[3]) - stateCount[2] / 2.0f;

    ZXResultPoint *center1 = [[ZXResultPoint alloc] initWithX:centerX y:centerY];
    ZXResultPoint *center2 = [self crossCheckFromLeft:center1 maxCount:stateCount[2] originalStateCountTotal:stateCountTotal];
    if (center2 == nil) {
        return NO;
    }

    ZXResultPoint *center3 = [self crossCheckFromRight:center2 maxCount:stateCount[2] originalStateCountTotal:stateCountTotal];
    if (center3 == nil) {
        return NO;
    }

    self.bull = [self crossCheckVertical:center3 maxCount:stateCount[2] originalStateCountTotal:stateCountTotal];
    return self.bull != nil;
}

- (ZXResultPoint *)crossCheckFromLeft:(ZXResultPoint *)center maxCount:(int)maxCount originalStateCountTotal:(int)originalStateCountTotal {
    int maxX = self.image.width;
    int maxY = self.image.height;
    int stateCount[5] = {0, 0, 0, 0, 0};
    float startX, startY, endX, endY;

    int i = 0;
    while (center.x >= 2 * i && center.y >= i && [self.image getX:(center.x - 2 * i) y:(center.y - i)]) {
        stateCount[2]++;
        i++;
    }
    if (center.x < 2 * i || center.y < i) {
        return nil;
    }

    while (center.x >= 2 * i && center.y >= i && ![self.image getX:(center.x - 2 * i) y:(center.y - i)] && stateCount[1] <= maxCount) {
        stateCount[1]++;
        i++;
    }
    if (center.x < 2 * i || center.y < i || stateCount[1] > maxCount) {
        return nil;
    }

    while (center.x >= 2 * i && center.y >= i && [self.image getX:(center.x - 2 * i) y:(center.y - i)] && stateCount[0] <= maxCount) {
        stateCount[0]++;
        i++;
        startX = center.x - 2 * i;
        startY = center.y - i;
    }
    if (stateCount[0] > maxCount) {
        return nil;
    }

    i = 1;
    while (center.x + 2 * i < maxX && center.y + i < maxY && [self.image getX:(center.x + 2 * i) y:(center.y + i)]) {
        stateCount[2]++;
        i++;
    }
    if (center.x + 2 * i >= maxX || center.y + i >= maxY) {
        return nil;
    }

    while (center.x + 2 * i < maxX && center.y + i < maxY && ![self.image getX:(center.x + 2 * i) y:(center.y + i)] && stateCount[3] < maxCount) {
        stateCount[3]++;
        i++;
    }
    if (center.x + 2 * i >= maxX || center.y + i >= maxY || stateCount[3] >= maxCount) {
        return nil;
    }

    while (center.x + 2 * i < maxX && center.y + i < maxY && [self.image getX:(center.x + 2 * i) y:(center.y + i)] && stateCount[4] < maxCount) {
        stateCount[4]++;
        i++;
        endX = center.x + 2 * i;
        endY = center.y + i;
    }
    if (stateCount[4] >= maxCount) {
        return nil;
    }

    int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2] + stateCount[3] + stateCount[4];
    if (5 * abs(stateCountTotal - originalStateCountTotal / 2) >= originalStateCountTotal / 2) {
        return nil;
    }

    if ([self isBullCross:stateCount]) {
        return [[ZXResultPoint alloc] initWithX:(startX + (endX - startX) / 2.0f) y:(startY + (endY - startY) / 2.0f)];
    } else {
        return nil;
    }
}

- (ZXResultPoint *)crossCheckFromRight:(ZXResultPoint *)center maxCount:(int)maxCount originalStateCountTotal:(int)originalStateCountTotal {
    int maxX = self.image.width;
    int maxY = self.image.height;
    int stateCount[5] = {0, 0, 0, 0, 0};
    float startX, startY, endX, endY;

    int i = 0;
    while (center.x + 2 * i < maxX && center.y >= i && [self.image getX:(center.x + 2 * i) y:(center.y - i)]) {
        stateCount[2]++;
        i++;
    }
    if (center.x + 2 * i >= maxX || center.y < i) {
        return nil;
    }

    while (center.x + 2 * i < maxX && center.y >= i && ![self.image getX:(center.x + 2 * i) y:(center.y - i)] && stateCount[3] <= maxCount) {
        stateCount[3]++;
        i++;
    }
    if (center.x + 2 * i >= maxX || center.y < i || stateCount[3] > maxCount) {
        return nil;
    }

    while (center.x + 2 * i < maxX && center.y >= i && [self.image getX:(center.x + 2 * i) y:(center.y - i)] && stateCount[4] <= maxCount) {
        stateCount[4]++;
        i++;
        endX = center.x + 2 * i;
        endY = center.y - i;
    }
    if (stateCount[4] > maxCount) {
        return nil;
    }

    i = 1;
    while (center.x >= 2 * i && center.y + i < maxY && [self.image getX:(center.x - 2 * i) y:(center.y + i)]) {
        stateCount[2]++;
        i++;
    }
    if (center.x < 2 * i || center.y + i >= maxY) {
        return nil;
    }

    while (center.x >= 2 * i && center.y + i < maxY && ![self.image getX:(center.x - 2 * i) y:(center.y + i)] && stateCount[1] < maxCount) {
        stateCount[1]++;
        i++;
    }
    if (center.x < 2 * i || center.y + i >= maxY || stateCount[1] >= maxCount) {
        return nil;
    }

    while (center.x >= 2 * i && center.y + i < maxY && [self.image getX:(center.x - 2 * i) y:(center.y + i)] && stateCount[0] < maxCount) {
        stateCount[0]++;
        i++;
        startX = center.x - 2 * i;
        startY = center.y + i;
    }
    if (stateCount[0] >= maxCount) {
        return nil;
    }

    int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2] + stateCount[3] + stateCount[4];
    if (5 * abs(stateCountTotal - originalStateCountTotal / 2) >= originalStateCountTotal / 2) {
        return nil;
    }

    if ([self isBullCross:stateCount]) {
        return [[ZXResultPoint alloc] initWithX:(startX + (endX - startX) / 2.0f) y:(endY + (startY - endY) / 2.0f)];
    } else {
        return nil;
    }
}

- (ZXBlotCodeBull *)crossCheckVertical:(ZXResultPoint *)center maxCount:(int)maxCount originalStateCountTotal:(int)originalStateCountTotal {
    int maxY = self.image.height;
    int stateCount[5] = {0, 0, 0, 0, 0};

    int x = center.x;
    int y = center.y;
    while (y >= 0 && [self.image getX:x y:y]) {
        stateCount[2]++;
        y--;
    }
    if (y < 0) {
        return nil;
    }
    while (y >= 0 && ![self.image getX:x y:y] && stateCount[1] <= maxCount) {
        stateCount[1]++;
        y--;
    }
    if (y < 0 || stateCount[1] > maxCount) {
        return nil;
    }
    while (y >= 0 && [self.image getX:x y:y] && stateCount[0] <= maxCount) {
        stateCount[0]++;
        y--;
    }
    if (stateCount[0] > maxCount) {
        return nil;
    }
    y = center.y + 1;
    while (y < maxY && [self.image getX:x y:y]) {
        stateCount[2]++;
        y++;
    }
    if (y == maxY) {
        return nil;
    }
    while (y < maxY && ![self.image getX:x y:y] && stateCount[3] < maxCount) {
        stateCount[3]++;
        y++;
    }
    if (y == maxY || stateCount[3] >= maxCount) {
        return nil;
    }
    while (y < maxY && [self.image getX:x y:y] && stateCount[4] < maxCount) {
        stateCount[4]++;
        y++;
    }
    if (stateCount[4] >= maxCount) {
        return nil;
    }

    int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2] + stateCount[3] + stateCount[4];
    if (5 * abs(stateCountTotal - originalStateCountTotal) >= originalStateCountTotal) {
        return nil;
    }

    if ([self isBullCross:stateCount]) {
        float centerX = center.x;
        float centerY = (float)(y - stateCount[4] - stateCount[3]) - stateCount[2] / 2.0f;
        float estimatedModuleSize = stateCountTotal * 1.0f / ZX_BLOT_CODE_BULL_MODULES;
        return [[ZXBlotCodeBull alloc] initWithPosX:centerX posY:centerY estimatedModuleSize:estimatedModuleSize];
    } else {
        return nil;
    }
}

@end
