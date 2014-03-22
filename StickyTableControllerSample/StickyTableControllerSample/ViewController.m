//
//  ViewController.m
//  StickyTableControllerSample
//
//  Created by Eli Kohen Gomez on 21/03/14.
//  Copyright (c) 2014 Eli Kohen Gomez. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>


@interface ViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *tableViewBackground;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBackgroundYPosition;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableTopConstraint;


@property (strong, nonatomic) EKStickyTableController *mStickyTableController;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.mStickyTableController = [[EKStickyTableController alloc] init];
    [self.mStickyTableController setupOnTableView:self.tableView withYPosConstraint:self.tableTopConstraint viewBelow:self.mapView parentView:self.view andDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - EKStickyTableControllerDelegate

- (void) onHeaderHeightWillChange: (CGFloat) height{
    NSLog(@"==== onHeaderHeightWillChange ====> %f", height);
}

- (void) onHeaderHeightIsStretched: (CGFloat) height{
    NSLog(@"==== onHeaderHeightIsStretched ====> %f", height);
}

- (void) tableView: (UITableView*) tableView backgroundYoriginWillChange: (CGFloat) yOrigin withAnimationDuration: (CGFloat) duration{
    NSLog(@"==== backgroundYoriginDidChange ====> %f, %f", yOrigin,duration);
    if(duration > 0.0){
        self.tableBackgroundYPosition.constant = yOrigin;
        __weak ViewController *weakSelf = self;
        [UIView animateWithDuration:duration animations:^{
            [weakSelf.view layoutIfNeeded];
        }];
    }
    else{
        self.tableBackgroundYPosition.constant = yOrigin;
        [self.view layoutIfNeeded];
    }
}
#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellName = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Cell number: %d", indexPath.row];
    
    return cell;
}

@end
