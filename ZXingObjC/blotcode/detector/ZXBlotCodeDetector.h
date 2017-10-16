//
//  ZXBlotCodeDetector.h
//  ZXingObjC
//
//  Created by Ping Lam on 16/10/2017.
//  Copyright © 2017 zxing. All rights reserved.
//

@class ZXBitMatrix, ZXDecodeHints, ZXDetectorResult, ZXPerspectiveTransform, ZXResultPoint;
@protocol ZXResultPointCallback;

@interface ZXBlotCodeDetector : NSObject

@property (nonatomic, strong, readonly) ZXBitMatrix *image;
@property (nonatomic, weak, readonly) id <ZXResultPointCallback> resultPointCallback;

- (id)initWithImage:(ZXBitMatrix *)image;

- (ZXDetectorResult *)detectWithError:(NSError **)error;

- (ZXDetectorResult *)detect:(ZXDecodeHints *)hints error:(NSError **)error;

@end
