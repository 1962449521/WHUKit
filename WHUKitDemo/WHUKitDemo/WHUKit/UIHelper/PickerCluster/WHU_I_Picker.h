//
//  WHU_I_Picker.h
//  WHUKitDemo
//
//  Created by 胡 帅 on 16/4/9.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WHU_I_Picker <NSObject>

@property (nonatomic, strong) NSArray<NSNumber *>* selectedIndexList;

- (void) showInView:(UIView *)superview WithCover:(BOOL) isHaveCover;

- (void) dismiss:(BOOL)animated;

- (void) layoutPickerDidDisplay;

- (void) PickerWillDisplay;

@optional
@property (nonatomic, readonly) NSUInteger selectedIndex;

- (void) showAtPoint:(CGPoint)point

@end

@protocol WHUPickerDataSource <NSObject>

@required

- (NSInteger) Picker:(id<WHU_I_Picker>)Picker numberOfRowsInColumn:(NSInteger)column;


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;              // Default is 1 if not implemented

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;


- (NSUInteger) columnsOfPicker;

- (NSUInteger) width4CloumnAt

@end

@protocol WHUPickerDelegate <NSObject>

<#methods#>

@end