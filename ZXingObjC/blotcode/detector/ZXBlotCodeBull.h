//
//  ZXBlotCodeBull.h
//  ZXingObjC
//
//  Created by Ping Lam on 16/10/2017.
//  Copyright © 2017 zxing. All rights reserved.
//

#import "ZXResultPoint.h"

@interface ZXBlotCodeBull : ZXResultPoint

@property (nonatomic, assign, readonly) float estimatedModuleSize;

- (id)initWithPosX:(float)posX posY:(float)posY estimatedModuleSize:(float)estimatedModuleSize;

@end
