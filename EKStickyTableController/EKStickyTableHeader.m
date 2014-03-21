//
//  EKStickyTableHeader.m
//  MapListDraft
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
    }
    return self;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if(point.y > self.frame.size.height){
        return nil;
    }
    return [self.belowView hitTest:point withEvent:event];
}

@end
