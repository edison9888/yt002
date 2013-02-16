//
//  FSPostTableSelViewController.m
//  FashionShop
//
//  Created by gong yi on 12/13/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSPostTableSelViewController.h"
#import "UIViewController+Loading.h"
#import "FSGroupBrand.h"

@interface FSPostTableSelViewController ()
{
    NSMutableArray *_data;
    NSMutableArray *_nameList;
    PostTableDataSource _delegate;
    PostProgressStep _currentStep;
    id _target;
}



@end

@implementation FSPostTableSelViewController

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
    [self prepareData];
    [self presentControl];
}

-(void) setDataSource:(PostTableDataSource)source step:(PostProgressStep)current selectedCallbackTarget:(id)target
{
    _delegate = source;
    _currentStep = current;
    _target = target;
}

-(void) prepareData
{
    if (_delegate) {
        _data = _delegate();
        if (_currentStep == PostStep4Finished) {
            _nameList = [[NSMutableArray alloc] initWithCapacity:2];
            for (FSGroupBrand *item in _data) {
                [_nameList addObject:item.groupName];
            }
        }
    }
}

-(void) presentControl
{
    [self replaceBackItem];
    _tbContent.delegate = self;
    _tbContent.dataSource = self;
}

#pragma UITableViewSource delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_currentStep == PostStep4Finished) {
        return _data?_data.count:0;
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_currentStep == PostStep4Finished) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        headView.backgroundColor = [UIColor blackColor];
        headView.alpha = 0.6;
        UILabel *_lb = [[UILabel alloc] initWithFrame:CGRectInset(headView.frame, 10, 0)];
        _lb.backgroundColor = [UIColor clearColor];
        _lb.font = ME_FONT(15);
        if (_data.count > 0 && section < _data.count) {
            FSGroupBrand *_item =[_data objectAtIndex:section];
            _lb.text = _item.groupName;
        }
        [headView addSubview:_lb];
        return headView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_currentStep == PostStep4Finished) {
        return 30;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_currentStep == PostStep4Finished) {
        if (_data.count > 0 && section < _data.count) {
            FSGroupBrand *_item =[_data objectAtIndex:section];
            return _item?_item.groupList.count:0;
        }
        return 0;
    }
    return _data?_data.count:0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *detailCell =  [tableView dequeueReusableCellWithIdentifier:@"defaultcell"];
    if (!detailCell)
    {
        detailCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultcell"];
    }
    if (_currentStep == PostStep4Finished) {
        if (_data.count > 0 && indexPath.section < _data.count) {
            FSGroupBrand *_item =[_data objectAtIndex:indexPath.section];
            id rowData = [_item.groupList objectAtIndex:indexPath.row];
            if ([rowData respondsToSelector:@selector(name)]) {
                detailCell.textLabel.text = [rowData name];
                detailCell.textLabel.font = ME_FONT(14);
            }
            return detailCell;
        }
    }
    id rowData = [_data objectAtIndex:indexPath.row];
    if ([rowData respondsToSelector:@selector(name)]) {
        detailCell.textLabel.text = [rowData name];
        detailCell.textLabel.font = ME_FONT(14);
    }
    return detailCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_currentStep == PostStep4Finished) {
        if (_data.count > 0 && indexPath.section < _data.count) {
            FSGroupBrand *_item =[_data objectAtIndex:indexPath.section];
            if ([_target respondsToSelector:@selector(proPostStep:didCompleteWithObject:)])
                [ _target proPostStep:_currentStep didCompleteWithObject:[_item.groupList objectAtIndex:indexPath.row]];
            [self.navigationController popViewControllerAnimated:TRUE];
            return;
        }
    }
    if ([_target respondsToSelector:@selector(proPostStep:didCompleteWithObject:)])
       [ _target proPostStep:_currentStep didCompleteWithObject:[_data objectAtIndex:indexPath.row]];
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (_currentStep == PostStep4Finished) {
        return _nameList;
    }
    return nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
