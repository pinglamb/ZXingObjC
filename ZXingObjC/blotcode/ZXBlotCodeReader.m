//
//  ZXBlotCodeReader.m
//  ZXingObjC
//
//  Created by Ping Lam on 16/10/2017.
//  Copyright © 2017 zxing. All rights reserved.
//

#import "ZXBinaryBitmap.h"
#import "ZXBitMatrix.h"
#import "ZXDecodeHints.h"
#import "ZXDecoderResult.h"
#import "ZXDetectorResult.h"
#import "ZXErrors.h"
#import "ZXIntArray.h"
#import "ZXBlotCodeDecoder.h"
#import "ZXBlotCodeDetector.h"
#import "ZXBlotCodeReader.h"
#import "ZXResult.h"
#import "ZXByteArray.h"

@interface ZXBlotCodeReader ()

@property (nonatomic, strong, readonly) ZXBlotCodeDecoder *decoder;

@end

@implementation ZXBlotCodeReader

- (id)init {
    if (self = [super init]) {
        _decoder = [[ZXBlotCodeDecoder alloc] init];
    }

    return self;
}

- (ZXResult *)decode:(ZXBinaryBitmap *)image error:(NSError **)error {
    return [self decode:image hints:nil error:error];
}

- (ZXResult *)decode:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints error:(NSError **)error {
    ZXBitMatrix *matrix = [image blackMatrixWithError:error];
    if (!matrix) {
        return nil;
    }

    ZXDetectorResult *detectorResult = [[[ZXBlotCodeDetector alloc] initWithImage:matrix] detect:hints error:error];
    if (!detectorResult) {
        return nil;
    }

    NSLog(@"Decoding ...........");
    [self.decoder decode:detectorResult.bits hints:hints error:error];

    return nil;
}

- (void)reset {
    // do nothing
}

@end
