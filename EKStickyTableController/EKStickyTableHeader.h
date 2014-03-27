//
//  EKStickyTableHeader.h
//  EKStickyTableController
//
//  Created by Eli Kohen Gomez on 21/03/14.
//  Copyright (c) 2014 Eli Kohen Gomez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EKStickyTableHeader : UIView

@property (nonatomic) BOOL trespassingEnabled;
@property (nonatomic,weak) UIView *belowView;
@property (nonatomic,weak) id delegate;

@end

@protocol EKStickyTableHeaderDelegate <NSObject>

@optional
- (void) onStickyHeaderTapped: (EKStickyTableHeader*) header;
- (void) onStickyHeader: (EKStickyTableHeader*) header trespassedOnPoint: (CGPoint) point withEvent: (UIEvent*) event;

@end
