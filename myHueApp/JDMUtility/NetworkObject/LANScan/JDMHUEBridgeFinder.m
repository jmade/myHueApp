//
//  JDMHUEBridgeFinder.m
//  myHueApp
//
//  Created by Justin Madewell on 11/1/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import "JDMHUEBridgeFinder.h"

static NSString* HUEMAC = @"00:17:88:";

static NSString* XML = @"text/xml";
static NSString* JSON = @"application/json";

static NSString* NUPNP_URL = @"https://www.meethue.com/api/nupnp";

static NSString* NOTFOUND = @"NOTFOUND";
static NSString *APPNAME = @"JDMHueBridgeFinder";
static NSString *STORAGE_KEY = @"HueBridgeFinderData";

// Storage Keys
static NSString *BRIDGE_NAME = @"BRIDGE_NAME";
static NSString *BRIDGE_ID = @"BRIDGE_ID";
static NSString *BRIDGE_IP_ADDRESS = @"BRIDGE_IP_ADDRESS";
static NSString *BRIDGE_MAC_ADDRESS = @"BRIDGE_MAC_ADDRESS";
static NSString *BRIDGE_USERNAME = @"BRIDGE_USERNAME";
static NSString *LAST_SAVED = @"LAST_SAVED";

static int NUPNPMethod = 1;
static int ManualScanMethod = 2;
static int ManualEntryMethod = 3;



@interface JDMHUEBridgeFinder ()

@property JDMNetworkObject *networkObject;
@property NSTimer *networkScanTimer;
@property NSTimer *NUPNPTimer;
@property NSTimer *linkTimer;
@property BOOL isNUPNPSearching;
@property BOOL shouldLinkAgian;
@property BOOL shouldContinueLinking;
@property BOOL hasEstablishedLink;


@property UIViewController *viewController;
@property UIView *interfaceView;
@property UILabel *interfaceLabel;

@property NSString *bridgeIPAddress;
@property NSString *bridgeUsername;

@property NSMutableDictionary *data;

@end

@implementation JDMHUEBridgeFinder

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        self.bridgeInformation = [self makeInfoDict];
//        self.data = [[NSMutableDictionary alloc]init];
//        self.foundBridges = [[NSMutableArray alloc]init];
//        
//        [self initialization];
//        
//        self.isNUPNPSearching = NO;
//        self.shouldContinueLinking = YES;
//    }
//    return self;
//}

-(instancetype)initWithViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        [self makeInterfaceForViewController:viewController];
        self.bridgeInformation = [self makeInfoDict];
        self.data = [[NSMutableDictionary alloc]init];
        self.foundBridges = [[NSMutableArray alloc]init];
        
        self.isNUPNPSearching = NO;
        self.shouldContinueLinking = YES;
        self.hasEstablishedLink = NO;
        
        self.viewController = viewController;
        
        [self initialization];
       
    }
    return self;
}




#pragma mark - Initialization

-(void)initialization
{
    NSLog(@"JDMHUEBridgeFinder Initialized");
    
    //   [self deleteSavedUserDafaultData];
//    
  [self readFromUserDefaults];
    
    
    
   [self checkBridgeSituation];
    
    _networkObject = [[JDMNetworkObject alloc]initWithDelegate:self];

}

#pragma mark - User Defaults

-(void)deleteSavedUserDafaultData
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@{}];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:STORAGE_KEY];
     NSLog(@"USER DEFAULTS DATA RESET");
}

-(void)saveToUserDefaults:(NSDictionary*)bridgedata
{
    NSLog(@"SAVING TO USER DEFAULTS");
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:bridgedata];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:STORAGE_KEY];
}

