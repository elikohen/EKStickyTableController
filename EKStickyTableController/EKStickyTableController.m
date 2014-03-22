//
//  EKStickyTableController.m
//  EKStickyTableController
//
//  Created by Eli Kohen Gomez on 21/03/14.
//  Copyright (c) 2014 Eli Kohen Gomez. All rights reserved.
//

#import "EKStickyTableController.h"
#import "EKStickyTableProxyDelegate.h"
#import "EKStickyTableHeader.h"

#define kCOLLAPSE_EXPAND_ANIMATION_DURATION 0.3

@interface EKStickyTableController (){
    BOOL mHeaderExpanded;
    BOOL mWaitUntilDecelerated;
    BOOL mDragging;
}

@property (nonatomic,strong) EKStickyTableProxyDelegate *mProxyDelegate;
@property (nonatomic,weak) UITableView *mTableView;
@property (nonatomic,weak) UIView *mParentView;
@property (nonatomic,strong) EKStickyTableHeader *mTableHeader;

@end

@implementation EKStickyTableController

- (instancetype) init{
    self = [super init];
    if(self){
        self.collapsedHeaderHeight = DEFAULT_COLLAPSED_HEADER_HEIGHT;
        self.expandedHeaderVisibleListHeigh = DEFAULT_EXPANDED_HEADER_VISIBLE_LIST_HEIGHT;
        self.listExpandThreshold = DEFAULT_LIST_EXPAND_THRESHOLD;
    }
    return self;
}

- (void) setupOnTableView: (UITableView*) tableView withViewBelow: (UIView*) belowView parentView: (UIView*) view andDelegate:(id<EKStickyTableControllerDelegate>) delegate{
    self.mProxyDelegate = [EKStickyTableProxyDelegate new];
    self.mProxyDelegate.realDelegate = delegate;
    self.mProxyDelegate.controller = self;
    
    self.delegate = delegate;
    
    CGRect tableFrame = CGRectMake(0, 0, tableView.frame.size.width, self.collapsedHeaderHeight);
    self.mTableHeader = [[EKStickyTableHeader alloc] initWithFrame:tableFrame];
    self.mTableHeader.belowView = belowView;
    UIView *realHeader = tableView.tableHeaderView;
    if(realHeader){
        realHeader.frame = tableFrame;
        [self.mTableHeader addSubview:realHeader];
    }
    tableView.tableHeaderView = self.mTableHeader;
    
    [self tableBackgroundOriginDidChange:self.collapsedHeaderHeight];
    
    tableView.delegate = self.mProxyDelegate;
    tableView.dataSource = self.mProxyDelegate;
    self.mTableView = tableView;
    
    self.mParentView = view;
}

- (void) setDelegate:(id<EKStickyTableControllerDelegate>)delegate{
    _delegate = delegate;
    [self.mProxyDelegate setRealDelegate:delegate];
}

#pragma mark - delegate methods

- (void) onHeaderHeightWillChange: (CGFloat) height{
    if([self.delegate respondsToSelector:@selector(onHeaderHeightWillChange:)]){
        [self.delegate onHeaderHeightWillChange:height];
    }
}

- (void) onHeaderHeightIsStretched: (CGFloat) height{
    if([self.delegate respondsToSelector:@selector(onHeaderHeightIsStretched:)]){
        [self.delegate onHeaderHeightIsStretched:height];
    }
}

- (void) tableBackgroundOriginDidChange: (CGFloat) position{
    if([self.delegate respondsToSelector:@selector(tableView:backgroundYoriginDidChange:)]){
        [self.delegate tableView:self.mTableView backgroundYoriginDidChange:position];
    }
}

