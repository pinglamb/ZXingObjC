//
//  ZXBlotCodeBullInfo.h
//  ZXingObjC
//
//  Created by Ping Lam on 16/10/2017.
//  Copyright © 2017 zxing. All rights reserved.
//

@class ZXBlotCodeBull;

@interface ZXBlotCodeBullInfo : NSObject

@property (nonatomic, strong, readonly) ZXBlotCodeBull *bull;

- (id)initWithBull:(ZXBlotCodeBull *)bull;

@end