-(void)readFromUserDefaults
{
    NSLog(@"LOADING FROM USER DEFAULTS");
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:STORAGE_KEY];
    NSDictionary *bridgeData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (bridgeData) {
        
        if ([bridgeData allKeys].count > 1) {
           
            //TODO: Handle more than one bridge
        }
        
        NSDictionary *dataDict = [bridgeData valueForKey:[[bridgeData allKeys] firstObject]];
        
        NSString *savedBridgeIPAddress = [[bridgeData allKeys] firstObject];
        
        if (savedBridgeIPAddress) {
            self.bridgeIPAddress = savedBridgeIPAddress;
            [self saveBridgeIP:self.bridgeIPAddress];
        }
        
        
        NSString *savedUserName = [dataDict valueForKey:BRIDGE_USERNAME];
        NSString *savedBridgeID = [dataDict valueForKey:BRIDGE_ID];
        
        if (savedBridgeID) {
            
        }
        
        if (savedUserName) {
            if (!([savedUserName length] == 0)) {
                
                self.bridgeUsername = savedUserName;
                [self saveUserName:self.bridgeUsername];
            }
        }
        
        
        
        
    }
    else
    {
        NSLog(@"NO DATA SAVED");
    }

}


#pragma mark - Finding Data
// write methods that will grab all the rest of the information we need from the bridge, and then once we get the ip, we can look the rest up and save to the dictionary

-(void)gatherInformationFromBridgeIP:(NSString*)bridgeIPAddress
{
    
}

#pragma mark -  Saving Data

-(void)saveData
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.data setValue:self.bridgeInformation forKey:self.bridgeIPAddress];
                       [self saveToUserDefaults:self.data];
                       
                   });

}


-(void)saveBridge:(NSString*)bridgeIPAddress
{
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.bridgeInformation setValue:[self makeBridgeEntry:bridgeIPAddress] forKey:bridgeIPAddress];
                       [self saveToUserDefaults:self.bridgeInformation];
                       
                       if ([self.bridgeUsername isEqualToString:@"NULL"]) {
                           [self startBridgeLink];
                       }
                       else
                       {
                           [self checkBridgeSituation];
                       }
                   });

}



-(void)saveBridgeID:(NSString*)bridgeIDValue
{
    
    NSLog(@"SAVE BRIDGE ID: %@",bridgeIDValue);
    [self.bridgeInformation setValue:bridgeIDValue forKey:BRIDGE_ID];
    NSLog(@"self.bridgeInformation:%@",self.bridgeInformation);
    
    [self saveData];
}

-(void)saveBridgeIP:(NSString*)bridgeIPValue
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       NSLog(@"SAVE BRIDGE IP: %@",bridgeIPValue);
                       self.bridgeIPAddress = bridgeIPValue;
                       [self.bridgeInformation setValue:bridgeIPValue forKey:BRIDGE_IP_ADDRESS];
                       NSLog(@"self.bridgeInformation:%@",self.bridgeInformation);
                   });


     [self saveData];
}

-(void)saveBridgeMACAddress:(NSString*)macAddressValue
{
    NSLog(@"SAVE MAC ADDRESS: %@",macAddressValue);
    [self.bridgeInformation setValue:macAddressValue forKey:BRIDGE_MAC_ADDRESS];
    NSLog(@"self.bridgeInformation:%@",self.bridgeInformation);
    
    [self saveData];

}


-(void)saveUserName:(NSString*)username
{
    NSLog(@"SAVE USER NAME: %@",username);
    [self.bridgeInformation setValue:username forKey:BRIDGE_USERNAME];
    
    NSLog(@"self.bridgeInformation:%@",self.bridgeInformation);
    
    [self saveData];

}

-(NSMutableDictionary*)makeInfoDict
{
  return   [NSMutableDictionary dictionaryWithDictionary:@{
                                                    BRIDGE_NAME : @"",
                                                    BRIDGE_ID : @"",
                                                    BRIDGE_IP_ADDRESS : @"",
                                                    BRIDGE_MAC_ADDRESS : @"",
                                                    BRIDGE_USERNAME : @"",
                                                    LAST_SAVED : @(CFAbsoluteTimeGetCurrent()),
                                                    }];
    
    

}

