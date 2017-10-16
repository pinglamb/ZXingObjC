//
//  ZXBlotCodeBull.m
//  ZXingObjC
//
//  Created by Ping Lam on 16/10/2017.
//  Copyright © 2017 zxing. All rights reserved.
//

#import "ZXBlotCodeBull.h"

@implementation ZXBlotCodeBull

- (id)initWithPosX:(float)posX posY:(float)posY estimatedModuleSize:(float)estimatedModuleSize {
    if (self = [super initWithX:posX y:posY]) {
        _estimatedModuleSize = estimatedModuleSize;
    }

    return self;
}

@end
