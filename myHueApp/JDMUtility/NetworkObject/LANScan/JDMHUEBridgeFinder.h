//
//  JDMHUEBridgeFinder.h
//  myHueApp
//
//  Created by Justin Madewell on 11/1/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDMUtility.h"

@interface JDMHUEBridgeFinder : NSObject <JDMNetworkObjectDelegate>

@property (nonatomic, strong) NSMutableArray *foundBridges;
@property (nonatomic, strong) NSMutableDictionary *bridgeInformation;


-(instancetype)initWithViewController:(UIViewController*)viewController;


@end
