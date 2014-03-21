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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBackgroundYPosition;


@property (strong, nonatomic) EKStickyTableController *mStickyTableController;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.mStickyTableController = [[EKStickyTableController alloc] init];
    [self.mStickyTableController setupOnTableView:self.tableView withViewBelow:self.mapView parentView:self.view andDelegate:self];
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

- (void) tableView: (UITableView*) tableView backgroundYoriginDidChange: (CGFloat) yOrigin{
    NSLog(@"==== backgroundYoriginDidChange ====> %f", yOrigin);
    self.tableBackgroundYPosition.constant = yOrigin;
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