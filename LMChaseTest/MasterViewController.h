//
//  MasterViewController.h
//  LMChaseTest
//
//  Created by laxman raju on 8/31/15.
//  Copyright (c) 2015 laxman raju. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *searchTextLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong, nonatomic) DetailViewController *detailViewController;



@end

