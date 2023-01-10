//
//  SampleBufferDisplayView.m
//  AgoraPipExample
//
//  Created by Yuhua Hu on 2022/12/01.
//

#import "SampleBufferDisplayView.h"
#import "AgoraSampleBufferRender.h"

@interface SampleBufferDisplayView ()
@property (nonatomic, weak) IBOutlet UILabel* placeHolderLabel;
@property (nonatomic, weak) IBOutlet UILabel* infoLabel;
@end

@implementation SampleBufferDisplayView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setPlaceHolder: (NSString*) text {
    self.placeHolderLabel.text = text;
}

- (void)setInfo: (NSString*) text {
    self.infoLabel.text = text;
}

@end
