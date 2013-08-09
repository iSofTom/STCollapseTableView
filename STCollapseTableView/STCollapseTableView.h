//
//  STCollapseTableView.h
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

#import <UIKit/UIKit.h>

/**
 *	STCollapseTableView is a UITableView subclass that automatically collapse and/or expand your sections.
 *
 *  Just fill your datasource like for any table view and the magic will happen.
 *  By default all the sections are closed.
 */
@interface STCollapseTableView : UITableView

/**
 *	This property allow to enable/disable the exclusivity.
 *  If YES, only one section is allowed to be open.
 *  Default value is YES.
 */
@property (nonatomic, assign) BOOL exclusiveSections;

/**
 *	This property allows STCollapseTableView to automatically handle tap on headers in order to collapse or expand sections.
 *  If NO, you'll have to manually call the open or close methods if you want any content to be displayed.
 *  Default value is YES.
 */
@property (nonatomic, assign) BOOL shouldHandleHeadersTap;

/**
 *	This method will display the section whose index is in parameters
 *  If exclusiveSections boolean is YES, this method will close any open section.
 *
 *	@param	sectionIndex	The section you want to show.
 *	@param	animated	YES if you want the opening to be animated.
 */
- (void)openSection:(NSUInteger)sectionIndex animated:(BOOL)animated;

/**
 *	This method will close the section whose index is in parameters.
 *
 *	@param	sectionIndex	The section you want to close.
 *	@param	animated	YES if you want the closing to be animated.
 */
- (void)closeSection:(NSUInteger)sectionIndex animated:(BOOL)animated;

/**
 *	The will open or close the section whose index is in parameters regarding of its current state.
 *
 *	@param	sectionIndex	The section you want to toggle the visibility.
 *	@param	animated	YES if you want the toggle to be animated.
 */
- (void)toggleSection:(NSUInteger)sectionIndex animated:(BOOL)animated;

/**
 *	This methods will return YES if the section whose index is in parameters is open.
 *
 *	@param	sectionIndex	The section you want to knwo its visibility.
 *
 *	@return	YES if the section is open.
 */
- (BOOL)isOpenSection:(NSUInteger)sectionIndex;

@end
