//
//  ZXBlotCodeBullFinder.h
//  ZXingObjC
//
//  Created by Ping Lam on 16/10/2017.
//  Copyright © 2017 zxing. All rights reserved.
//

@protocol ZXResultPointCallback;
@class ZXBitMatrix, ZXDecodeHints, ZXBlotCodeBullInfo;

@interface ZXBlotCodeBullFinder : NSObject

@property (nonatomic, strong, readonly) ZXBitMatrix *image;
@property (nonatomic, strong, readonly) NSMutableArray *possibleBulls;

- (id)initWithImage:(ZXBitMatrix *)image;

- (id)initWithImage:(ZXBitMatrix *)image resultPointCallback:(id<ZXResultPointCallback>)resultPointCallback;

- (ZXBlotCodeBullInfo *)find:(ZXDecodeHints *)hints error:(NSError **)error;

+ (BOOL)foundBull:(const int[])stateCount;

@end
