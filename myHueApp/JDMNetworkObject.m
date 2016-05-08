//
//  JDMNetworkObject.m
//  myHueApp
//
//  Created by Justin Madewell on 10/29/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import "JDMNetworkObject.h"

@implementation JDMNetworkObject



- (void)startScanningLAN {
    
    [self.lanScanner stopScan];
    
    self.lanScanner = [[ScanLAN alloc] initWithDelegate:self];
    self.connctedDevices = [[NSMutableArray alloc] init];
    
    [self.lanScanner startScan];
}


#pragma mark LAN Scanner delegate method
- (void)scanLANDidFindNewAdrress:(NSString *)address havingHostName:(NSString *)hostName {
    NSLog(@"found  %@", address);
    Device *device = [[Device alloc] init];
    device.name = hostName;
    device.address = address;
    [self.connctedDevices addObject:device];
    [self.tableView reloadData];
}

- (void)scanLANDidFinishScanning {
    NSLog(@"Scan finished");
    [[[UIAlertView alloc] initWithTitle:@"Scan Finished" message:[NSString stringWithFormat:@"Number of devices connected to the Local Area Network : %lu", (unsigned long)self.connctedDevices.count] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}




@end
