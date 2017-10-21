//
//  ZXBlotCodeBitMatrixParser.m
//  ZXingObjC
//
//  Created by Ping Lam on 21/10/2017.
//  Copyright © 2017 zxing. All rights reserved.
//

#import "ZXBitMatrix.h"
#import "ZXBitArray.h"
#import "ZXErrors.h"
#import "ZXBlotCodeBitMatrixParser.h"

const int ZX_BLOTBITS[9][9] = {
    { -1, -1,  0,  1,  2,  3,  4, -1, -1},
      { -1,  5,  6,  7,  8,  9, 10, -1, -1},
    { -1, 11, 12, -1, 13, -1, 14, 15, -1},
      { 16, 17, 18, -1, -1, 19, 20, 21, -1},
    { 22, 23, -1, -1, -1, -1, -1, 24, 25},
      { 26, 27, 28, -1, -1, 29, 30, 31, -1},
    { -1, 32, 33, -1, 34, -1, 35, 36, -1},
      { -1, 37, 38, 39, 40, 41, 42, -1, -1},
    { -1, -1, 43, 44, 45, 46, 47, -1, -1}
};

@interface ZXBlotCodeBitMatrixParser ()

@property (nonatomic, strong, readonly) ZXBitMatrix *bitMatrix;

@end

@implementation ZXBlotCodeBitMatrixParser

- (id)initWithBitMatrix:(ZXBitMatrix *)bitMatrix error:(NSError *__autoreleasing *)error {
    if (self = [super init]) {
        _bitMatrix = bitMatrix;
    }

    return self;
}

- (ZXBitArray *)readCodewords {
    ZXBitArray *result = [[ZXBitArray alloc] initWithSize:48];
    int height = self.bitMatrix.height;
    int width = self.bitMatrix.width;
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            int index = ZX_BLOTBITS[y][x];
            if (index >= 0) {
                if (![self.bitMatrix getX:x y:y]) {
                    [result set:index];
                }
            }
        }
    }
    return result;
}

@end
