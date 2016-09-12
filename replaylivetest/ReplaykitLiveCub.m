//
//  ReplaykitLiveCub.m
//  replaylivetest
//
//  Created by zl on 16/9/12.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "ReplaykitLiveCub.h"


@interface ReplaykitLiveCub() {

    bool    isSetupping;
    bool    openMic;
    bool    openCamera;
    
}

@property (strong, nonatomic) UIViewController * owerVC;
@property (strong, nonatomic) RPBroadcastController * brcontroller;
@property (strong, nonatomic) RPBroadcastActivityViewController * brviewcontroller;

@end

@implementation ReplaykitLiveCub

@synthesize     owerVC;
@synthesize     brcontroller;

+(nonnull ReplaykitLiveCub*) instance
{
    static dispatch_once_t pred = 0;
    __strong static id instance = nil;
    dispatch_once(&pred , ^{
        instance = [[ReplaykitLiveCub alloc] init];
    });
    return (ReplaykitLiveCub*)instance;
}

-(nonnull ReplaykitLiveCub *) init
{
    self = [super init];
    openMic = false;
    openCamera = false;
    isSetupping = false;
    self.owerVC = nil;
    return self;
}

-(bool) isBroadcasting
{
    return self.brcontroller != nil && self.brcontroller.isBroadcasting;
}

-(bool) isPaused
{
    return self.brcontroller != nil && self.brcontroller.isPaused;
}

-(void) beginBroadcast:(UIViewController *) vc openMic:(bool)openMic_  openCamera:(bool)openCamera_
{
    if([self isBroadcasting])
        return;
    if(isSetupping)
        return;
    isSetupping = true;
    
    openMic = openMic_;
    openCamera = openCamera_;
    
    [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler: ^(RPBroadcastActivityViewController *broadcastActivityViewController, NSError *error) {
        
        if(error != nil || broadcastActivityViewController == nil)
            isSetupping = false;

        if(error)
        {
            NSLog(@"%@", error.localizedDescription);
        }
        if(broadcastActivityViewController)
        {
            self.owerVC = vc;
            broadcastActivityViewController.delegate = self;
            //resolved crash in ipad
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                broadcastActivityViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            }
            [self.owerVC presentViewController:broadcastActivityViewController animated:YES completion:^{
                NSLog(@"DIsplay complete!");
            }];
        }
    }];
    
}

-(void) stopBroadcast
{
    if(![self isBroadcasting])
    {
        NSLog(@"have stopped");
        [self clearStatus];
        return;
    }
    
    [self.brcontroller finishBroadcastWithHandler:^(NSError * _Nullable error) {
        
        if( error != nil)
            NSLog(@"error onstop:%@",error.description);
        [self clearStatus];
        NSLog(@"broadcast live stopped");
    }];
    
}

-(void) resumeBroadcast
{
    if([self isBroadcasting])
        [self.brcontroller resumeBroadcast];
}

-(void) pauseBroadcast
{
    if([self isBroadcasting])
        [self.brcontroller pauseBroadcast];
}

-(void) setupCamear:(bool) ison
{
    if(ison && ![self isBroadcasting])
        return;
    if(openCamera == ison)
        return;
    openCamera = ison;
    
    if(openCamera)
    {
        [RPScreenRecorder sharedRecorder].cameraEnabled = TRUE;
        UIView * v = [RPScreenRecorder sharedRecorder].cameraPreviewView;
        [self.owerVC.view addSubview:v];
    }
    else
    {
        UIView * v = [RPScreenRecorder sharedRecorder].cameraPreviewView;
        if(v != nil)
            [v removeFromSuperview];
    }
}

-(void) setupMicrophone:(bool) ison
{
    if(ison && ![self isBroadcasting])
        return;
    if(openMic == ison)
        return;
    openMic = ison;
    
    [RPScreenRecorder sharedRecorder].microphoneEnabled = openMic;
}



-(void) clearStatus
{
    if(self.brviewcontroller != nil)
        self.brviewcontroller.delegate = nil;
    if(self.brcontroller != nil)
        self.brcontroller.delegate = nil;
    self.brcontroller = nil;
    self.brviewcontroller = nil;
    
    [self setupCamear:false];
    [self setupMicrophone:false];

}


#pragma mark - delegate

- (void)broadcastController:(RPBroadcastController *)broadcastController didFinishWithError:(NSError * __nullable)error
{
    if( error != nil)
        NSLog(@"broadcast finished due to: error:%@",error.description);
    
    if(broadcastController != nil)
    {
        broadcastController.delegate = nil;
        broadcastController = nil;
    }
    [self clearStatus];
    NSLog(@"broadcast is stopped by some reason");
}


- (void)broadcastActivityViewController:(RPBroadcastActivityViewController *)broadcastActivityViewController didFinishWithBroadcastController:(RPBroadcastController *)broadcastController error:(NSError *)error
{
    if( error != nil)
        NSLog(@"to start error:%@",error.description);

    if(broadcastActivityViewController != nil)
    {
        [broadcastActivityViewController dismissViewControllerAnimated:YES completion:^{
            
            if(broadcastController != nil)
            {
                [RPScreenRecorder sharedRecorder].microphoneEnabled = openMic;
                [RPScreenRecorder sharedRecorder].cameraEnabled = TRUE;

                [broadcastController startBroadcastWithHandler:^(NSError * _Nullable error) {
                    if( error != nil)
                    {
                        NSLog(@"error:%@",error.description);
                    }
                    else
                    {
                        self.brcontroller = broadcastController;
                        self.brcontroller.delegate = self;
                        self.brviewcontroller = broadcastActivityViewController;
                        self.brviewcontroller.delegate = self;
                        
                        bool temp = openCamera;
                        openCamera = false;
                        if(temp)
                           [self setupCamear:temp];

                        NSLog(@"broadcast live successfully");
                    }
                    
                }];
            }
            else
            {
                NSLog(@"broadcast setup failed");
            }
            
        }];
    }
    isSetupping = false;
 }


@end
