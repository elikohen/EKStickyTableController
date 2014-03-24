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
    BOOL mAnimatingTableInsets;
}

@property (nonatomic,strong) EKStickyTableProxyDelegate *mProxyDelegate;
@property (nonatomic,weak) UITableView *mTableView;
@property (nonatomic,weak) NSLayoutConstraint *mTableYPosConstraint;
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

- (void) setupOnTableView: (UITableView*) tableView withYPosConstraint: (NSLayoutConstraint*) yConstraint viewBelow: (UIView*) belowView parentView: (UIView*) view andDelegate:(id<EKStickyTableControllerDelegate>) delegate{
    self.mProxyDelegate = [EKStickyTableProxyDelegate new];
    self.mProxyDelegate.tableDelegate = tableView.delegate;
    self.mProxyDelegate.tableDataSource = tableView.dataSource;
    self.mProxyDelegate.controller = self;
    
    //TODO: SET KEY VALUE OBSERVER FOR tableView.delegate && tableView.dataSource
    
    self.delegate = delegate;
    
    self.mTableYPosConstraint = yConstraint;
    
    CGRect tableFrame = CGRectMake(0, 0, tableView.frame.size.width, self.collapsedHeaderHeight);
    self.mTableHeader = [[EKStickyTableHeader alloc] initWithFrame:tableFrame];
    self.mTableHeader.belowView = belowView;
    UIView *realHeader = tableView.tableHeaderView;
    if(realHeader){
        realHeader.frame = tableFrame;
        [self.mTableHeader addSubview:realHeader];
    }
    tableView.tableHeaderView = self.mTableHeader;
    
    [self tableBackgroundOriginWillChange:self.collapsedHeaderHeight withAnimationDuration:0.0];
    
    tableView.delegate = self.mProxyDelegate;
    tableView.dataSource = self.mProxyDelegate;
    self.mTableView = tableView;
    
    self.mParentView = view;
}

- (void) setDelegate:(id<EKStickyTableControllerDelegate>)delegate{
    _delegate = delegate;
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

- (void) tableBackgroundOriginWillChange: (CGFloat) position withAnimationDuration: (CGFloat) duration{
    if([self.delegate respondsToSelector:@selector(tableView:backgroundYoriginWillChange:withAnimationDuration:)]){
        [self.delegate tableView:self.mTableView backgroundYoriginWillChange:position withAnimationDuration:duration];
    }
}

#pragma mark - Private methods
- (BOOL) expanded{
    return mHeaderExpanded;
}

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
    
    mAnimatingTableInsets = YES;
    [self tableBackgroundOriginWillChange:newHeight withAnimationDuration:0.0];
    [UIView animateWithDuration:kCOLLAPSE_EXPAND_ANIMATION_DURATION animations:^{
        weakSelf.mTableView.contentInset = auxInset;
        [weakSelf.mParentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        weakSelf.mTableHeader.frame = hframe;
        weakSelf.mTableView.tableHeaderView = weakSelf.mTableHeader;
        weakSelf.mTableView.contentInset = tableInset;
        mAnimatingTableInsets = NO;
    }];
}

- (void) collapseHeader{
    if(!mHeaderExpanded) return;
    mHeaderExpanded = NO;
    
    CGFloat height = self.collapsedHeaderHeight;
    
    CGRect hframe = self.mTableHeader.frame;
    CGFloat deltaY = hframe.size.height - height;
    
    //Content offset to avoid table jumping when changing header height
    CGPoint offset = self.mTableView.contentOffset;
    offset.y -= deltaY;
    
    if(offset.y < 0){
        offset.y = 0;
        [self onHeaderHeightWillChange:height];
        
        __weak EKStickyTableController* weakSelf = self;
        
        [self.mParentView layoutIfNeeded];
        //content smaller than table height => move entire table
        if(self.mTableView.contentSize.height <= (self.mTableView.frame.size.height + self.listExpandThreshold)){
            
            [UIView animateWithDuration:kCOLLAPSE_EXPAND_ANIMATION_DURATION animations:^{
                weakSelf.mTableYPosConstraint.constant -= deltaY;
                [weakSelf.mParentView layoutIfNeeded];
            } completion:^(BOOL finished) {
                weakSelf.mTableYPosConstraint.constant += deltaY;
                [weakSelf applyTableOffset:offset andHeaderHeight:height];
                [weakSelf.mParentView layoutIfNeeded];
            }];
        }
        else{
            //First move table (scrolling) to the correct position, and then change header height to avoid table glitching
            [UIView animateWithDuration:kCOLLAPSE_EXPAND_ANIMATION_DURATION animations:^{
                CGRect scrollBounds = self.mTableView.bounds;
                scrollBounds.origin.y = deltaY;
                weakSelf.mTableView.bounds = scrollBounds;
                
            } completion:^(BOOL finished) {
                [weakSelf applyTableOffset:offset andHeaderHeight:height];
            }];
        }
    }
    else{
        [self onHeaderHeightWillChange:height];
        [self applyTableOffset:offset andHeaderHeight:height];
    }
}

- (void) applyTableOffset: (CGPoint) offset andHeaderHeight: (CGFloat) height{
    
    CGRect hframe = self.mTableHeader.frame;
    hframe.size.height = height;
    self.mTableHeader.frame = hframe;
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
    if(!mAnimatingTableInsets){
        if(baseHeight < 0){
            baseHeight = 0;
        }
        else if(baseHeight > self.mParentView.frame.size.height){
            baseHeight = self.mParentView.frame.size.height;
        }
        [self tableBackgroundOriginWillChange:baseHeight withAnimationDuration:0.0];
    }
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
    
    BOOL waitUntilDecelerate = (decelerate && scrollView.contentSize.height > (scrollView.frame.size.height + self.listExpandThreshold));
    if(mHeaderExpanded && !waitUntilDecelerate && scrollView.contentOffset.y > self.listExpandThreshold){
        [self collapseHeader];
    }
    else if(mHeaderExpanded && waitUntilDecelerate){
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
