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

///更新选中状态,key为component,value为row
- (void)updateSelectionWithComponentRowMap:(NSDictionary<NSNumber *, NSNumber *> *)componentRowMap;

/// 选择完成描述分隔符，默认为"-"
@property (nonatomic, copy) NSString *descriptionSeparator;

/// 点击完成按钮点击处理
@property (nonatomic, copy) void (^doneBarButtonTapHandler) (WLPickerView *pickerView, NSDictionary<NSNumber *, NSNumber *> *selectedComponentRowMap,NSString *selectionDescription);

///取消按钮点击处理
@property (nonatomic, copy) void (^cancelBarButtonTapHandler) (WLPickerView *pickerView) ;

@end