-(NSDictionary*)makeAutoBridgeEntry
{
    NSString *bridgeID = @"";
    NSString *bridgeMACAddress = @"";
    NSString *bridgeName = @"";
    NSString *bridgeUserName = self.bridgeUsername;
    
    CGFloat currentTime = CFAbsoluteTimeGetCurrent();
    
    return @{
             BRIDGE_NAME : bridgeName,
             BRIDGE_ID : bridgeID,
             BRIDGE_IP_ADDRESS : self.bridgeIPAddress,
             BRIDGE_MAC_ADDRESS : bridgeMACAddress,
             BRIDGE_USERNAME : bridgeUserName,
             LAST_SAVED : @(currentTime),
             };
}


-(NSDictionary*)makeBridgeEntry:(NSString*)bridgeIPAddress
{
    
    NSString *bridgeID = @"";
    NSString *bridgeMACAddress = @"";
    NSString *bridgeName = @"";
    NSString *bridgeUserName = @"NULL";
    
    CGFloat currentTime = CFAbsoluteTimeGetCurrent();
    
    return @{
      BRIDGE_NAME : bridgeName,
      BRIDGE_ID : bridgeID,
      BRIDGE_IP_ADDRESS : bridgeIPAddress,
      BRIDGE_MAC_ADDRESS : bridgeMACAddress,
      BRIDGE_USERNAME : bridgeUserName,
      LAST_SAVED : @(currentTime),
      };
}

-(NSDictionary*)makeBridgeIDEntry:(NSString*)bridgeIPAddress
{
    
    NSString *bridgeID = @"";
    NSString *bridgeMACAddress = @"";
    NSString *bridgeName = @"";
    NSString *bridgeUserName = @"NULL";
    
    CGFloat currentTime = CFAbsoluteTimeGetCurrent();
    
    return @{
             BRIDGE_NAME : bridgeName,
             BRIDGE_ID : bridgeID,
             BRIDGE_IP_ADDRESS : bridgeIPAddress,
             BRIDGE_MAC_ADDRESS : bridgeMACAddress,
             BRIDGE_USERNAME : bridgeUserName,
             LAST_SAVED : @(currentTime),
             };
}











-(void)checkBridgeSituation
{
    
   
    
    NSLog(@"CHECKING FOR BRIDGE VALUE");
    
    NSString *bridgeIp;
    
    bridgeIp = self.bridgeIPAddress;
    
    if (!bridgeIp) {
        
        NSLog(@"NO BRIDGE");
        [self startBridgeSearch];
    }
    else
    {
        NSLog(@"BRIDGE IP IS: %@",bridgeIp);
        [self checkUserName];
    }
}


-(void)checkUserName
{
    NSLog(@"CHECKING FOR USERNAME VALUE");
    
    if (self.bridgeUsername) {
        
        NSString *userName;
        
        userName = self.bridgeUsername;
        
        if ([userName isEqualToString:@"NULL"]) {
            NSLog(@"USERNAME IS NULL");
            [self startBridgeLink];
        }
        else
        {
            NSLog(@"USERNAME IS: %@",userName);
            [self hasUserNameAndBridgeIP];
        }

    }
    else
    {
        NSLog(@"USERNAME IS NULL");
        [self startBridgeLink];
    }
    
    
}

#pragma mark - GREAT SUCCESS
-(void)hasUserNameAndBridgeIP
{
    NSLog(@"HAVE EVERYTHING WE NEED!");
    
    [self animate_SuccessBridgeLinking];
}



#pragma mark - Link To Bridge

/* 
 
 Pitch
 Catch
 Pass
 Home
 
 */



#pragma mark - Start Bridge Link


