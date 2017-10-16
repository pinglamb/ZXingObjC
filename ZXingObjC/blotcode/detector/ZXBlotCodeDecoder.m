//
//  ZXBlotCodeDecoder.m
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
    return nil;
}

@end
