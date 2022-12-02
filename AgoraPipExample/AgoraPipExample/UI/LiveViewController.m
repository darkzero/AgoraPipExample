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

@interface LiveViewController () <AgoraRtcEngineDelegate, AgoraVideoDataFrameProtocol, AVPictureInPictureControllerDelegate>
@property (nonatomic, weak) AgoraRtcEngineKit* agoraEngine;
@property (nonatomic, strong) AgoraPictureInPictureController* pipController;
@property (nonatomic, weak) IBOutlet SampleBufferDisplayView* remoteVideoView;
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
    
    [self.remoteVideoView setPlaceHolder: @"remote host"];
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

@end