-(void)startBridgeLink
{
    
    
    NSLog(@"BRIDGE LINK STARTED");
    // display message to tap on the bridge link button now,
    // show a progress bar or something run down in 30 seconds.
    // run a timer that checks every second, then cancels checking after the timer fires.. (32.0) for grace, but only show and aimate the first 30?
    
    
    // show link
    
    [self animate_linkBridgeAcknowledgment];
    
//    dispatch_async(dispatch_get_main_queue(), ^
//                   {
//                       // self.linkTimer  = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(linkTimerFired) userInfo:nil repeats:NO];
//                       self.linkTimer  = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(linkTimerCheck) userInfo:nil repeats:NO];
//                       [self pitchBridgeLink];
//                       NSLog(@"LINK TIMER FIRED...");
//                   });
//
    
    
}

-(void)linkBridgeAcknowledgment
{
    
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       self.interfaceLabel.text = @"Trying To Link...";
                       // self.linkTimer  = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(linkTimerFired) userInfo:nil repeats:NO];
                       self.linkTimer  = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(linkTimerCheck) userInfo:nil repeats:NO];
                       [self pitchBridgeLink];
                       NSLog(@"LINK TIMER FIRED...");
                   });

}

-(void)pitchBridgeLink
{
    NSLog(@"PITCH (REQUEST MADE) FOR LINK BRIDGE");
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:[self makeUserNameRequest]
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      [self catchBridgeLink:data withResponse:response withError:error];
                                  }];
    
    [task resume];
}

-(void)catchBridgeLink:(NSData*)data withResponse:(NSURLResponse*)response withError:(NSError*)error
{
    NSString *caughtValue;
    
    if (error) {
        
        NSLog(@"BRIDGE LINK ERROR");
        NSLog(@"error:%@",error);
        caughtValue = @"ERROR";
        
    }
    else
    {
        
        NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        NSString *responseString = [[[responseArray firstObject] allKeys] firstObject];
        
        if ([responseString isEqualToString:@"error"]) {
            caughtValue = [[[responseArray firstObject] valueForKey:[[[responseArray firstObject] allKeys] firstObject]] valueForKey:@"description"];
        }
        else
        {
            caughtValue = [[[responseArray firstObject] valueForKey:[[[responseArray firstObject] allKeys] firstObject]] valueForKey:@"username"];
        }
    }
    
    [self passBridgeLink:caughtValue];
}

-(void)passBridgeLink:(NSString*)caughtValue
{
    
    if (![caughtValue isEqualToString:@"link button not pressed"]) {
       
        [self homeNewUserNameGenerated:caughtValue];
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self.linkTimer invalidate];
                       });

    }
    else
    {
        NSLog(@"Link Button Not Pressed");
        
        [self updateInterfaceMessage:@"Link Button Not Pressed"];
        
        if (self.shouldContinueLinking) {
            
            NSLog(@"WOULD NORMALLY REFIRE");
            
            [self startBridgeLink];
        }
        
    }
}

-(void)homeNewUserNameGenerated:(NSString*)newUserName
{
    NSLog(@"NEW USERNAME GENERATED: %@",newUserName);
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       self.hasEstablishedLink = YES;
                       self.bridgeUsername = newUserName;
                       [self saveUserName:newUserName];
                       [self saveData];
                       [self animate_SuccessBridgeLinking];
                       
                   });
}



-(void)linkTimerCheck
{
    static int counter;
    
    if (counter > 31 ) {
        NSLog(@"Counted 31 ");
        [self.linkTimer invalidate];
    }
    else
    {
        [self pitchBridgeLink];
    }
    
    
    
    
    counter++;
}


-(void)linkTimerFired
{
    self.shouldContinueLinking = NO;
    NSLog(@"LINK ALARM -- STOPPING LINK PROCESS");
}



-(void)handleBridgeFound:(NSString*)bridgeIPAddress
{
    NSLog(@"BRIDGE FOUND:%@",bridgeIPAddress);
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                        self.bridgeIPAddress = bridgeIPAddress;
                       [self saveData];
                       [self checkBridgeSituation];
                   });
    
    
}

#pragma mark - START BRIDGE SEARCH

