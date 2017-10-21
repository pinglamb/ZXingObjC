//
//  ZXBlotCodeBitMatrixParser.h
//  ZXingObjC
//
//  Created by Ping Lam on 21/10/2017.
//  Copyright © 2017 zxing. All rights reserved.
//

@class ZXBitMatrix, ZXBitArray;

@interface ZXBlotCodeBitMatrixParser : NSObject

- (id)initWithBitMatrix:(ZXBitMatrix *)bitMatrix error:(NSError **)error;
- (ZXBitArray *)readCodewords;

@end
