//
//  EKStickyTableProxyDelegate.m
//  EKStickyTableController
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
    return [NSString stringWithFormat:@"<EKStickyTableProxyDelegate: %p, realDelegate (%@): %p>", self, (self.tableDelegate ? [self.tableDelegate class] : @""), self.tableDelegate];
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
    
    if ([self.tableDelegate respondsToSelector:selector])
        return [(NSObject *)self.tableDelegate methodSignatureForSelector:selector];
    if ([self.tableDataSource respondsToSelector:selector])
        return [(NSObject *)self.tableDataSource methodSignatureForSelector:selector];
    return [[NSObject class] methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if (invocation.selector == @selector(respondsToSelector:))
    {
        [invocation invokeWithTarget:self];
    }
    else if ([self.tableDelegate respondsToSelector:invocation.selector])
    {
        [invocation invokeWithTarget:self.tableDelegate];
    }
    else if ([self.tableDataSource respondsToSelector:invocation.selector])
    {
        [invocation invokeWithTarget:self.tableDataSource];
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
    
    return ([self.tableDelegate respondsToSelector:selector] || [self.tableDataSource respondsToSelector:selector]);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if([self.tableDelegate respondsToSelector:@selector(scrollViewDidScroll:)]){
        [self.tableDelegate scrollViewDidScroll:scrollView];
    }
    
    [self.controller scrollViewDidScroll:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if([self.tableDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]){
        [self.tableDelegate scrollViewWillBeginDragging:scrollView];
    }
    
    [self.controller scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if([self.tableDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]){
        [self.tableDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    
    [self.controller scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if([self.tableDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]){
        [self.tableDelegate scrollViewDidEndDecelerating:scrollView];
    }
    
    [self.controller scrollViewDidEndDecelerating:scrollView];
}



@end
