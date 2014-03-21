//
//  EKStickyTableProxyDelegate.h
//  MapListDraft
//
//  Created by Eli Kohen Gomez on 21/03/14.
//  Copyright (c) 2014 Eli Kohen Gomez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EKStickyTableController.h"

@class EKStickyTableController;

@interface EKStickyTableProxyDelegate : NSProxy <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) id <UITableViewDelegate,UITableViewDataSource>realDelegate;
@property (nonatomic, weak) EKStickyTableController *controller;

+ (instancetype)new;

- (instancetype)init;

@end
