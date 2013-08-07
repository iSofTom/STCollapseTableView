//
//  STRollTableView.m
//  STRollTableView
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

#import "STRollTableView.h"

@interface STRollTableView () <UITableViewDataSource>

@property (nonatomic, strong) id<UITableViewDataSource> rollingDataSource;
@property (nonatomic, strong) NSMutableArray* sectionsStates;

@end

@implementation STRollTableView

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
    {
		[self setup];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
    {
		[self setup];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
	self = [super initWithFrame:frame style:style];
	if (self)
    {
		[self setup];
	}
	return self;
}

- (void)setup
{
	self.exclusiveSections = YES;
	self.sectionsStates = [[NSMutableArray alloc] init];
}

- (void)setDataSource:(id <UITableViewDataSource>)newDataSource
{
	if (newDataSource != self.rollingDataSource)
    {
		self.rollingDataSource = newDataSource;
		[self.sectionsStates removeAllObjects];
		[super setDataSource:self.rollingDataSource?self:nil];
	}
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
	if ([self.rollingDataSource respondsToSelector:aSelector])
    {
		return self.rollingDataSource;
	}
	return nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	return [super respondsToSelector:aSelector] || [self.rollingDataSource respondsToSelector:aSelector];
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
		[self setSectionAtIndex:sectionIndex open:YES];
		
		NSArray* indexPathsToInsert = [self indexPathsForRowsInSectionAtIndex:sectionIndex];
		
		UITableViewRowAnimation insertAnimation = UITableViewRowAnimationTop;
		
		[self insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
		
	}
}

- (void)closeSection:(NSUInteger)sectionIndex animated:(BOOL)animated
{
    [self setSectionAtIndex:sectionIndex open:NO];
	
	NSArray* indexPathsToDelete = [self indexPathsForRowsInSectionAtIndex:sectionIndex];
	
	[self deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
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

- (BOOL)isOpenedSection:(NSUInteger)sectionIndex
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
	return [self.rollingDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([[self.sectionsStates objectAtIndex:section] boolValue])
    {
		return [self.rollingDataSource tableView:tableView numberOfRowsInSection:section];
	}
	return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	int nbSection = [self.rollingDataSource numberOfSectionsInTableView:tableView];
    
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

#pragma mark - Private methods

- (NSArray*)indexPathsForRowsInSectionAtIndex:(NSUInteger)sectionIndex
{
	if (sectionIndex >= [self.sectionsStates count])
    {
		return nil;
	}
	
	NSInteger numberOfRows = [self.rollingDataSource tableView:self numberOfRowsInSection:sectionIndex];
	
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
