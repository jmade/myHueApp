//
//  JDMNetworkObject.h
//  myHueApp
//
//  Created by Justin Madewell on 10/29/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

#import "ScanLAN.h"
#import "Device.h"

#import "route.h"
#import "Utils.h"



@protocol JDMNetworkObjectDelegate <NSObject>

@optional
-(void)ipAddressFound:(NSString*)ipAddress withMACAddress:(NSString*)macAddress;
@end


@interface JDMNetworkObject : NSObject <ScanLANDelegate>

@property(nonatomic,weak) id<JDMNetworkObjectDelegate>networkObjectDelegate;

@property ScanLAN *lanScanner;
@property (nonatomic, strong) NSMutableDictionary *records;


- (id)initWithDelegate:(id<JDMNetworkObjectDelegate>)delegate;

-(void)stopScan;
-(void)startScanning;
-(void)rescan;
-(void)longScan;
-(void)quickScan;

@end
