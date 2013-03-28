//
//  FSProPostTitleViewController.h
//  FashionShop
//
//  Created by gong yi on 12/1/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCommonProRequest.h"
#import "TDSemiModalViewController.h"
#import "FSPlaceHoldTextView.h"

typedef enum {
    StartRecord = 1,
    Recording,
    StopRecording,
    WaitPlay,
}RecordState;

@protocol FSProPostTitleViewControllerDelegate;

@interface FSProPostTitleViewController : TDSemiModalViewController<UITextFieldDelegate,UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UITextField *txtTitle;

@property (strong, nonatomic) IBOutlet UILabel *lblDescName;
@property (strong, nonatomic) IBOutlet FSPlaceHoldTextView *txtDesc;

@property (strong, nonatomic) IBOutlet UILabel *lblDescVoice;
@property (strong, nonatomic) IBOutlet UIButton *btnRecord;

@property (strong, nonatomic) IBOutlet UILabel *lblPrice;
@property (strong, nonatomic) IBOutlet UITextField *txtPrice;

@property (strong, nonatomic) IBOutlet UILabel *lbProDesc;
@property (strong, nonatomic) IBOutlet UITextField *txtProDesc;

@property (strong, nonatomic) IBOutlet UILabel *lbProTime;
@property (strong, nonatomic) IBOutlet UITextField *txtProStartTime;
@property (strong, nonatomic) IBOutlet UITextField *txtProEndTime;

- (IBAction)doSave:(id)sender;
- (IBAction)doCancel:(id)sender;
- (IBAction)selDuration:(id)sender;

- (IBAction)recordTouchDown:(id)sender;
- (IBAction)recordTouchUpInside:(id)sender;
- (IBAction)recordTouchUpOutside:(id)sender;

@property (strong,nonatomic) id delegate;
@property (nonatomic) FSSourceType publishSource;
@property (strong, nonatomic) NSString *recordFileName;

@end

@interface NSObject (FSProPostTitleViewControllerDelegate)
-(void)titleViewControllerSetTitle:(FSProPostTitleViewController*)viewController;
-(void)titleViewControllerCancel:(FSProPostTitleViewController*)viewController;
@end