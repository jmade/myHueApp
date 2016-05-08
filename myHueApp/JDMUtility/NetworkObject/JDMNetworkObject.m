//
//  JDMNetworkObject.m
//  myHueApp
//
//  Created by Justin Madewell on 10/29/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import "JDMNetworkObject.h"
#import "JDMUtility.h"

@implementation JDMNetworkObject

- (id)initWithDelegate:(id<JDMNetworkObjectDelegate>)delegate {
    
    self = [super init];
    if(self)
    {
        self.networkObjectDelegate = delegate;
        self.records = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark - External Scan Methods

-(void)stopScan
{
    [self.lanScanner stopScan];
}

-(void)startScanning
{
    [self startScannerWithTime:0.5];
}


-(void)rescan
{
    [self startScannerWithTime:0.5];
}


-(void)quickScan
{
    [self startScannerWithTime:0.1];
}


-(void)longScan
{
    [self startScannerWithTime:2.5];
}

-(void)startScannerWithTime:(CGFloat)scanTime
{
    [self.lanScanner stopScan];
    self.lanScanner = [[ScanLAN alloc] initWithDelegate:self];
    self.lanScanner.scanTime = scanTime;
    [self.lanScanner startScan];
}



-(void)addRecordToDictionary:(NSString*)newAddress
{
    // if theres a new ip, run it and add it to the master dictionary
    NSString *ipAddress = newAddress;
    NSString *macAddress = [self ipAdressToMacAddress:ipAddress];
    
    [self.networkObjectDelegate ipAddressFound:ipAddress withMACAddress:macAddress];
    
    [self.records setValue:macAddress forKey:ipAddress];
    
   
    
}

#pragma mark - ARP

-(NSString*)ipAdressToMacAddress:(NSString*)ipAddress
{
    return  [Utils ipToMac:ipAddress];
}

-(NSString*)getDefaultGatewayIp
{
    return [Utils getDefaultGatewayIp];
}


#pragma mark - LANScan
#pragma mark LAN Scanner delegate method

- (void)scanLANDidFindNewAdrress:(NSString *)address havingHostName:(NSString *)hostName {
 
    [self addRecordToDictionary:address];
}

- (void)scanLANDidFinishScanning {
     
}


@end
