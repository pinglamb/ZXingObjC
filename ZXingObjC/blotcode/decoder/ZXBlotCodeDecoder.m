//
//  ZXBlotCodeDecoder.m
//  ZXingObjC
//
//  Created by Ping Lam on 16/10/2017.
//  Copyright © 2017 zxing. All rights reserved.
//

#import "ZXBitMatrix.h"
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

    NSLog(@"Parsing ...............");
    ZXBitArray *codewords = [parser readCodewords];
    NSLog(@"%@", codewords);

    return nil;
}

@end
