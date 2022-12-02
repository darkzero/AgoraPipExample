//
//  ViewController.m
//  AgoraPipExample
//
//  Created by Yuhua Hu on 2022/12/01.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "LiveViewController.h"

@interface HomeViewController ()
@property (nonatomic, weak) IBOutlet UITextField* appIdField;
@property (nonatomic, weak) IBOutlet UITextField* tokenField;
@property (nonatomic, weak) IBOutlet UITextField* channelNameField;
@property (nonatomic, weak) IBOutlet UIButton* joinButton;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.appIdField.text = <#App id#>; // temp
}

- (IBAction)onStartButtonClicked: (id)sender {
    NSString* appId = self.appIdField.text;
    NSString* token = self.tokenField.text;
    NSString* channelName = self.channelNameField.text;
    NSLog(@"Join channel %@, use app id: %@ and token: %@", channelName, appId, token);
    
    if ( appId != nil && appId.length != 0 && channelName != nil && channelName.length != 0 ) {
        [self performSegueWithIdentifier: @"JoinChannel" sender: self];
    }
    else {
        NSLog(@"Please fill appid and channel name");
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    LiveViewController* liveVC = (LiveViewController*)[segue destinationViewController];
    NSString* appId = self.appIdField.text;
    NSString* channelName = self.channelNameField.text;
    NSLog(@"appid: %@, channel: %@", appId, channelName);
    
    liveVC.appId = appId;
    liveVC.channlName = channelName;
}

@end
