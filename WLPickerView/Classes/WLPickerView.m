//
//  WLPickerView.m
//  WLPickerView_Example
//
//  Created by Fallrainy on 2018/6/3.
//  Copyright © 2018年 nomeqc@gmail.com. All rights reserved.
//

#import "WLPickerView.h"

@interface WLPickerView ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, copy) NSArray<WLPickerViewNode *> *nodes;

@property (nonatomic) UIToolbar *toolBar;
@property (nonatomic) UIPickerView *pickerView;

@property (nonatomic) NSMutableDictionary<NSNumber *, NSNumber *> *selectedRowIndexMap;

@end

static CGFloat const kPickerViewHeight = 215.f;
static CGFloat const kToolBarViewHeight = 44.f;

@implementation WLPickerView

- (instancetype)initWithNodes:(NSArray<WLPickerViewNode *> *)nodes {
    self = [super init];
    if (!self) {
        return nil;
    }
    _nodes = [nodes copy];
    _columnCount = 3;
    _descriptionSeparator = @"-";
    UIToolbar *toolBar = ({
        UIToolbar *view = [[UIToolbar alloc] init];
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(didTapCancelBarButton:)];
        UIBarButtonItem *spaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(didTapDoneBarButton:)];
        [view setItems:@[cancelBarButtonItem,
                         spaceBarButtonItem,
                         doneBarButtonItem]];
        view;
    });
    UIPickerView *pickerView = ({
        UIPickerView *view = [[UIPickerView alloc] init];
        view.delegate = self;
        view.dataSource = self;
        view;
    });
    [self addSubview:toolBar];
    [self addSubview:pickerView];
    _toolBar = toolBar;
    _pickerView = pickerView;
    
    _selectedRowIndexMap = [NSMutableDictionary dictionary];
    [pickerView reloadAllComponents];
    
    return self;
}

- (void)updateSelectionWithComponentRowMap:(NSDictionary<NSNumber *,NSNumber *> *)componentRowMap {
    [self.selectedRowIndexMap removeAllObjects];
    for (NSInteger i = 0; i < self.columnCount; i ++) {
       NSInteger row = [componentRowMap[@(i)] integerValue];
        [self setSelectedRow:row forComponent:i];
        [self.pickerView selectRow:row inComponent:i animated:NO];
        [self.pickerView reloadComponent:i];
    }
}

// MARK: Button Event Handler
- (void)didTapCancelBarButton:(UIBarButtonItem *)barButtonItem {
    if (self.cancelBarButtonTapHandler) {
        self.cancelBarButtonTapHandler(self);
    }
}

- (void)didTapDoneBarButton:(UIBarButtonItem *)barButtonItem {
    if (self.doneBarButtonTapHandler) {
        NSMutableArray<NSString *> *selectedNodeNames = [NSMutableArray array];
        for (NSInteger i = 0; i < self.columnCount; i++) {
            NSInteger selectedRow = [self selectedRowInComponent:i];
            WLPickerViewNode *node = [self nodeForRow:selectedRow forComponent:i];
            if (node.nodeName.length > 0) {
                [selectedNodeNames addObject:node.nodeName];
            }
        }
        
        self.doneBarButtonTapHandler(self,[self.selectedRowIndexMap copy],[selectedNodeNames componentsJoinedByString:self.descriptionSeparator]);
    }
}

// MARK: UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (self.nodes.count == 0) {
        return 0;
    }
    return self.columnCount;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.nodes.count;
    }
    WLPickerViewNode *parentNode = nil;
    for (NSInteger i = 0; i < component; i++) {
        NSInteger selectedRow = [self selectedRowInComponent:i];
        parentNode = [self nodeForRow:selectedRow forComponent:i];
    }
    return parentNode.childNodes.count;
}

// MARK: UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return [self componentWidth];
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *titleLabel = (UILabel *)view;
    if (!titleLabel) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [self componentWidth], 30)];
    }
    WLPickerViewNode *node = [self nodeForRow:row forComponent:component];
    titleLabel.text = node.nodeName;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    return titleLabel;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    /*
        检查记录的列选中的行是否和实际情况一致 如果不一致，将后续的列默认选中第一个，并刷新
     */
    for (NSInteger i = 0; i < self.columnCount; i++) {
        NSInteger selectedRow = [self selectedRowInComponent:i];
        if (selectedRow != [pickerView selectedRowInComponent:i]) {
            selectedRow = [pickerView selectedRowInComponent:i];
            [self setSelectedRow:selectedRow forComponent:i];
            //当前列行索引有变动，刷新所有后续的列
            for (NSInteger j = i + 1; j < self.columnCount; j++) {
                [self setSelectedRow:0 forComponent:j];
                [pickerView selectRow:0 inComponent:j animated:NO];
                [pickerView reloadComponent:j];
            }
            [pickerView setNeedsLayout];
            [pickerView layoutIfNeeded];
            return;
        }
    }
    [pickerView setNeedsLayout];
    [pickerView layoutIfNeeded];
}

// MARK: Helper

- (WLPickerViewNode *)nodeForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return self.nodes[row];
    }
    NSInteger rootSelectedRowIndex = [self selectedRowInComponent:0];
    WLPickerViewNode *node = self.nodes[rootSelectedRowIndex];
    for (NSInteger i = 1; i < component; i++) {
        NSInteger selectedRow = [self selectedRowInComponent:i];
        node = node.childNodes[selectedRow];
    }
    return node.childNodes[row];
}


- (NSInteger)selectedRowInComponent:(NSInteger)component {
    return  [self.selectedRowIndexMap[@(component)] integerValue];
}

- (void)setSelectedRow:(NSInteger)row forComponent:(NSInteger)component {
    self.selectedRowIndexMap[@(component)] = @(row);
}

- (CGFloat)componentWidth {
    return CGRectGetWidth(self.bounds) / self.columnCount - 10;
}

// MARK: @Override
- (void)setFrame:(CGRect)frame {
    frame = ({
        CGRect rect = frame;
        rect.size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), kPickerViewHeight + kToolBarViewHeight);
        rect;
    });
    [super setFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _toolBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), kToolBarViewHeight);
    _pickerView.frame = CGRectMake(0, kToolBarViewHeight, CGRectGetWidth(self.bounds), kPickerViewHeight);
}

@end
