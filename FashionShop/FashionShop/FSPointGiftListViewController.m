//
//  FSPointGiftListViewController.m
//  FashionShop
//
//  Created by HeQingshan on 13-4-28.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSPointGiftListViewController.h"
#import "FSPointGiftDetailViewController.h"
#import "FSPointGiftListCell.h"
#import "FSCommonUserRequest.h"
#import "FSExchangeRequest.h"
#import "FSPagedExchangeList.h"
#import "FSExchange.h"

#define Point_Gift_List_Cell_Indentifier @"PointGiftListCell"

@interface FSPointGiftListViewController ()
{
    FSGiftSortBy _currentSelIndex;
    
    NSMutableArray *_dataSourceList;
    NSMutableArray *_noMoreList;
    NSMutableArray *_pageIndexList;
    NSMutableArray *_refreshTimeList;
    BOOL _inLoading;
}

@end

@implementation FSPointGiftListViewController

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
    self.title = NSLocalizedString(@"Point Exchange List", nil);
    UIBarButtonItem *baritemCancel = [self createPlainBarButtonItem:@"goback_icon.png" target:self action:@selector(onButtonBack:)];
    [self.navigationItem setLeftBarButtonItem:baritemCancel];
    
    [self requestData];
    [self initArray];
    [self setFilterType];
    
    _currentSelIndex = SortByUnUsed;
    _contentView.backgroundView = nil;
    _contentView.backgroundColor = APP_TABLE_BG_COLOR;
    
    [self prepareRefreshLayout:_contentView withRefreshAction:^(dispatch_block_t action) {
        if (_inLoading)
        {
            action();
            return;
        }
        int currentPage = [_pageIndexList objectAtIndex:_currentSelIndex];
        [self setPageIndex:currentPage selectedSegmentIndex:_segFilters.selectedSegmentIndex];
        FSExchangeRequest *request = [self createRequest:currentPage];
        _inLoading = YES;
        [request send:[FSPagedExchangeList class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
            _inLoading = NO;
            action();
            if (resp.isSuccess)
            {
                FSPagedExchangeList *innerResp = resp.responseData;
                if (innerResp.totalPageCount <= currentPage)
                    [self setNoMore:YES selectedSegmentIndex:_segFilters.selectedSegmentIndex];
                [self mergeLike:innerResp isInsert:NO];
                
                [self setRefreshTime:[NSDate date] selectedSegmentIndex:_segFilters.selectedSegmentIndex];
            }
            else
            {
                [self reportError:resp.errorDescrip];
            }
        }];
    }];
}

- (IBAction)onButtonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) setFilterType
{
    [_segFilters removeAllSegments];
    [_segFilters insertSegmentWithTitle:NSLocalizedString(@"ExchangeList_UnUsed", nil) atIndex:0 animated:FALSE];
    [_segFilters insertSegmentWithTitle:NSLocalizedString(@"ExchangeList_Used", nil) atIndex:1 animated:FALSE];
    [_segFilters insertSegmentWithTitle:NSLocalizedString(@"ExchangeList_Disable", nil) atIndex:2 animated:FALSE];
    [_segFilters addTarget:self action:@selector(filterSearch:) forControlEvents:UIControlEventValueChanged];
    _segFilters.selectedSegmentIndex = 0;
}

-(void)initArray
{
    _dataSourceList = [@[] mutableCopy];
    _pageIndexList = [@[] mutableCopy];
    _noMoreList = [@[] mutableCopy];
    _refreshTimeList = [@[] mutableCopy];
    
    for (int i = 0; i < 3; i++) {
        [_dataSourceList insertObject:[@[] mutableCopy] atIndex:i];
        [_pageIndexList insertObject:@1 atIndex:i];
        [_noMoreList insertObject:@NO atIndex:i];
        [_refreshTimeList insertObject:[NSDate date] atIndex:i];
    }
}

-(void)filterSearch:(UISegmentedControl *) segmentedControl
{
    int index = segmentedControl.selectedSegmentIndex;
    if(_currentSelIndex == index)
    {
        return;
    }
    _currentSelIndex = index;
    NSMutableArray *source = [_dataSourceList objectAtIndex:index];
    if (source == nil || source.count<=0)
    {
        [self requestData];
    }
    [_contentView reloadData];
    [_contentView setContentOffset:CGPointZero];
}

-(void)setPageIndex:(int)_index selectedSegmentIndex:(NSInteger)_selIndexSegment
{
    NSNumber * nsNum = [NSNumber numberWithInt:_index];
    [_pageIndexList replaceObjectAtIndex:_selIndexSegment withObject:nsNum];
}

-(void)setNoMore:(BOOL)_more selectedSegmentIndex:(NSInteger)_selIndexSegment
{
    NSNumber * nsNum = [NSNumber numberWithBool:_more];
    [_noMoreList replaceObjectAtIndex:_selIndexSegment withObject:nsNum];
}

