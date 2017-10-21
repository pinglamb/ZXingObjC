//
//  ZXBlotCodeDecoder.m
//  ZXingObjC
//
//  Created by Ping Lam on 16/10/2017.
//  Copyright © 2017 zxing. All rights reserved.
//

#import "ZXBitMatrix.h"
#import "ZXBitArray.h"
#import "ZXByteArray.h"
#import "ZXDecodeHints.h"
#import "ZXDecoderResult.h"
#import "ZXErrors.h"
#import "ZXGenericGF.h"
#import "ZXIntArray.h"
#import "ZXBlotCodeBitMatrixParser.h"
#import "ZXBlotCodeDecoder.h"
#import "ZXReedSolomonDecoder.h"

@interface ZXBlotCodeDecoder ()

@property (nonatomic, strong, readonly) ZXReedSolomonDecoder *rsDecoder;

@end

@implementation ZXBlotCodeDecoder

- (id)init {
    if (self = [super init]) {
        _rsDecoder = [[ZXReedSolomonDecoder alloc] initWithField:[ZXGenericGF MaxiCodeField64]];
    }

    return self;
}

- (ZXDecoderResult *)decode:(ZXBitMatrix *)bits error:(NSError **)error {
    return [self decode:bits hints:nil error:error];
}

- (ZXDecoderResult *)decode:(ZXBitMatrix *)bits hints:(ZXDecodeHints *)hints error:(NSError **)error {
    ZXBlotCodeBitMatrixParser *parser = [[ZXBlotCodeBitMatrixParser alloc] initWithBitMatrix:bits error:error];
    if (!parser) {
        return nil;
    }

    ZXBitArray *codewords = [parser readCodewords];
    ZXByteArray *bytes = [[ZXByteArray alloc] initWithLength:4];
    [codewords toBytes:0 array:bytes offset:0 numBytes:4];
    uint32_t intV = 0;
    for (int i = 0; i < 32; i++) {
        if ([codewords get:i]) {
            intV |= (1 << i);
        }
    }

    NSString *text = [NSString stringWithFormat:@"0x%02x", intV];

    return [[ZXDecoderResult alloc] initWithRawBytes:bytes
                                                text:text
                                        byteSegments:nil
                                             ecLevel:@""];
}

@end
