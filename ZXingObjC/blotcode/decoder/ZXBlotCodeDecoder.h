//
//  ZXBlotCodeDecoder.h
//  ZXingObjC
//
//  Created by Ping Lam on 16/10/2017.
//  Copyright © 2017 zxing. All rights reserved.
//

@class ZXBitMatrix, ZXDecodeHints, ZXDecoderResult;

@interface ZXBlotCodeDecoder : NSObject

- (ZXDecoderResult *)decode:(ZXBitMatrix *)bits error:(NSError **)error;
- (ZXDecoderResult *)decode:(ZXBitMatrix *)bits hints:(ZXDecodeHints *)hints error:(NSError **)error;

@end