-(void)startBridgeSearch
{
    [self startNUPNPLookup];
}


#pragma mark - NUPNPLookup

-(void)startNUPNPLookup
{
    NSLog(@"STARTING NUPNPLookup FOR BRIDGE");
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       self.isNUPNPSearching = YES;
                       self.NUPNPTimer = [NSTimer scheduledTimerWithTimeInterval:8.0 target:self selector:@selector(NUPNPTimerFired) userInfo:nil repeats:NO];
                       [self pitchNUPNPLookup];
                   });
}


-(void)pitchNUPNPLookup
{
    
    
    NSURL *lookupURL = [NSURL URLWithString:NUPNP_URL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:lookupURL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      if (self.isNUPNPSearching) {
                                          [self catchNUPNPLookup:data withResponse:response withError:error];
                                      }
                                      else
                                      {
                                          if (error) {
                                              // NSLog(@"--- finished lookup with Erro but told to shutup about it...---");
                                          }
                                          //NSLog(@"--- finished lookup but told to shutup about it...---");
                                      }
                                    
                                  }];
    
    [task resume];
    
}

-(void)catchNUPNPLookup:(NSData*)data withResponse:(NSURLResponse*)response withError:(NSError*)error
{
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       self.isNUPNPSearching = NO;
                       [self.NUPNPTimer invalidate];
                   });
    

    
    NSString *caughtResult;
    
    if (error) {
        NSLog(@"ERROR OCCURED DURING NUPNP LOOKUP");
        caughtResult = NOTFOUND;
        [self passNUPNPLookup:caughtResult];
    }
    else
    {
        NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        NSLog(@"responseArray:%@",responseArray);
        
        // return the first (or only) bridge
        NSDictionary *bridgeDictionary = [responseArray firstObject];
        NSString *ipaddressString = [bridgeDictionary valueForKey:[[bridgeDictionary allKeys] lastObject]];
        NSString *idString = [bridgeDictionary valueForKey:[[bridgeDictionary allKeys] firstObject]];
        
    
        // ip first
        
        if (ipaddressString) {
            NSLog(@"ipaddressString:%@",ipaddressString);
            [self saveBridgeIP:ipaddressString];
        }
        
        if (idString) {
            [self saveBridgeID:idString];
        }
        
        [self homeIPAddressIsValidedAsBridge:ipaddressString];
        
    }
}

-(void)passNUPNPLookup:(NSString*)caughtResult
{
   
    if ([caughtResult isEqualToString:NOTFOUND]) {
        // try the next thing
        NSLog(@"NO IP VIA NUPNPLookup -- TRYING MANUAL SEARCH");
        [self startManualSearchMethod];
    }
    else
    {
        [self homeWithBridgeIPAddress:caughtResult withMethod:NUPNPMethod];
    }
}


#pragma mark - MANUAL SEARCH MODE

-(void)startManualSearchMethod
{
    [_networkObject startScanning];
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       self.networkScanTimer = [NSTimer scheduledTimerWithTimeInterval:18.0 target:self selector:@selector(networkTimer) userInfo:nil repeats:NO];
                   });
}




#pragma mark - HOME
-(void)homeWithBridgeIPAddress:(NSString*)bridgeIPAddress withMethod:(int)method
{
    NSLog(@"IP RETURNED - %@ Method:%i",bridgeIPAddress,method);
    [self validateIPAddressForBrige:bridgeIPAddress];
}

#pragma mark - Passed Bridge Validation

-(void)homeIPAddressIsValidedAsBridge:(NSString*)ipAddress;
{
    NSLog(@"IP PASSED VALIDATION:%@",ipAddress);
    
    
    
    [self handleBridgeFound:ipAddress];
}


#pragma mark - Timers
-(void)networkTimer
{
    NSLog(@"ERROR Shutting down network Search");
    NSLog(@"STARTING MANUAL ENTRY MODE");
    
    [_networkObject stopScan];
    [self startManalEntryMode];
}

