//
//  ZXBlotCodeBullInfo.m
//  ZXingObjC
//
//  Created by Ping Lam on 16/10/2017.
//  Copyright © 2017 zxing. All rights reserved.
//

#import "ZXBlotCodeBull.h"
#import "ZXBlotCodeBullInfo.h"

@implementation ZXBlotCodeBullInfo

- (id)initWithBull:(ZXBlotCodeBull *)bull {
    if (self = [super init]) {
        _bull = bull;
    }

    return self;
}

@end
