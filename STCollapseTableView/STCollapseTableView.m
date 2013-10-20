//
//  STCollapseTableView.m
//  STCollapseTableView
//
//  Created by Thomas Dupont on 07/08/13.

/***********************************************************************************
 *
 * Copyright (c) 2013 Thomas Dupont
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 ***********************************************************************************/

#import "STCollapseTableView.h"

#import <objc/runtime.h>

@interface STCollapseTableView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id<UITableViewDataSource> collapseDataSource;
@property (nonatomic, assign) id<UITableViewDelegate> collapseDelegate;
@property (nonatomic, strong) NSMutableArray* sectionsStates;

@end

@implementation STCollapseTableView

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
    {
		[self setupCollapseTableView];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
    {
		[self setupCollapseTableView];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
	self = [super initWithFrame:frame style:style];
	if (self)
    {
		[self setupCollapseTableView];
	}
	return self;
}

- (void)setupCollapseTableView
{
	self.exclusiveSections = YES;
    self.shouldHandleHeadersTap = YES;
	self.sectionsStates = [[NSMutableArray alloc] init];
}

- (void)setDataSource:(id <UITableViewDataSource>)newDataSource
{
	if (newDataSource != self.collapseDataSource)
    {
		self.collapseDataSource = newDataSource;
		[self.sectionsStates removeAllObjects];
		[super setDataSource:self.collapseDataSource?self:nil];
	}
}

- (void)setDelegate:(id<UITableViewDelegate>)newDelegate
{
    if (newDelegate != self.collapseDelegate)
    {
        self.collapseDelegate = newDelegate;
        [super setDelegate:self.collapseDelegate?self:nil];
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
	if ([self.collapseDataSource respondsToSelector:aSelector])
    {
		return self.collapseDataSource;
	}
    if ([self.collapseDelegate respondsToSelector:aSelector])
    {
        return self.collapseDelegate;
    }
	return nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if (sel_isEqual(aSelector, @selector(tableView:viewForHeaderInSection:)))
    {
        return [self.collapseDelegate respondsToSelector:aSelector];
    }
    
	return [super respondsToSelector:aSelector] || [self.collapseDataSource respondsToSelector:aSelector] || [self.collapseDelegate respondsToSelector:aSelector];
}

- (void)openSection:(NSUInteger)sectionIndex animated:(BOOL)animated
{
    if (sectionIndex >= [self.sectionsStates count])
    {
        return;
    }
    
    if ([[self.sectionsStates objectAtIndex:sectionIndex] boolValue])
    {
        return;
    }
	
	if (self.exclusiveSections)
    {
        NSUInteger openedSection = [self openedSection];
        
		[self setSectionAtIndex:sectionIndex open:YES];
		[self setSectionAtIndex:openedSection open:NO];
        
        if(animated)
		{
            NSArray* indexPathsToInsert = [self indexPathsForRowsInSectionAtIndex:sectionIndex];
            NSArray* indexPathsToDelete = [self indexPathsForRowsInSectionAtIndex:openedSection];
            
            UITableViewRowAnimation insertAnimation;
            UITableViewRowAnimation deleteAnimation;
            
            if (openedSection == NSNotFound || sectionIndex < openedSection)
            {
                insertAnimation = UITableViewRowAnimationTop;
                deleteAnimation = UITableViewRowAnimationBottom;
            }
            else
            {
                insertAnimation = UITableViewRowAnimationBottom;
                deleteAnimation = UITableViewRowAnimationTop;
            }
            
            [self beginUpdates];
            [self insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
            [self deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:deleteAnimation];
            [self endUpdates];
        }
        else
        {
            [self reloadData];
        }
	}
    else
    {
		[self setSectionAtIndex:sectionIndex open:YES];
		
		if (animated)
        {
            NSArray* indexPathsToInsert = [self indexPathsForRowsInSectionAtIndex:sectionIndex];
            [self insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationTop];
        }
        else
        {
            [self reloadData];
        }
	}
}

- (void)closeSection:(NSUInteger)sectionIndex animated:(BOOL)animated
{
    [self setSectionAtIndex:sectionIndex open:NO];
	
	if (animated)
    {
        NSArray* indexPathsToDelete = [self indexPathsForRowsInSectionAtIndex:sectionIndex];
        [self deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
    }
    else
    {
        [self reloadData];
    }
}

- (void)toggleSection:(NSUInteger)sectionIndex animated:(BOOL)animated
{
    if (sectionIndex >= [self.sectionsStates count])
    {
		return;
	}
	
	BOOL sectionIsOpen = [[self.sectionsStates objectAtIndex:sectionIndex] boolValue];
	
	if (sectionIsOpen)
    {
		[self closeSection:sectionIndex animated:animated];
	}
    else
    {
		[self openSection:sectionIndex animated:animated];
	}
}

- (BOOL)isOpenSection:(NSUInteger)sectionIndex
{
    if (sectionIndex >= [self.sectionsStates count])
    {
		return NO;
	}
	return [[self.sectionsStates objectAtIndex:sectionIndex] boolValue];
}

- (void)setExclusiveSections:(BOOL)exclusiveSections
{
    _exclusiveSections = exclusiveSections;
    
    if (self.exclusiveSections)
    {
        NSInteger firstSection = NSNotFound;
        
        for (NSUInteger index = 0 ; index < [self.sectionsStates count] ; index++)
        {
            if ([[self.sectionsStates objectAtIndex:index] boolValue])
            {
                if (firstSection == NSNotFound)
                {
                    firstSection = index;
                }
                else
                {
                    [self closeSection:index animated:YES];
                }
            }
        }
    }
}

#pragma mark - DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self.collapseDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([[self.sectionsStates objectAtIndex:section] boolValue])
    {
		return [self.collapseDataSource tableView:tableView numberOfRowsInSection:section];
	}
	return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	int nbSection = [self.collapseDataSource numberOfSectionsInTableView:tableView];
    
	while (nbSection < [self.sectionsStates count])
    {
		[self.sectionsStates removeLastObject];
	}
    
	while (nbSection > [self.sectionsStates count])
    {
		[self.sectionsStates addObject:@NO];
	}
    
	return nbSection;
}

#pragma mark - Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* view = [self.collapseDelegate tableView:tableView viewForHeaderInSection:section];
    
    if (self.shouldHandleHeadersTap)
    {
        NSArray* gestures = view.gestureRecognizers;
        BOOL tapGestureFound = NO;
        for (UIGestureRecognizer* gesture in gestures)
        {
            if ([gesture isKindOfClass:[UITapGestureRecognizer class]])
            {
                tapGestureFound = YES;
                break;
            }
        }
        
        if (!tapGestureFound)
        {
            [view setTag:section];
            [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
        }
    }
    
    return view;
}

#pragma mark - Private methods

- (void)handleTapGesture:(UITapGestureRecognizer*)tap
{
    NSInteger index = tap.view.tag;
    if (index >= 0)
    {
        [self toggleSection:(NSUInteger)index animated:YES];
    }
}

- (NSArray*)indexPathsForRowsInSectionAtIndex:(NSUInteger)sectionIndex
{
	if (sectionIndex >= [self.sectionsStates count])
    {
		return nil;
	}
	
	NSInteger numberOfRows = [self.collapseDataSource tableView:self numberOfRowsInSection:sectionIndex];
	
	NSMutableArray* array = [[NSMutableArray alloc] init];
	
	for (int i = 0 ; i < numberOfRows ; i++)
    {
		[array addObject:[NSIndexPath indexPathForRow:i inSection:sectionIndex]];
	}
    
    return array;
}

- (void)setSectionAtIndex:(NSUInteger)sectionIndex open:(BOOL)open
{
	if (sectionIndex >= [self.sectionsStates count])
    {
		return;
	}
	
	[self.sectionsStates replaceObjectAtIndex:sectionIndex withObject:@(open)];
}

- (NSUInteger)openedSection
{
    if (!self.exclusiveSections)
    {
        return NSNotFound;
    }
    
    for (NSUInteger index = 0 ; index < [self.sectionsStates count] ; index++)
    {
        if ([[self.sectionsStates objectAtIndex:index] boolValue])
        {
            return index;
        }
    }
    
    return NSNotFound;
}

@end
