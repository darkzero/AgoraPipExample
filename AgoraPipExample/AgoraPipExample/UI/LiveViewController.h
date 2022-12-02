//
//  LiveViewController.h
//  AgoraPipExample
//
//  Created by Yuhua Hu on 2022/12/01.
//

#import <UIKit/UIKit.h>
#import <AgoraRtcKit/AgoraRtcEngineKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveViewController : UIViewController
@property (nonatomic, strong) NSString* appId;
@property (nonatomic, strong) NSString* channlName;
@end

NS_ASSUME_NONNULL_END
