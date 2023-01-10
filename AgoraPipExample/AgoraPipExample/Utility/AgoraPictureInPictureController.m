//
//  AgoraPictureInPictureController.m
//  AgoraPipExample
//
//  Created by Yuhua Hu on 2022/12/01.
//

#import "AgoraPictureInPictureController.h"

@interface AgoraPictureInPictureController () <AVPictureInPictureSampleBufferPlaybackDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) AVPictureInPictureController *pipController;

@property (nonatomic, strong) AgoraSampleBufferRender *displayView;

@property (nonatomic, strong) AVAudioPlayer *player;

@end

@implementation AgoraPictureInPictureController

- (instancetype)initWithDisplayView:(AgoraSampleBufferRender *) displayView {
    if (@available(iOS 15.0, *)) {
        if ([AVPictureInPictureController isPictureInPictureSupported]) {
            self = [super init];
            if (self) {
                _displayView = displayView;
                AVPictureInPictureControllerContentSource *pipControllerContentSource = [[AVPictureInPictureControllerContentSource alloc] initWithSampleBufferDisplayLayer:_displayView.displayLayer playbackDelegate: self];
                
                _pipController = [[AVPictureInPictureController alloc] initWithContentSource: pipControllerContentSource];
//                _pipController.delegate = self;
//                [_pipController addObserver: self
//                                 forKeyPath: @""
//                                    options: [NSKeyValueObservingOptionInitial, NSKeyValueObservingOptionNew]
//                                    context: nil]
                // Start picture in picture when go to background
                _pipController.canStartPictureInPictureAutomaticallyFromInline = false;
                
                // for test
                for(UIView* l in self.displayView.subviews) {
                    NSLog(@"%f", l.frame.size.width);
                }
            }
            return self;
        }
    }
    return nil;
}

//MARK: - <AVPictureInPictureSampleBufferPlaybackDelegate>
- (void)pictureInPictureController:(nonnull AVPictureInPictureController *)pictureInPictureController didTransitionToRenderSize:(CMVideoDimensions)newRenderSize {
    NSLog(@"a %d, %d", newRenderSize.width, newRenderSize.height);
    NSLog(@"%s: %d", __func__, pictureInPictureController.isPictureInPictureActive);
//    if ( pictureInPictureController.isPictureInPictureActive ) {
//        [self.displayView.displayLayer setHidden: NO];
//    }
//    else {
//        NSLog(@"hide layer.");
//        [self.displayView.displayLayer setHidden: YES];
//    }
}

- (void)pictureInPictureController:(nonnull AVPictureInPictureController *)pictureInPictureController setPlaying:(BOOL)playing {
    NSLog(@"pictureInPictureController setplaying %d", playing);
}

- (void)pictureInPictureController:(nonnull AVPictureInPictureController *)pictureInPictureController skipByInterval:(CMTime)skipInterval completionHandler:(nonnull void (^)(void))completionHandler {
    NSLog(@"c");
}

- (BOOL)pictureInPictureControllerIsPlaybackPaused:(nonnull AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"pictureInPictureController paused");
    return NO;
}

- (CMTimeRange)pictureInPictureControllerTimeRangeForPlayback:(nonnull AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"pictureInPictureController time range for playback");
    [self.displayView.displayLayer setHidden: NO];
    return CMTimeRangeMake(kCMTimeNegativeInfinity, kCMTimePositiveInfinity);
}

@end
