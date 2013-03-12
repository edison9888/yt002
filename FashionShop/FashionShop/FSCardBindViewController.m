//
//  FSCardBindViewController.m
//  FashionShop
//
//  Created by HeQingshan on 13-3-11.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSCardBindViewController.h"
#import "UIViewController+Loading.h"
#import "FSCardRequest.h"
#import "FSCardInfo.h"

@interface FSCardBindViewController ()

@end

@implementation FSCardBindViewController
@synthesize currentUser;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateTitle];
    UIBarButtonItem *baritemCancel = [self createPlainBarButtonItem:@"goback_icon.png" target:self action:@selector(onButtonBack:)];
    [self.navigationItem setLeftBarButtonItem:baritemCancel];
    self.view.backgroundColor = APP_BACKGROUND_COLOR;
    [self prepareView];
    _cardNumField.text = @"4367455100790570";
    _cardPwField.text = @"090027";
}

-(void)updateTitle
{
    if ([currentUser.isBindCard boolValue]) {
        self.title = NSLocalizedString(@"Card Info Query", nil);
    }
    else {
        self.title = NSLocalizedString(@"Bind Card", nil);
    }
}

-(void)prepareView
{
    if (![currentUser.isBindCard boolValue]) {
        _bindView.hidden = NO;
        _resultView.hidden = YES;
        _bindView.layer.cornerRadius = 10;
        _bindView.layer.borderWidth = 1;
        _bindView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        CGRect _rect = _bindView.frame;
        _rect.origin.y = 15;
        _bindView.frame = _rect;
    }
    else {
        _bindView.hidden = YES;
        _resultView.hidden = YES;
        _resultView.layer.cornerRadius = 10;
        _resultView.layer.borderWidth = 1;
        _resultView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        CGRect _rect = _resultView.frame;
        _rect.origin.y = 15;
        _resultView.frame = _rect;
        
        if (currentUser.cardInfo) {
            [self updateResultView:currentUser.cardInfo];
        }
        else{
            FSCardRequest *request = [[FSCardRequest alloc] init];
            request.userToken = currentUser.uToken;
            request.routeResourcePath = RK_REQUEST_USER_CARD_DETAIL;
            [self beginLoading:self.view];
            [request send:[FSCardInfo class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
                if (!resp.isSuccess)
                {
                    [self reportError:resp.description];
                }
                else
                {
                    [self reportError:resp.message];
                    //显示绑定成功界面
                    _cardNumField.text = @"";
                    _cardPwField.text = @"";
                    currentUser.isBindCard = @YES;
                    [self updateResultView:resp.responseData];
                    [self updateTitle];
                    [self prepareView];
                }
                [self endLoading:self.view];
            }];
        }
    }
}

- (IBAction)onButtonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setBindView:nil];
    [self setResultView:nil];
    [self setCardNumField:nil];
    [self setCardPwField:nil];
    [self setCardLevel:nil];
    [self setCardNum:nil];
    [self setCardPoint:nil];
    [super viewDidUnload];
}

- (IBAction)bindCard:(id)sender {
    if ([self checkInput])
    {
        FSCardRequest *request = [[FSCardRequest alloc] init];
        request.userToken = currentUser.uToken;
        request.cardNo = _cardNumField.text;
        request.passWord = _cardPwField.text;
        request.routeResourcePath = RK_REQUEST_USER_CARD_BIND;
        [self beginLoading:self.view];
        [request send:[FSCardInfo class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
            if (!resp.isSuccess)
            {
                [self reportError:resp.description];
            }
            else
            {
                [self reportError:resp.message];
                //显示绑定成功界面
                _cardNumField.text = @"";
                _cardPwField.text = @"";
                currentUser.isBindCard = @YES;
                [self updateResultView:resp.responseData];
                [self updateTitle];
                [self prepareView];
            }
            [self endLoading:self.view];
        }];
    }
}

-(void)updateResultView:(FSCardInfo*)_cardInfo
{
    _bindView.hidden = YES;
    _resultView.hidden = NO;
    _cardLevel.text = [NSString stringWithFormat:@"%@-%@", _cardInfo.type, _cardInfo.cardLevel];
    _cardNum.text = _cardInfo.cardNo;
    _cardPoint.text = [NSString stringWithFormat:@"%@", _cardInfo.amount];
    currentUser.cardInfo = _cardInfo;
}

-(BOOL) checkInput
{
    return YES;
}

- (IBAction)unBindCard:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warm prompt",nil) message:NSLocalizedString(@"Prompt Of UnBindCard", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [alert show];
}

#pragma UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        FSCardRequest *request = [[FSCardRequest alloc] init];
        request.userToken = currentUser.uToken;
        request.routeResourcePath = RK_REQUEST_USER_CARD_UNBIND;
        [self beginLoading:self.view];
        [request send:[FSModelBase class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
            if (!resp.isSuccess)
            {
                [self reportError:resp.description];
            }
            else
            {
                [self reportError:resp.message];
                //显示绑定界面
                currentUser.isBindCard = @NO;
                [self updateTitle];
                [self prepareView];
            }
            [self endLoading:self.view];
        }];
    }
}

@end