-(void)setRefreshTime:(NSDate*)_date selectedSegmentIndex:(NSInteger)_selIndexSegment
{
    [_refreshTimeList replaceObjectAtIndex:_selIndexSegment withObject:_date];
}

-(void) requestData
{
    int currentPage = [_pageIndexList objectAtIndex:_currentSelIndex];
    [self setPageIndex:currentPage selectedSegmentIndex:_segFilters.selectedSegmentIndex];
    FSExchangeRequest *request = [self createRequest:currentPage];
    [self beginLoading:self.view];
    [request send:[FSPagedExchangeList class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
        [self endLoading:self.view];
        if (resp.isSuccess)
        {
            FSPagedExchangeList *innerResp = resp.responseData;
            if (innerResp.totalPageCount <= currentPage)
                [self setNoMore:YES selectedSegmentIndex:_currentSelIndex];
            [self mergeLike:innerResp isInsert:NO];
            
            [self setRefreshTime:[NSDate date] selectedSegmentIndex:_currentSelIndex];
        }
        else
        {
            [self reportError:resp.errorDescrip];
        }
    }];
}

-(void) mergeLike:(FSPagedExchangeList *)response isInsert:(BOOL)isinsert
{
    NSMutableArray *_likes = _dataSourceList[_currentSelIndex];
    if (response && response.items)
    {
        [response.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            int index = [_likes indexOfObjectPassingTest:^BOOL(id obj1, NSUInteger idx1, BOOL *stop1) {
                if ([[(FSExchange *)obj1 valueForKey:@"id"] isEqualToValue:[(FSExchange *)obj valueForKey:@"id" ]])
                {
                    return TRUE;
                    *stop1 = TRUE;
                }
                return FALSE;
            }];
            if (index == NSNotFound)
            {
                if (isinsert)
                    [_likes insertObject:obj atIndex:0];
                else
                    [_likes addObject:obj];
            }
        }];
        [_contentView reloadData];
    }
    if (_likes.count<1)
    {
        //加载空视图
        [self showNoResultImage:_contentView withImage:@"blank_me_fans.png" withText:NSLocalizedString(@"TipInfo_Coupon_List", nil)  originOffset:30];
    }
    else
    {
        [self hideNoResultImage:_contentView];
    }
}

-(FSExchangeRequest *)createRequest:(int)index
{
    FSExchangeRequest *request = [[FSExchangeRequest alloc] init];
    request.userToken =[FSModelManager sharedModelManager].loginToken;
    request.pageSize = [NSNumber numberWithInt:COMMON_PAGE_SIZE];
    request.nextPage = [_pageIndexList objectAtIndex:_currentSelIndex];
    request.type = @1;
    request.userToken = [FSUser localProfile].uToken;
    request.routeResourcePath = RK_REQUEST_STOREPROMOTION_COUPON_LIST;
    return request;
}

- (void)viewDidUnload {
    [self setContentView:nil];
    [self setSegFilters:nil];
    [super viewDidUnload];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSMutableArray *_likes = _dataSourceList[_currentSelIndex];
    return _likes?_likes.count:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPointGiftListCell *cell = (FSPointGiftListCell*)[tableView dequeueReusableCellWithIdentifier:Point_Gift_List_Cell_Indentifier];
    if (cell == nil) {
        NSArray *_array = [[NSBundle mainBundle] loadNibNamed:@"FSPointGiftListCell" owner:self options:nil];
        if (_array.count > 0) {
            cell = (FSPointGiftListCell*)_array[0];
        }
        else{
            cell = [[FSPointGiftListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Point_Gift_List_Cell_Indentifier];
        }
    }
    [cell setData:nil];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPointGiftDetailViewController *controller = [[FSPointGiftDetailViewController alloc] initWithNibName:@"FSPointGiftDetailViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPointGiftListCell *cell = (FSPointGiftListCell*)[tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.cellHeight;
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    BOOL _noMore = [[_noMoreList objectAtIndex:_currentSelIndex] boolValue];
    if(!_inLoading
       && (scrollView.contentOffset.y+scrollView.frame.size.height) + 150 > scrollView.contentSize.height
       &&scrollView.contentOffset.y>0
       && !_noMore)
    {
        _inLoading = TRUE;
        int currentPage = [_pageIndexList objectAtIndex:_currentSelIndex];
        FSExchangeRequest *request = [self createRequest:currentPage+1];
        [request send:[FSPagedExchangeList class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
            _inLoading = FALSE;
            if (resp.isSuccess)
            {
                FSPagedExchangeList *innerResp = resp.responseData;
                if (innerResp.totalPageCount<=currentPage+1)
                    [self setNoMore:YES selectedSegmentIndex:_segFilters.selectedSegmentIndex];
                [self setPageIndex:currentPage+1 selectedSegmentIndex:_segFilters.selectedSegmentIndex];
                [self mergeLike:innerResp isInsert:NO];
            }
            else
            {
                [self reportError:resp.errorDescrip];
            }
        }];
    }
}

@end
