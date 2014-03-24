//
//  EKStickyTableProxyDelegate.h
//  EKStickyTableController
//
//  Created by Eli Kohen Gomez on 21/03/14.
//  Copyright (c) 2014 Eli Kohen Gomez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EKStickyTableController.h"

@class EKStickyTableController;

@interface EKStickyTableProxyDelegate : NSProxy <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) id <UITableViewDelegate>tableDelegate;
@property (nonatomic, weak) id <UITableViewDataSource>tableDataSource;
@property (nonatomic, weak) EKStickyTableController *controller;

+ (instancetype)new;

- (instancetype)init;

@end
