//
//  DragableButton.m
//  SmartOTA
//
//  Created by Jakey on 2017/8/8.
//  Copyright © 2017年 Jakey. All rights reserved.
//

#import "DragableButton.h"

@implementation DragableButton

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
- (void)awakeFromNib {
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSURLPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        if (files.count <= 0) {
            return NO;
        }
        if (_dragableButtonDragEnd) {
            _dragableButtonDragEnd(files);
        }
    }
    return YES;
}



#pragma mark - Destination Operations

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    _isDragIn = YES;
    [self setNeedsDisplay:YES];
    return NSDragOperationCopy;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    _isDragIn = NO;
    [self setNeedsDisplay:YES];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    _isDragIn = NO;
    [self setNeedsDisplay:YES];
    return YES;
}


-(void)dragableButtonDragEnd:(DragableButtonDragEnd)dragableButtonDragEnd{
    _dragableButtonDragEnd = [dragableButtonDragEnd copy];
}

@end
