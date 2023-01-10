//
//  AgoraSampleBufferRender.m
//  AgoraPipExample
//
//  Created by Yuhua Hu on 2022/12/01.
//

#import "AgoraSampleBufferRender.h"

@interface AgoraSampleBufferRender() <CALayerDelegate> {
    NSInteger _videoWidth, _videoHeight;
}

@property (nonatomic, strong) AVSampleBufferDisplayLayer *displayLayer;

@end

@implementation AgoraSampleBufferRender

- (AVSampleBufferDisplayLayer *)displayLayer {
    if (!_displayLayer) {
        _displayLayer = [AVSampleBufferDisplayLayer new];
    }
    
//    _displayLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//    _displayLayer.opaque = YES;
    return _displayLayer;
}

- (instancetype)init {
    if (self = [super init]) {
        self.displayLayer.delegate = self;
        [self.layer addSublayer: self.displayLayer];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.layer addSublayer: self.displayLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.clipsToBounds = YES;
    [self layoutDisplayLayer];
}

- (void)layoutDisplayLayer {
    if (_videoWidth == 0 || _videoHeight == 0 || CGSizeEqualToSize(self.frame.size, CGSizeZero)) {
        return;
    }
    
    CGFloat viewWidth = self.frame.size.width;
    CGFloat viewHeight = self.frame.size.height;
    CGFloat videoRatio = (CGFloat)_videoWidth/(CGFloat)_videoHeight;
    CGFloat viewRatio = viewWidth/viewHeight;
    
    CGSize videoSize;
    if (videoRatio >= viewRatio) {
        videoSize.height = viewHeight;
        videoSize.width = videoSize.height * videoRatio;
    } else {
        videoSize.width = viewWidth;
        videoSize.height = videoSize.width / videoRatio;
    }
    
    CGRect renderRect = CGRectMake(0.5 * (viewWidth - videoSize.width), 0.5 * (viewHeight - videoSize.height), videoSize.width, videoSize.height);

    if (!CGRectEqualToRect(renderRect, self.displayLayer.frame)) {
        NSLog(@"reset displayLayer frame");
        self.displayLayer.frame = renderRect;
    }
}

- (void)reset {
    //[self.displayLayer flushAndRemoveImage];
}

- (void)renderVideoData:(AgoraVideoDataFrame *_Nonnull)videoData {
    if (!videoData) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_videoWidth = videoData.width;
        self->_videoHeight = videoData.height;
        
        //NSLog(@"%d, %d", videoData.width, videoData.height);
        [self layoutDisplayLayer];
    });
    
    size_t width = videoData.width;
    size_t height = videoData.height;
    size_t yStride = videoData.yStride;
    size_t uStride = videoData.uStride;
    size_t vStride = videoData.vStride;
    
    void* yBuffer = videoData.yBuffer;
    void* uBuffer = videoData.uBuffer;
    void* vBuffer = videoData.vBuffer;
    
    @autoreleasepool {
        CVPixelBufferRef pixelBuffer = NULL;
        NSDictionary *pixelAttributes = @{(id)kCVPixelBufferIOSurfacePropertiesKey : @{}};
        CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_420YpCbCr8Planar, (__bridge CFDictionaryRef)(pixelAttributes), &pixelBuffer);

        if (result != kCVReturnSuccess) {
            NSLog(@"Unable to create cvpixelbuffer %d", result);
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        
        void *yPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        int pixelBufferYBytes = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);

        if (yStride == pixelBufferYBytes) {
            memcpy(yPlane, yBuffer, yStride*height);
        } else {
            for (int i = 0; i < height; ++i) {
                memcpy(yPlane + pixelBufferYBytes * i, yBuffer + yStride * i, MIN(yStride, pixelBufferYBytes));
            }
        }

        void *uPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
        int pixelBufferUBytes = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
        if (uStride == pixelBufferUBytes) {
            memcpy(uPlane, uBuffer, uStride*height/2);
        } else {
            for (int i = 0; i < height/2; ++i) {
                memcpy(uPlane + pixelBufferUBytes * i, uBuffer + uStride * i, MIN(uStride, pixelBufferUBytes));
            }
        }

        void *vPlane = (void *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 2);
        int pixelBufferVBytes = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 2);
        if (vStride == pixelBufferVBytes) {
            memcpy(vPlane, vBuffer, vStride*height/2);
        } else {
            for (int i = 0; i < height/2; ++i) {
                memcpy(vPlane + pixelBufferVBytes * i, vBuffer + vStride * i, MIN(vStride, pixelBufferVBytes));
            }
        }

        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);

        CMVideoFormatDescriptionRef videoInfo;
        CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &videoInfo);
        
        CMSampleTimingInfo timingInfo;
        timingInfo.duration = kCMTimeZero;
        timingInfo.decodeTimeStamp = kCMTimeInvalid;
        timingInfo.presentationTimeStamp = CMTimeMake(CACurrentMediaTime()*1000, 1000);
        
        CMSampleBufferRef sampleBuffer;
        CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault, pixelBuffer, videoInfo, &timingInfo, &sampleBuffer);

        [self.displayLayer enqueueSampleBuffer:sampleBuffer];
        CMSampleBufferInvalidate(sampleBuffer);
        CFRelease(sampleBuffer);
        
        CVPixelBufferRelease(pixelBuffer);
    }
}

// MARK: - <CALayerDelegate>
// Try to find how to fix the blink
- (void)displayLayer:(CALayer *)layer {
    NSLog(@"CALayerDelegate - displayLayer");
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    NSLog(@"CALayerDelegate - drawLayer inContext");
}

- (void)layerWillDraw:(CALayer *)layer {
    NSLog(@"CALayerDelegate - layerWillDraw");
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    NSLog(@"CALayerDelegate - layoutSublayersOfLayer");
}

- (nullable id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event {
    NSLog(@"CALayerDelegate - actionForLayer %@", event);
    return nil;
}

@end