-(void)NUPNPTimerFired
{
    NSLog(@"NOTHING FOUND, CANCELLING REQUEST -- STARTING MANUAL SEARCH");
    
    self.isNUPNPSearching = NO;
    [self startManualSearchMethod];
    
}



#pragma mark - MANUAL ENTRY MODE
-(void)startManalEntryMode
{
    //TODO: Implement User Input if all else fails
    [self homeWithBridgeIPAddress:@"0.0.0.0" withMethod:ManualEntryMethod];
}



#pragma mark - Validate Bridge

-(void)validateIPAddressForBrige:(NSString*)ipAddress
{
    [self picthIPAddressValidation:ipAddress];
}

-(void)picthIPAddressValidation:(NSString*)ipAddress
{
    NSString *ip = ipAddress;
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",@"http://",ip,@"/api/config"];
    
    NSURL *lookupURL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:lookupURL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      [self catchIPAddress:ipAddress forValidation:data withResponse:response withError:error];
                                  }];
    [task resume];

}

-(void)catchIPAddress:(NSString*)ipAddress forValidation:(NSData*)data withResponse:(NSURLResponse*)response withError:(NSError*)error
{
    BOOL isValid = YES;
    
    if (error) {
        NSLog(@"NONVALID IP");
        NSLog(@"error:%@",error);
        isValid = NO;
    }
    else
    {
        isValid = YES;
    }
    
    [self passIPAddress:ipAddress forValidation:isValid];
}

-(void)passIPAddress:(NSString*)ipAddress forValidation:(BOOL)caughtResult
{
    if (caughtResult) {
        [self homeIPAddressIsValidedAsBridge:ipAddress];
    }
    else
    {
        NSLog(@"BRIDGE VALIDATION FAILED");
    }
}





















//
//#pragma mark - Find Bridge
//-(void)findBridge
//{
//
//    // then get config
//    [self lookupConfig];
//}




#pragma mark - OG Methods

-(void)lookupConfig
{
    NSString *ip = @"192.168.0.3";
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",@"http://",ip,@"/api/config"];
    
    NSURL *lookupURL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:lookupURL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      [self processResponseData:data withResponseURL:response];
                                  }];
    [task resume];
}

-(void)getDataDump
{
    NSString *ip = @"192.168.0.3";
    
    NSString *userName = @"4147c93c1362355d2665b1ec36113312";
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@%@",@"http://",ip,@"/api/",userName,@"/"];
    
    NSLog(@"urlString:%@",urlString);
    
    NSURL *lookupURL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:lookupURL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      [self processResponseData:data withResponseURL:response];
                                  }];
    [task resume];

}


-(void)lookupConfigWithUserName
{
    NSString *ip = @"192.168.0.3";
    
    NSString *userName = @"4147c93c1362355d2665b1ec36113312";
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@%@",@"http://",ip,@"/api/",userName,@"/config"];
    
    
    NSURL *lookupURL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:lookupURL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                     [self processResponseData:data withResponseURL:response];
                                  }];
    [task resume];
    
    
    
}


-(void)lookupDescription
{
    NSString *ip = @"192.168.0.3";
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",@"http://",ip,@"/description.xml"];
    
    
    NSURL *lookupURL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:lookupURL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                     [self processResponseData:data withResponseURL:response];                                      
                                  }];
    [task resume];

}


-(void)lookupUPNP
{
    NSURL *lookupURL = [NSURL URLWithString:@"https://www.meethue.com/api/nupnp"];
    NSURLRequest *request = [NSURLRequest requestWithURL:lookupURL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      [self processResponseData:data withResponseURL:response];
                                }];
    
    [task resume];
    
}










// NOT using
#pragma mark - Handle Request

