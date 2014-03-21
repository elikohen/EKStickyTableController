//
//  EKStickyTableProxyDelegate.m
//  MapListDraft
//
//  Created by Eli Kohen Gomez on 21/03/14.
//  Copyright (c) 2014 Eli Kohen Gomez. All rights reserved.
//

#import "EKStickyTableProxyDelegate.h"

@implementation EKStickyTableProxyDelegate

+ (instancetype)new {
    return [[self alloc] init];
}

- (instancetype)init
{
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<EKStickyTableProxyDelegate: %p, realDelegate (%@): %p>", self, (self.realDelegate ? [self.realDelegate class] : @""), self.realDelegate];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    if (selector == @selector(scrollViewDidScroll:))
        return [[EKStickyTableProxyDelegate class] methodSignatureForSelector:selector];
    
    if (selector == @selector(scrollViewWillBeginDragging:))
        return [[EKStickyTableProxyDelegate class] methodSignatureForSelector:selector];
    
    if (selector == @selector(scrollViewDidEndDragging:willDecelerate:))
        return [[EKStickyTableProxyDelegate class] methodSignatureForSelector:selector];
    
    if (selector == @selector(scrollViewDidEndDecelerating:))
        return [[EKStickyTableProxyDelegate class] methodSignatureForSelector:selector];
    
    if ([self.realDelegate respondsToSelector:selector])
        return [(NSObject *)self.realDelegate methodSignatureForSelector:selector];
    
    return [[NSObject class] methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if (invocation.selector == @selector(respondsToSelector:))
    {
        [invocation invokeWithTarget:self];
    }
    else if ([self.realDelegate respondsToSelector:invocation.selector])
    {
        [invocation invokeWithTarget:self.realDelegate];
    }
}

- (BOOL)respondsToSelector:(SEL)selector
{
    if (selector == @selector(scrollViewDidScroll:))
        return YES;
    
    if (selector == @selector(scrollViewWillBeginDragging:))
        return YES;
    
    if (selector == @selector(scrollViewDidEndDragging:willDecelerate:))
        return YES;
    
    if (selector == @selector(scrollViewDidEndDecelerating:))
        return YES;
    
    return ([self.realDelegate respondsToSelector:selector]);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if([self.realDelegate respondsToSelector:@selector(scrollViewDidScroll:)]){
        [self.realDelegate scrollViewDidScroll:scrollView];
    }
    
    [self.controller scrollViewDidScroll:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if([self.realDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]){
        [self.realDelegate scrollViewWillBeginDragging:scrollView];
    }
    
    [self.controller scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if([self.realDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]){
        [self.realDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    
    [self.controller scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if([self.realDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]){
        [self.realDelegate scrollViewDidEndDecelerating:scrollView];
    }
    
    [self.controller scrollViewDidEndDecelerating:scrollView];
}



@end
