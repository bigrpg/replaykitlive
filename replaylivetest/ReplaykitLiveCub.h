//
//  ReplaykitLiveCub.h
//  replaylivetest
//
//  Created by zl on 16/9/12.
//  Copyright © 2016年 wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReplayKit/ReplayKit.h>

@protocol RPLiveDelegate <NSObject>
@required
-(void) onStart:(bool) success;
@required
-(void) onStop;

@end

@interface ReplaykitLiveCub : NSObject<RPBroadcastControllerDelegate,RPBroadcastActivityViewControllerDelegate>

+(nonnull ReplaykitLiveCub*) instance;

-(bool) isBroadcasting;
-(bool) isPaused;
-(void) beginBroadcast:(nonnull UIViewController *) vc openMic:(bool)openMic  openCamera:(bool)openCamera;
-(void) stopBroadcast;
-(void) resumeBroadcast;
-(void) pauseBroadcast;
-(void) setupCamear:(bool) ison;
-(void) setupMicrophone:(bool) ison;

@property(nonatomic,strong,nullable) id<RPLiveDelegate>  delegate;

@end
