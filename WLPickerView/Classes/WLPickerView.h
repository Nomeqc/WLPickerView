//
//  WLPickerView.h
//  WLPickerView_Example
//
//  Created by Fallrainy on 2018/6/3.
//  Copyright © 2018年 nomeqc@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLPickerViewNode.h"

@interface WLPickerView : UIView

- (instancetype)initWithNodes:(NSArray<WLPickerViewNode *> *)nodes;

/// 列总数，默认为3
@property (nonatomic) NSUInteger columnCount;

///是否记住上次的选择，默认为YES
@property (nonatomic) BOOL rememberLastPick;

///更列对应选中的行的索引
- (void)updateSelectionWithRowIndexes:(NSArray<NSNumber *> *)indexes;

/// 选择完成描述分隔符，默认为"-"
@property (nonatomic, copy) NSString *descriptionSeparator;

@property (nonatomic, copy) void (^doneBarButtonTapHandler) (WLPickerView *pickerView, NSArray<NSNumber *> *selectedRowIndexes, NSString *selectionDescription);

///取消按钮点击处理
@property (nonatomic, copy) void (^cancelBarButtonTapHandler) (WLPickerView *pickerView) ;

@end
