STRollTableView
===============

A UITableView subclass that automatically handle opening and closing of the sections.

You just have to fill your datasource like for a classic UITableView, the only thing you have to do to take advantage of the new features is to not forget to use a STRollTableView instead of a UITableView!

## How to

By default all the sections are closed, so no rows will be displayed !
But you have now access to several new table view methods:

```
- (void)openSection:(NSUInteger)sectionIndex animated:(BOOL)animated;
- (void)closeSection:(NSUInteger)sectionIndex animated:(BOOL)animated;
- (void)toggleSection:(NSUInteger)sectionIndex animated:(BOOL)animated;
- (BOOL)isOpenSection:(NSUInteger)sectionIndex;
```
As their names suggests, those methods allows to open or close a section and can be animated or not. The last one returns a boolean to know if a section is currently open.

By default if you open a section, any other that is open will be automatically closed.
This can be prevented by setting this property to NO:

```
@property (nonatomic, assign) BOOL exclusiveSections;
```