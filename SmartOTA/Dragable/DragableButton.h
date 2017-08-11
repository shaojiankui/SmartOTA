//
//  DragableButton.h
//  SmartOTA
//
//  Created by Jakey on 2017/8/8.
//  Copyright © 2017年 Jakey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
typedef void (^DragableButtonDragEnd)(NSArray *files);

@interface DragableButton : NSButton
{
    DragableButtonDragEnd _dragableButtonDragEnd;
    BOOL _isDragIn;
}
-(void)dragableButtonDragEnd:(DragableButtonDragEnd)dragableButtonDragEnd;
@end
