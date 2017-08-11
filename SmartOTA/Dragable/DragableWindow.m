//
//  DragableWindow.m
//  SmartOTA
//
//  Created by Jakey on 2017/8/4.
//  Copyright © 2017年 Jakey. All rights reserved.
//

#import "DragableWindow.h"

@implementation DragableWindow
-(void)mouseDragged:(NSEvent *)event{
    [super mouseDragged:event];
    if (_dragableWindowMouseDragged) {
        _dragableWindowMouseDragged(event);
    }
}


- (void)dragableWindowMouseDragged:(DragableWindowMouseDragged)dragableWindowMouseDragged{
    _dragableWindowMouseDragged = [dragableWindowMouseDragged copy];
}
@end
