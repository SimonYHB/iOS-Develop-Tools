//
//  YECallRecordCell.h
//  IOSDevelopTools
//
//  Created by 叶煌斌 on 2020/3/11.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YECallRecordModel;
@class YECallRecordCell;

@protocol YECallRecordCellDelegate <NSObject>

- (void)recordCell:(YECallRecordCell *)cell clickExpandWithSection:(NSInteger)section;

@end

@interface YECallRecordCell : UITableViewCell

@property (nonatomic, weak)id<YECallRecordCellDelegate> delegate;

- (void)bindRecordModel:(YECallRecordModel *)model isHiddenExpandBtn:(BOOL)isHidden isExpand:(BOOL)isExpand section:(NSInteger)section isCallCountType:(BOOL)isCallCountType;

@end

NS_ASSUME_NONNULL_END
