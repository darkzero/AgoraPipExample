//
//  LiveViewController.m
//  AgoraPipExample
//
//  Created by Yuhua Hu on 2022/12/01.
//

#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import "LiveViewController.h"
#import "AgoraPictureInPictureController.h"
#import "SampleBufferDisplayView.h"
#import <QuartzCore/QuartzCore.h>

@interface LiveViewController () <AgoraRtcEngineDelegate, AgoraVideoDataFrameProtocol, AVPictureInPictureControllerDelegate, CALayerDelegate>
@property (nonatomic, weak) AgoraRtcEngineKit* agoraEngine;
@property (nonatomic, strong) AgoraPictureInPictureController* pipController;
@property (nonatomic, strong) IBOutlet SampleBufferDisplayView* remoteVideoView;
@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pipController = [[AgoraPictureInPictureController alloc] initWithDisplayView: self.remoteVideoView.videoView];
    self.pipController.pipController.delegate = self;
    
    // Do any additional setup after loading the view.
    self.agoraEngine = [AgoraRtcEngineKit sharedEngineWithAppId: self.appId delegate: self];
    [self.agoraEngine setParameters: @"{\"che.video.enable_bg_hw_decodec\": true}"];
    
    [self.agoraEngine enableVideo];
    
    // Setup raw video data frame observer
    [self.agoraEngine setVideoDataFrame: self];
    
    [self.remoteVideoView setPlaceHolder: @"remote video"];
    [self.remoteVideoView setInfo:@"Live info here. Just for test"];
    
    self.remoteVideoView.videoView.displayLayer.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [self.agoraEngine setClientRole: AgoraClientRoleAudience];
    
    NSLog(@"appid: %@, channel: %@", self.appId, self.channlName);
    // channel config
    AgoraRtcEngineConfig* config = [[AgoraRtcEngineConfig alloc] init];
    config.appId = self.appId;
    config.areaCode = AgoraAreaCodeGLOB;
    
    // channel profile
    [self.agoraEngine setChannelProfile: AgoraChannelProfileLiveBroadcasting];
    
    // join channel
    [self.agoraEngine joinChannelByToken: nil
                               channelId: self.channlName
                                    info: nil
                                     uid: 0
                             joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        // nothing
        NSLog(@"Join channel %@ success, uid is %ld", channel, uid);
    }];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    NSLog(@"will move to parent view controller.");
    if (parent == nil) {
        
    }
}

- (IBAction)onCloseButtonClicked: (id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

- (IBAction)onPipButtonClicked: (id)sender {
    NSLog(@"onPipButtonClicked");
    if (self.pipController != nil) {
//        NSLog(@"%@", self.pipController.pipController.pictureInPicturePossible?@"YES":@"NO");
//        NSLog(@"%@", self.pipController.pipController.isPictureInPicturePossible?@"YES":@"NO");
//        NSLog(@"%@", self.pipController.pipController.pictureInPictureSuspended?@"YES":@"NO");
        if (self.pipController.pipController.pictureInPicturePossible) {
            [self.pipController.pipController startPictureInPicture];
        }
    }
}

// MARK: - AgoraRtcEngineDelegate
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    NSLog(@"Host %ld joined.", uid);
//    AgoraRtcVideoCanvas* canvas = [[AgoraRtcVideoCanvas alloc] init];
//    canvas.uid = uid;
//    canvas.view = self.remoteVideoView.videoView;
//    canvas.renderMode = AgoraVideoRenderModeHidden;
    [self.remoteVideoView.videoView reset];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    //
    [self.remoteVideoView.videoView reset];
}

// MARK: - AgoraVideoDataFrameProtocol
- (BOOL)onCaptureVideoFrame:(AgoraVideoDataFrame *)videoFrame {
    return YES;
}

- (BOOL)onRenderVideoFrame:(AgoraVideoDataFrame *)videoFrame forUid:(unsigned int)uid {
    [self.remoteVideoView.videoView renderVideoData: videoFrame];
    return YES;
}

- (AgoraVideoFrameType)getVideoFormatPreference {
    return AgoraVideoFrameTypeYUV420;
}

- (BOOL)getRotationApplied {
    return YES;
}

- (BOOL)getMirrorApplied {
    return NO;
}

// MARK: - AVPictureInPictureControllerDelegate

- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"will start pip");
//    [self.remoteVideoView.videoView setHidden: YES];
    pictureInPictureController.requiresLinearPlayback = NO;
//    [self.remoteVideoView setAlpha: 0.0];
    
    BOOL a = _remoteVideoView.videoView.displayLayer.hidden; //[self.remoteVideoView.videoView.layer.sublayers containsObject: _remoteVideoView.videoView.displayLayer];
    NSLog(@"will start pip %d", a);
//    [_remoteVideoView.videoView.displayLayer setHidden: YES];
}

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"did start pip");
    
//    BOOL a = [self.remoteVideoView.videoView.layer.sublayers containsObject: _remoteVideoView.videoView.displayLayer];
    BOOL a = _remoteVideoView.videoView.displayLayer.hidden;
    NSLog(@"did start pip %d", a);
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error {
    NSLog(@"%@", error.localizedDescription);
}

- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"will stop pip");
    
    //    BOOL a = [self.remoteVideoView.videoView.layer.sublayers containsObject: _remoteVideoView.videoView.displayLayer];
    BOOL a = _remoteVideoView.videoView.displayLayer.hidden;
    NSLog(@"will stop pip %d", a);
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"did stop pip");
//    [UIView animateWithDuration:0.33 delay:0.5 options: nil animations:^{
//        [self.remoteVideoView setAlpha: 1.0];
//    } completion:^(BOOL finished) {
//        //
//    }];
    
//    BOOL a = [self.remoteVideoView.videoView.layer.sublayers containsObject: _remoteVideoView.videoView.displayLayer];
    BOOL a = _remoteVideoView.videoView.displayLayer.hidden;
    NSLog(@"did stop pip %d", a);
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler {
    NSLog(@"restore ui");
}


// CALayerDelegate
- (void)displayLayer:(CALayer *)layer {
    NSLog(@"displayLayer");
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    NSLog(@"drawLayer inContext");
}

- (void)layerWillDraw:(CALayer *)layer {
    NSLog(@"layerWillDraw");
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    NSLog(@"layoutSublayersOfLayer: %f", ((AVSampleBufferDisplayLayer*)layer).frame.size.width);
}

//- (nullable id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event {
//
//}

@end
