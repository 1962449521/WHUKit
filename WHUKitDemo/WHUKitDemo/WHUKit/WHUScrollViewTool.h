//
//  WHUScrollViewTool.h
//  WHUKitDemo
//
//  Created by 胡 帅 on 16/4/1.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHUScrollViewTool : NSObject

+ (void) scrollView:(UIScrollView *)scrollView appendStickyHeaderView:(UIView *)stickyHeaderView;

+ (void) scrollView:(UIScrollView *)scrollView appendStickyFooterView:(UIView *)stickyFooterView;

+ (void) scrollView:(UIScrollView *)scrollView appendTreasureView:(UIView *)treasureView;

+ (void) scrollView:(UIScrollView *)scrollView appendNoDataView:(UIView *)noDataView;

@end
