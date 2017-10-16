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
    NSLog(@"%@", info);
    if (!info) {
        return nil;
    }

    return [self processBullInfo:info error:error];
}

- (ZXDetectorResult *)processBullInfo:(ZXBlotCodeBullInfo *)info error:(NSError **)error {
    return [[ZXDetectorResult alloc] initWithBits:self.image points:@[]];
}

@end

