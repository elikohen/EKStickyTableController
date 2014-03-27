//
//  EKStickyTableHeader.m
//  EKStickyTableController
//
//  Created by Eli Kohen Gomez on 21/03/14.
//  Copyright (c) 2014 Eli Kohen Gomez. All rights reserved.
//

#import "EKStickyTableHeader.h"

@implementation EKStickyTableHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupTouchTap];
    }
    return self;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if(!self.trespassingEnabled){
        return [super hitTest:point withEvent:event];
    }
    
    if(point.y > self.frame.size.height){
        return nil;
    }
    
    if([self.delegate respondsToSelector:@selector(onStickyHeader:trespassedOnPoint:withEvent:)]){
        [self.delegate onStickyHeader:self trespassedOnPoint:point withEvent:event];
    }
    return [self.belowView hitTest:point withEvent:event];
}

#pragma mark - Private methods

- (void) setupTouchTap{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHeaderTapped:)];
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
}

- (void) onHeaderTapped: (id) sender{
    if([self.delegate respondsToSelector:@selector(onStickyHeaderTapped:)]){
        [self.delegate onStickyHeaderTapped:self];
    }
}

@end
