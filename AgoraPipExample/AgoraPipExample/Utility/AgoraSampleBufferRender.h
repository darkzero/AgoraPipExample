//
//  AgoraSampleBufferRender.h
//  AgoraPipExample
//
//  Created by Yuhua Hu on 2022/12/01.
//

#import <UIKit/UIKit.h>
#import <AgoraRtcKit/AgoraRtcEngineKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraSampleBufferRender : UIView

@property (nonatomic, readonly) AVSampleBufferDisplayLayer *displayLayer;

- (void)reset;

- (void)renderVideoData:(AgoraVideoDataFrame *_Nonnull)videoData;

@end

NS_ASSUME_NONNULL_END
