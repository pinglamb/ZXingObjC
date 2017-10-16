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
#import "ZXErrors.h"
#import "ZXIntArray.h"
#import "ZXBlotCodeDecoder.h"
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
    if (hints == nil) {
        ZXByteArray *datawords = [[ZXByteArray alloc] initWithLength:94];
        ZXResult *result = [ZXResult resultWithText:@"Hello"
                                           rawBytes:datawords
                                       resultPoints:@[]
                                             format:kBarcodeFormatBlotCode];
        return result;
    } else {
        return nil;
    }
}

- (void)reset {
    // do nothing
}

@end