-(void)processResponseData:(NSData*)responseData withResponseURL:(NSURLResponse*)responseURL
{
    // Find the URL Response if Coming From
    NSString *responseString = [responseURL.URL absoluteString];
    NSLog(@"responseString:%@",responseString);
    
    // Get the Data From Response Into a Dictionary
    NSDictionary *responseDictionary;
    if ([self isContentTypeJSON:responseURL]) {
        responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    }
    else
    {
        responseDictionary = [NSDictionary dictionaryWithXMLData:responseData];
    }
    
    
    // handle the data based off the url
    NSLog(@"responseDictionary:%@",responseDictionary);
    

    
}




-(void)changeLight
{
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:[self makeLightRequest]
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      NSLog(@"response:%@",response);
                                      
                                      NSDictionary *responseDictionary;
                                      
                                      if ([self isContentTypeJSON:response]) {
                                          
                                          //JSON
                                          
                                          NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                          responseDictionary = @{@"Response Array":responseArray,};
                                      }
                                      else
                                      {
                                          // XML
                                          responseDictionary = [NSDictionary dictionaryWithXMLData:data];
                                      }
                                      
                                      NSLog(@"responseDictionary:%@",responseDictionary);
                                      
                                      
                                  }];
    
    [task resume];
    
    
    

}







#pragma mark - JDMNetworkObject Delegate

-(void)ipAddressFound:(NSString *)ipAddress withMACAddress:(NSString *)macAddress
{
    
    if ([self isMACAddressForHueBridge:macAddress]) {
        // could be for hue bridge
        NSLog(@"FOUND POSSIBLE BRIDGE IP");
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self.networkScanTimer invalidate];
                       });

        
        
        [_networkObject stopScan];
        [self homeWithBridgeIPAddress:ipAddress withMethod:ManualScanMethod];
    }
}





#pragma mark - Utilities

-(BOOL)isContentTypeJSON:(NSURLResponse*)response
{
    BOOL isJSON = YES;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *urlResponseData = httpResponse.allHeaderFields;
    NSString *contentType = [urlResponseData valueForKey:@"Content-Type"];
    
    if (![contentType isEqualToString:@"application/json"]) {
        isJSON = NO;
    }
    
    return isJSON;
}


-(BOOL)isMACAddressForHueBridge:(NSString*)macAddress
{
    BOOL macAddressIsForHueBridge = NO;
    
    NSString *macStart = [macAddress substringToIndex:9];
    
    if ([macStart isEqualToString:HUEMAC]) {
        macAddressIsForHueBridge = YES;
    }
    
    return macAddressIsForHueBridge;
}


-(BOOL)validateUserName:(NSString*)username
{
    //TODO: Implement, by looking up the bridge whitelist -- or by making a call to confid with username?
    return YES;
}


-(NSMutableURLRequest*)makeUserNameRequest
{
    // Create the request.
    NSString *ipAddress = self.bridgeIPAddress;
    NSString *urlString = [NSString stringWithFormat:@"http://%@/api",ipAddress];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"POST";
    
    NSString *deviceName = [[UIDevice currentDevice] name];
    
    NSString *valueString = [NSString stringWithFormat:@"%@#%@",APPNAME,deviceName];
    
    NSDictionary* jsonDictionary = @{
                                     @"devicetype" : valueString ,
                                     };
    
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    request.HTTPBody = jsonData;
    
    return request;
}








-(NSMutableURLRequest*)makeLightRequest
{
     // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.0.3/api/4147c93c1362355d2665b1ec36113312/lights/3/state"]];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"PUT";
    
    NSDictionary* jsonDictionary = @{
                          @"effect" : @"none",
                       };
    
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:NSJSONWritingPrettyPrinted error:&error];

    request.HTTPBody = jsonData;
    
    return request;
}









#pragma mark - UI

