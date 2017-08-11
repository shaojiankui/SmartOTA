//
//  DragableView.m
//  Disguise
//
//  Created by Jakey on 2017/6/26.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import "DragableView.h"

@implementation DragableView
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
        if (_dragableViewDragEnd) {
            _dragableViewDragEnd(files);
        }
    }
    return YES;
}


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if (_isDragIn)
    {
        NSColor* color = [NSColor colorWithRed:210.0 / 255 green:210.0 / 255 blue:210.0 / 255 alpha:1.0];
        [color set];
        NSBezierPath* thePath = [NSBezierPath bezierPath];
        [thePath appendBezierPathWithRoundedRect:dirtyRect xRadius:8.0 yRadius:8.0];
        [thePath fill];
    }
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

-(void)dragableViewDragEnd:(DragableViewDragEnd)dragableViewDragEnd{
    _dragableViewDragEnd = [dragableViewDragEnd copy];
}

@end
