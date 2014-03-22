//
//  EKStickyTableController.h
//  EKStickyTableController
//
//  Created by Eli Kohen Gomez on 21/03/14.
//  Copyright (c) 2014 Eli Kohen Gomez. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_COLLAPSED_HEADER_HEIGHT 150.0
#define DEFAULT_EXPANDED_HEADER_VISIBLE_LIST_HEIGHT 100.0
#define DEFAULT_LIST_EXPAND_THRESHOLD 50.0f

@protocol EKStickyTableControllerDelegate <UITableViewDataSource,UITableViewDelegate>

@optional
- (void) onHeaderHeightWillChange: (CGFloat) height;
- (void) onHeaderHeightIsStretched: (CGFloat) height;
- (void) tableView: (UITableView*) tableView backgroundYoriginWillChange: (CGFloat) yOrigin withAnimationDuration: (CGFloat) duration;

@end

@interface EKStickyTableController : NSObject <UIScrollViewDelegate>

@property (nonatomic) CGFloat collapsedHeaderHeight;
@property (nonatomic) CGFloat expandedHeaderVisibleListHeigh;
@property (nonatomic) CGFloat listExpandThreshold;
@property (nonatomic, weak) id<EKStickyTableControllerDelegate> delegate;

- (void) setupOnTableView: (UITableView*) tableView withYPosConstraint: (NSLayoutConstraint*) yConstraint viewBelow: (UIView*) belowView parentView: (UIView*) view andDelegate:(id<EKStickyTableControllerDelegate>) delegate;

@end

