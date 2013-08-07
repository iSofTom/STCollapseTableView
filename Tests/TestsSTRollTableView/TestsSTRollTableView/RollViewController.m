//
//  ViewController.m
//  TestsSTRollTableView
//
//  Created by Thomas Dupont on 07/08/13.
//  Copyright (c) 2013 iSofTom. All rights reserved.
//

#import "RollViewController.h"

#import "STRollTableView.h"

@interface RollViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet STRollTableView *tableView;

@property (nonatomic, strong) NSMutableArray* data;
@property (nonatomic, strong) NSMutableArray* headers;

@end

@implementation RollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setupRollViewController];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setupRollViewController];
    }
    return self;
}

- (void)setupRollViewController
{
    NSArray* colors = @[[UIColor purpleColor],
                        [UIColor blueColor],
                        [UIColor greenColor],
                        [UIColor yellowColor],
                        [UIColor orangeColor]];
    
    self.data = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < [colors count] ; i++)
    {
        NSMutableArray* section = [[NSMutableArray alloc] init];
        
        for (int j = 0 ; j < 3 ; j++)
        {
            [section addObject:[NSString stringWithFormat:@"Cell n°%i", j]];
        }
        
        [self.data addObject:section];
    }
    
    self.headers = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < [colors count] ; i++)
    {
        UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        [header setBackgroundColor:[colors objectAtIndex:i]];
        [header setTag:i];
        [header addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleHeaderTap:)]];
        [header addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleHeaderLongPress:)]];
        [self.headers addObject:header];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView openSection:0 animated:NO];
    });
    
}

- (IBAction)handleExclusiveButtonTap:(id)sender
{
    [self.tableView setExclusiveSections:!self.tableView.exclusiveSections];
}

- (IBAction)handleEditButtonTap:(id)sender
{
    
}

- (void)handleHeaderTap:(UITapGestureRecognizer*)tap
{
    [self.tableView toggleSection:tap.view.tag animated:YES];
}

- (void)handleHeaderLongPress:(UILongPressGestureRecognizer*)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        NSInteger index = longPress.view.tag;
        
        if (index >= 0 && index < [self.data count])
        {
            [[self.data objectAtIndex:index] insertObject:@"New cell" atIndex:0];
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        }
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[self.data objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
}

@end
