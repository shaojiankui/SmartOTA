//
//  DragableWindow.h
//  SmartOTA
//
//  Created by Jakey on 2017/8/4.
//  Copyright © 2017年 Jakey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
typedef void(^DragableWindowMouseDragged)(id info);
@interface DragableWindow : NSWindow
{
    DragableWindowMouseDragged _dragableWindowMouseDragged;
}
- (void)dragableWindowMouseDragged:(DragableWindowMouseDragged)dragableWindowMouseDragged;
@end
