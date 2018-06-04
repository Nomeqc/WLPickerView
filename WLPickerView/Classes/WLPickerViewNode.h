//
//  WLPickerViewNode.h
//  WLPickerView_Example
//
//  Created by Fallrainy on 2018/6/3.
//  Copyright © 2018年 nomeqc@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLPickerViewNode : NSObject

@property (nonatomic,copy) NSDictionary *userInfo;

@property (nonatomic, copy) NSString *nodeName;

@property (nonatomic, copy) NSArray<WLPickerViewNode *> *childNodes;

@end
