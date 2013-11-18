//
//  ViewController.m
//  STCollapseTableViewDemo
//
//  Created by Thomas Dupont on 09/08/13.
//  Copyright (c) 2013 iSofTom. All rights reserved.
//

#import "ViewController.h"

#import "STCollapseTableView.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, STCollapseTableViewSectionDelegate>

@property (weak, nonatomic) IBOutlet STCollapseTableView *tableView;

@property (nonatomic, strong) NSMutableArray* data;
@property (nonatomic, strong) NSMutableArray* headers;
@property (nonatomic, strong) NSArray*        colors;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setupViewController];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setupViewController];
    }
    return self;
}

- (void)setupViewController
{
    self.colors = @[[UIColor redColor],
                    [UIColor orangeColor],
                    [UIColor yellowColor],
                    [UIColor greenColor],
                    [UIColor blueColor],
                    [UIColor purpleColor]];
    
    self.data = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < [self.colors count] ; i++)
    {
        NSMutableArray* section = [[NSMutableArray alloc] init];
        for (int j = 0 ; j < 3 ; j++)
        {
            [section addObject:[NSString stringWithFormat:@"Cell n°%i", j]];
        }
        [self.data addObject:section];
    }
    
    self.headers = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < [self.colors count] ; i++)
    {
        UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        [header setBackgroundColor:[self.colors objectAtIndex:i]];
        [self.headers addObject:header];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.collapseSectionDelegate = self;
    [self.tableView reloadData];
    [self.tableView openSection:0 animated:NO];
}

- (IBAction)handleExclusiveButtonTap:(UIButton*)button
{
    [self.tableView setExclusiveSections:!self.tableView.exclusiveSections];
    
    [button setTitle:self.tableView.exclusiveSections?@"exclusive":@"!exclusive" forState:UIControlStateNormal];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.data count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString* cellIdentifier = @"cell";
	
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (!cell)
    {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
	}
	
	NSString* text = [[self.data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	cell.textLabel.text = text;
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[self.data objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self.headers objectAtIndex:section];
}

#pragma mark - STCollapseTableViewDelegate

-(void)didToggleSection:(NSUInteger)sectionIndex collapsed:(BOOL)collapsed
{
    UIView* headerView = [self.headers objectAtIndex:sectionIndex];
    
    if (collapsed)
    {
        headerView.backgroundColor = [self.colors objectAtIndex:sectionIndex];
    }
    else
    {
        headerView.backgroundColor = [UIColor grayColor];
    }
    
}

@end