#pragma mark - Private methods
- (void) expandHeader{
    if(mHeaderExpanded) return;
    mHeaderExpanded = YES;
    
    CGFloat newHeight = self.mParentView.frame.size.height - self.expandedHeaderVisibleListHeigh;
    
    //List header height
    CGRect hframe = self.mTableHeader.frame;
    CGFloat oldHeight = hframe.size.height;
    hframe.size.height = newHeight;
    
    [self onHeaderHeightWillChange:newHeight];
    
    //Animate changes
    __weak EKStickyTableController *weakSelf = self;
    
    UIEdgeInsets tableInset = self.mTableView.contentInset;
    UIEdgeInsets auxInset = self.mTableView.contentInset;
    auxInset.top += newHeight - oldHeight;
    
    [UIView animateWithDuration:kCOLLAPSE_EXPAND_ANIMATION_DURATION animations:^{
        weakSelf.mTableView.contentInset = auxInset;
    } completion:^(BOOL finished) {
        weakSelf.mTableHeader.frame = hframe;
        weakSelf.mTableView.tableHeaderView = weakSelf.mTableHeader;
        weakSelf.mTableView.contentInset = tableInset;
    }];
}

- (void) collapseHeader{
    if(!mHeaderExpanded) return;
    mHeaderExpanded = NO;
    
    CGFloat height = self.collapsedHeaderHeight;
    
    CGRect hframe = self.mTableHeader.frame;
    CGFloat deltaY = hframe.size.height - height;
    hframe.size.height = height;
    self.mTableHeader.frame = hframe;
    
    //Content offset to avoid table jumping when changing header height
    CGPoint offset = self.mTableView.contentOffset;
    offset.y -= deltaY;
    
    if(offset.y < 0){
        offset.y = 0;
        [self onHeaderHeightWillChange:height];
        
        //First move table (scrolling) to the correct position, and then change header height to avoid table glitching
        __weak EKStickyTableController* weakSelf = self;
        [UIView animateWithDuration:kCOLLAPSE_EXPAND_ANIMATION_DURATION animations:^{
            CGRect scrollBounds = self.mTableView.bounds;
            scrollBounds.origin.y = deltaY;
            weakSelf.mTableView.bounds = scrollBounds;
            
        } completion:^(BOOL finished) {
            [self applyTableOffset:offset andHeaderHeight:height];
        }];
    }
    else{
        [self onHeaderHeightWillChange:height];
        [self applyTableOffset:offset andHeaderHeight:height];
    }
}

- (void) applyTableOffset: (CGPoint) offset andHeaderHeight: (CGFloat) height{
    
    self.mTableView.tableHeaderView = self.mTableHeader;
    if(mDragging){
        CGRect scrollBounds = self.mTableView.bounds;
        scrollBounds.origin = offset;
        self.mTableView.bounds = scrollBounds;
    }
    else{
        [self.mTableView setContentOffset:offset animated:NO];
    }
    
    [self.mParentView layoutIfNeeded];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat baseHeight = mHeaderExpanded ? self.mParentView.frame.size.height - self.expandedHeaderVisibleListHeigh - scrollView.contentOffset.y : self.collapsedHeaderHeight - scrollView.contentOffset.y;
    
    //Just when user pulls down over de offset
    if(scrollView.contentOffset.y < 0){
        [self onHeaderHeightIsStretched:baseHeight];
    }
    
    //Move list background to avoid showing map below table
    if(baseHeight < 0){
        baseHeight = 0;
    }
    else if(baseHeight > self.mParentView.frame.size.height){
        baseHeight = self.mParentView.frame.size.height;
    }
    [self tableBackgroundOriginDidChange:baseHeight];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    mDragging = YES;
    [self onScrollViewFinishedState:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    mDragging = NO;
    
    if(!mHeaderExpanded && scrollView.contentOffset.y < -self.listExpandThreshold){
        [self expandHeader];
    }
    
    if(mHeaderExpanded && !decelerate && scrollView.contentOffset.y > self.listExpandThreshold){
        [self collapseHeader];
    }
    else if(mHeaderExpanded && decelerate){
        mWaitUntilDecelerated = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self onScrollViewFinishedState:scrollView];
}

- (void)onScrollViewFinishedState: (UIScrollView*) scrollView{
    if(mWaitUntilDecelerated && mHeaderExpanded && scrollView.contentOffset.y > self.listExpandThreshold){
        [self collapseHeader];
    }
    mWaitUntilDecelerated = NO;
}

@end
