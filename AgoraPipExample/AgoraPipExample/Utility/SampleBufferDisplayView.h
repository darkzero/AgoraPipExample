//
//  SampleBufferDisplayView.h
//  AgoraPipExample
//
//  Created by Yuhua Hu on 2022/12/01.
//

#import <UIKit/UIKit.h>
#import "AgoraSampleBufferRender.h"

NS_ASSUME_NONNULL_BEGIN

@interface SampleBufferDisplayView : UIView
@property (nonatomic, weak) IBOutlet AgoraSampleBufferRender* videoView;
- (void)setPlaceHolder: (NSString*) text;
- (void)setInfo: (NSString*) text;
@end

NS_ASSUME_NONNULL_END
