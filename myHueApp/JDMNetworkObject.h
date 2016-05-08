//
//  JDMNetworkObject.h
//  myHueApp
//
//  Created by Justin Madewell on 10/29/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ScanLAN.h"
#import "Device.h"

@interface JDMNetworkObject : NSObject < ScanLANDelegate >


@property NSMutableArray *connctedDevices;
@property ScanLAN *lanScanner;


@end
