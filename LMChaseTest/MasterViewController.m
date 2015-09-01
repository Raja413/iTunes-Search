//
//  MasterViewController.m
//  LMChaseTest
//
//  Created by laxman raju on 8/31/15.
//  Copyright (c) 2015 laxman raju. All rights reserved.
//

#define initialMusicSearchURL @"https://itunes.apple.com/search?term=tom+waits"
#import "MasterViewController.h"
#import "DetailViewController.h"

@interface MasterViewController ()

@property NSMutableArray *objects;
@end

@implementation MasterViewController

@synthesize searchTextLabel = _searchTextLabel;


- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //show activity indication with spinner
    [self.spinner startAnimating];
    /*create the server call in another thread to keep main thread responsive to UI*/
    dispatch_queue_t other_Q = dispatch_queue_create("Q", NULL);
    dispatch_async(other_Q, ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:initialMusicSearchURL]];
        [self performSelector:@selector(fetchedData:) withObject:data];
    });
    
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

/*
 parse the json data
 clear the objects array
 fill the objects array with new data
 
 get the main thread to do the ui chnges (updating table view)
 */
- (void)fetchedData:(NSData *)responseData
{
    NSError *error = nil;
    if (responseData) {
        NSDictionary *jsonDataDict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        
        [self.objects removeAllObjects];
        self.objects = [NSMutableArray arrayWithArray:[jsonDataDict objectForKey:@"results"]];
       
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.spinner stopAnimating];
        });
        
    }
}

/*
 search button action
 */

- (IBAction)searchAction:(UIButton *)sender
{
    if (_searchTextLabel.text) {
        /* create a url string by replacing spaces with + */
        NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@",[_searchTextLabel.text stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
        
        dispatch_queue_t other_Q = dispatch_queue_create("Q", NULL);
        dispatch_async(other_Q, ^{
                           NSURL *url = [NSURL URLWithString:urlString];
                           NSData *jsonResults = [NSData dataWithContentsOfURL:url];
                           [self performSelector:@selector(fetchedData:) withObject:jsonResults];
        });
       
    }
    // to dismiss the keyboard
    [self.view endEditing:YES];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = self.objects[indexPath.row];
        DetailViewController * detail = (DetailViewController *) segue.destinationViewController;
        [detail setDetailItem:object];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    
    NSDictionary *itemDict = [NSDictionary dictionaryWithDictionary:[self.objects objectAtIndex:indexPath.row]];
   
    cell.textLabel.text = [itemDict objectForKey:@"trackName"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@-%@",[itemDict objectForKey:@"artistName"], [itemDict objectForKey:@"collectionName"]];
    
    NSURL *imageURL = [NSURL URLWithString:[itemDict objectForKey:@"artworkUrl30"]];
    NSData *imgData = [NSData dataWithContentsOfURL:imageURL];
    cell.imageView.frame = CGRectMake(0, 0, 80, 70);
    cell.imageView.image = [UIImage imageWithData:imgData];

    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
