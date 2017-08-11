//
//  BRDrawer.m
//  TestDrawer
//
//  Created by Yang on 3/23/16.
//  Copyright © 2016 sgyang. All rights reserved.
//

#import "BRDrawer.h"
@import Quartz;

NSString * const BRDrawerWillOpenNotification = @"BRDrawerWillOpenNotification";
NSString * const BRDrawerDidOpenNotification = @"BRDrawerDidOpenNotification";
NSString * const BRDrawerWillCloseNotification = @"BRDrawerWillCloseNotification";
NSString * const BRDrawerDidCloseNotification = @"BRDrawerDidCloseNotification";

@interface BRDrawerWindow : NSWindow
+ (instancetype)defaultWindow;
@end

@interface BRDrawer () <NSAnimationDelegate>

@end

@implementation BRDrawer
{
    BRDrawerWindow * _contentWindow;
    NSAnimation * _animation;
    BOOL _windowsPrepared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.preferredEdge = NSMinYEdge;
        _state = BRDrawerClosedState;
        _contentWindow = [BRDrawerWindow defaultWindow];
        self.contentSize = NSMakeSize(100, 100);
        self.animateDuration = 1.0;
        self.offset = 0.0;
    }
    return self;
}

- (instancetype)initWithContentSize:(NSSize)size preferredEdge:(NSRectEdge)edge
{
    self = [self init];
    if (self) {
        self.contentSize = size;
        self.preferredEdge = edge;
    }
    return self;
}

- (void)setContentView:(NSView *)contentView
{
    if (contentView != _contentView) {
        _contentView = contentView;
        if (_contentView) {
            _contentWindow.contentView = _contentView;
            if (!_windowsPrepared) {
                _windowsPrepared = [self prepareWindows];
            }
        }
    }
}

- (void)setParentWindow:(NSWindow *)parentWindow
{
    if (parentWindow != _parentWindow) {
        _parentWindow = parentWindow;
        _windowsPrepared = [self prepareWindows];
    }
}

- (BOOL)prepareWindows
{
    BOOL bResult = NO;
    if (_parentWindow && _contentWindow) {
        if (![_contentWindow.parentWindow isEqual:self.parentWindow]) {
            [_contentWindow setFrame:[self contentWindowFrameWithEdge:self.preferredEdge closed:YES] display:YES];
            [self.parentWindow addChildWindow:_contentWindow ordered:NSWindowBelow];
            
        }
        bResult = YES;
    }
    return bResult;
}

- (NSRect)contentWindowFrameWithEdge:(NSRectEdge)edge closed:(BOOL)bClosed
{
    NSRect rectClose = NSZeroRect;

    if (_parentWindow && _contentWindow) {
        NSRect parentFrame = self.parentWindow.frame;
        NSRect contentFrame = NSMakeRect(0, 0, self.contentSize.width, self.contentSize.height);
        NSRect fixRect = NSInsetRect(parentFrame, 0.5 * (NSWidth(parentFrame) - NSWidth(contentFrame)), 0.5 * (NSHeight(parentFrame) - NSHeight(contentFrame)));
        
        switch (edge) {
            case NSMaxXEdge:
                fixRect.origin.x = NSMaxX(parentFrame) - (bClosed ? NSWidth(contentFrame) - self.offset : 0);
                break;
            case NSMinXEdge:
                fixRect.origin.x = NSMinX(parentFrame) - (!bClosed ? NSWidth(contentFrame) - self.offset : 0) ;
                break;
            case NSMaxYEdge:
                fixRect.origin.y = NSMaxY(parentFrame) - (bClosed ? NSHeight(contentFrame) - self.offset : 0);
                break;
            case NSMinYEdge:
                fixRect.origin.y = NSMinY(parentFrame) - (!bClosed ? NSHeight(contentFrame) - self.offset : 0);
                break;
            default:
                break;
        }
        
        rectClose = fixRect;
    }
    
    return rectClose;
}

- (IBAction)open:(id)sender
{
    if (_windowsPrepared && self.state == BRDrawerClosedState) {
        _state = BRDrawerOpeningState;
        
        if ([self.delegate respondsToSelector:@selector(drawerWillOpen:)]) {
            [self.delegate drawerWillOpen:self];
        }
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.allowsImplicitAnimation = YES;
            context.duration = self.animateDuration;
            context.timingFunction = [CAMediaTimingFunction functionWithName:@"easeIn"];
            
            [_contentWindow setFrame:[self contentWindowFrameWithEdge:self.preferredEdge closed:NO] display:YES];
            
        } completionHandler:^{
            _state = BRDrawerOpenState;
            if ([self.delegate respondsToSelector:@selector(drawerDidOpen:)]) {
                [self.delegate drawerDidOpen:self];
            }
            [_contentWindow orderFront:NULL];
            _contentWindow.hasShadow = YES;
        }];
    }
}

- (IBAction)close:(nullable id)sender
{
    if (_windowsPrepared && self.state == BRDrawerOpenState) {
        _state = BRDrawerClosingState;
        _contentWindow.hasShadow = NO;
        
        if ([self.delegate respondsToSelector:@selector(drawerWillClose:)]) {
            [self.delegate drawerWillClose:self];
        }
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.allowsImplicitAnimation = YES;
            context.duration = self.animateDuration;
            context.timingFunction = [CAMediaTimingFunction functionWithName:@"easeOut"];
            
            [_contentWindow setFrame:[self contentWindowFrameWithEdge:self.preferredEdge closed:YES] display:YES];
        } completionHandler:^{
            _state = BRDrawerClosedState;
            if ([self.delegate respondsToSelector:@selector(drawerDidClose:)]) {
                [self.delegate drawerDidClose:self];
            }
        }];
    }
}

- (IBAction)toggle:(nullable id)sender
{
    switch (self.state) {
        case BRDrawerClosedState:
            [self open:NULL];
            break;
        case BRDrawerOpenState:
            [self close:NULL];
            break;
        default:
            break;
    }
}

@end

@implementation BRDrawerWindow

+ (instancetype)defaultWindow
{
    return [[self alloc] initDefaultWindow];
}

- (instancetype)initDefaultWindow
{
    self = [self initWithContentRect:NSZeroRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    self.opaque = NO;
    return self;
}

@end
