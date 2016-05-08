//
//  ViewController.m
//  myHueApp
//
//  Created by Justin Madewell on 10/29/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import "ViewController.h"
#import "JDMUtility.h"

@interface ViewController ()

@property JDMHUEBridgeFinder *bridgeFinder;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self doSomething];
   
}

-(void)doSomething
{
    CALayer *hud = LayerMakeHudLayer(0.35);
    hud.borderColor = ColorGetDeviceColor().CGColor;
    [self.view.layer addSublayer:hud];
    
}





#pragma mark - Touches
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    static int checker;
    
    if (checker==0) {
        _bridgeFinder = [[JDMHUEBridgeFinder alloc]initWithViewController:self];
    }
    
    checker++;
    
   
}




//#pragma mark - interface
//
//-(UILabel*)makeLabelForIP:(NSString*)ip withMAC:(NSString*)mac
//{
//    UILabel *label =  [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth(),44)];
//    label.numberOfLines = 1;
//    label.textAlignment = NSTextAlignmentCenter;
//    
//    
//    NSString *string = [NSString stringWithFormat:@"%@ - %@",ip,mac];
//    
//    label.text = string;
//    
//    [self.view addSubview:label];
//    
//    
//    return label;
//}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
