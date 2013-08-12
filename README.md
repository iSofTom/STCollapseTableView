STCollapseTableView
===============

A UITableView subclass that automatically collapse and/or expand your sections.

You just have to fill your datasource like for a classic UITableView and the magic will happen.

## How to use it ?

By default all the sections are closed, so no rows will be displayed !
But you have now access to several new table view methods:

```
- (void)openSection:(NSUInteger)sectionIndex animated:(BOOL)animated;
- (void)closeSection:(NSUInteger)sectionIndex animated:(BOOL)animated;
- (void)toggleSection:(NSUInteger)sectionIndex animated:(BOOL)animated;
- (BOOL)isOpenSection:(NSUInteger)sectionIndex;
```
As their names suggests, those methods allows to open or close a section and can be animated or not. The last one returns a boolean to know if a section is currently open.

so if you want the first section to be open after your view is loaded, you could write:

```
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView reloadData];
    [self.tableView openSection:0 animated:NO];
}
```

By default if you open a section, any other that is open will automatically be closed.
This can be prevented by setting this property to NO:

```
@property (nonatomic, assign) BOOL exclusiveSections;
```

As you might have seen, your headers automatically toggle theirs section on a tap !
This is automatically done for you in three conditions:
* Your datasource implements the `tableView:heightForHeaderInSection:` method
* The returned views haven't any UITapGestureRecognizer.
* the STCollapseTableView property `shouldHandleHeadersTap` is YES (which is the default value).

## Installation

To include this component in your project, I recommend you to use [Cocoapods](http://cocoapods.org):
* Add `pod "STCollapseTableView"` to your Podfile.

## How does it work ?

Here is an article about how this component works : [Forwarding Mechanism](http://www.isoftom.com/2013/08/forwarding-mechanism.html).
