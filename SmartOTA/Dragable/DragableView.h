//
//  DragableView.h
//  Disguise
//
//  Created by Jakey on 2017/6/26.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
typedef void (^DragableViewDragEnd)(NSArray *files);

@interface DragableView : NSView
{
    DragableViewDragEnd _dragableViewDragEnd;
    BOOL _isDragIn;
}
-(void)dragableViewDragEnd:(DragableViewDragEnd)dragableViewDragEnd;
@end