-(void)makeInterfaceForViewController:(UIViewController*)viewController
{
    CGFloat wid = ScreenWidth();
    
    CGRect interfaceRect = CGRectMake(0, 0, wid, 100);
    UIView *interface = [[UIView alloc]initWithFrame:interfaceRect];
    
    interface.layer.cornerRadius = 0;
    interface.layer.masksToBounds = YES;
    
    interface.backgroundColor = [UIColor peachColor];
    
    CGFloat label_H = interfaceRect.size.height;
    CGFloat labelAmount = label_H/2;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, wid, labelAmount)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Checking...";
    label.textColor = [UIColor whiteColor];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, labelAmount, wid, labelAmount)];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"Checking 2...";
    label2.textColor = [UIColor whiteColor];
    
    [interface addSubview:label];
    [interface addSubview:label2];
    
    
    UITapGestureRecognizer *interfaceTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleInterfaceTap:)];
    [interface addGestureRecognizer:interfaceTap];
    
    [viewController.view addSubview:interface];

    self.interfaceView = interface;
    self.interfaceLabel = label;
    
    
//     CGRect shiftedUpRect = CGRectMake(0, -100, ScreenWidth(), 100);
//    interface.frame = shiftedUpRect;
    
}



-(void)handleInterfaceTap:(UITapGestureRecognizer*)tap
{
    if (!self.hasEstablishedLink) {
        [self linkBridgeAcknowledgment];
    }
    
    
//    static int counter;
//    
//    if (counter > 5) {
//        counter = 0;
//    }
//    
//    switch (counter) {
//        case 0:
//            [self animate_changeInterfaceViewColor];
//            break;
//        case 1:
//            [self animate_shiftInterfaceViewUp];
//            break;
//        case 2:
//            [self animate_shiftInterfaceViewDown];
//            break;
//        case 3:
//            [self animate_changeInterfaceViewColor];
//            break;
//        case 4:
//            [self animate_shiftInterfaceViewUp];
//            break;
//        case 5:
//             [self animate_shiftInterfaceViewDown];
//            break;
//            
//        default:
//            break;
//    }
//    counter++;
    

}


-(void)animate_shiftInterfaceViewUp
{
    CGRect currentFrame = self.interfaceView.frame;
    CGRect upRect = CGRectMake(currentFrame.origin.x, currentFrame.origin.y + 100, currentFrame.size.width, currentFrame.size.height);

    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.67 initialSpringVelocity:0.65 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.interfaceView.frame = upRect;
    } completion:^(BOOL finished) {
        //
    }];


}

-(void)animate_shiftInterfaceViewDown
{
    
    
    CGRect currentFrame = self.interfaceView.frame;
    CGRect downRect = CGRectMake(currentFrame.origin.x, currentFrame.origin.y - 100, currentFrame.size.width, currentFrame.size.height);
    
    
    [UIView animateWithDuration:0.4 delay:0.5 usingSpringWithDamping:0.67 initialSpringVelocity:0.65 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.interfaceView.frame = downRect;
    } completion:^(BOOL finished) {
        //
    }];

}

-(void)animate_changeInterfaceViewColor
{
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.67 initialSpringVelocity:0.34 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.interfaceView.backgroundColor = randomColor();
    } completion:^(BOOL finished) {
        //
    }];

}

-(void)animate_tapBridgeLink
{
    //
}


-(void)animate_linkBridgeAcknowledgment
{
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.67 initialSpringVelocity:0.34 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                           self.interfaceView.backgroundColor = [UIColor babyBlueColor];
                           self.interfaceLabel.text = @"Tap Here Once Bridge Link Button Has Been Pressed";
                       } completion:^(BOOL finished) {
                           //
                       }];                        
                   });


    
    
}

-(void)updateInterfaceMessage:(NSString*)message
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       self.interfaceLabel.text = message;
                   });

}

-(void)animate_SuccessBridgeLinking
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.67 initialSpringVelocity:0.34 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                           self.interfaceView.backgroundColor = [UIColor greenColor];
                           self.interfaceLabel.text = [NSString stringWithFormat:@"Bridge Linked! %@",self.bridgeUsername];
                       } completion:^(BOOL finished) {
                           [self animate_shiftInterfaceViewDown];
                       }];
                   });

}





















@end
