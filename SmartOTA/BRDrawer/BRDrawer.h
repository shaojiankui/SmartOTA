//
//  BRDrawer.h
//  TestDrawer
//
//  Created by Yang on 3/23/16.
//  Copyright © 2016 sgyang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol BRDrawerDelegate;

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, BRDrawerState) {
    BRDrawerClosedState			= 0,
    BRDrawerOpeningState 		= 1,
    BRDrawerOpenState 			= 2,
    BRDrawerClosingState 		= 3
};
IB_DESIGNABLE
@interface BRDrawer : NSObject

- (instancetype)initWithContentSize:(NSSize)size preferredEdge:(NSRectEdge)edge;

@property IBInspectable NSSize contentSize;
@property IBInspectable CGFloat animateDuration;
@property IBInspectable CGFloat offset;

@property (nullable, nonatomic, strong) IBOutlet NSView *contentView;
@property (nullable, nonatomic, weak) IBOutlet NSWindow *parentWindow;

@property NSRectEdge preferredEdge;
@property (nullable, weak) id<BRDrawerDelegate> delegate;

- (IBAction)open:(nullable id)sender;
- (IBAction)close:(nullable id)sender;
- (IBAction)toggle:(nullable id)sender;

@property (readonly) BRDrawerState state;

@end

@protocol BRDrawerDelegate <NSObject>
@optional

- (void)drawerWillOpen:(BRDrawer *)drawer;
- (void)drawerDidOpen:(BRDrawer *)drawer;
- (void)drawerWillClose:(BRDrawer *)drawer;
- (void)drawerDidClose:(BRDrawer *)drawer;

@end

NS_ASSUME_NONNULL_END
