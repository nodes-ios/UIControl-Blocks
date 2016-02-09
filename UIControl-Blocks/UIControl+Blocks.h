//
//  UIControl+blocks.h
//  UIControl block actions
//
//  Created by Kasper Welner on 8/29/12.
//  Copyright (c) 2012 Nodes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (Blocks)

typedef void (^ ControlBlock)(__weak id weakself, __weak UIControl *sender);

- (void)addBlock:(ControlBlock)block forControlEvents:(UIControlEvents)eventType selfRef:(id)sender;

- (void)addBlock:(ControlBlock)block withID:(int)ID forControlEvents:(UIControlEvents)eventType selfRef:(id)sender;

- (void)removeBlocksForControlEvents:(UIControlEvents)eventType;

- (void)removeBlockWithID:(int)ID;

@end

