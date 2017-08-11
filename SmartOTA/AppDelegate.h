//
//  AppDelegate.h
//  SmartOTA
//
//  Created by Jakey on 2017/8/4.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "DragableView.h"
#import "DragableButton.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet NSView *previewView;

@property (weak) IBOutlet NSTextField *serverTextField;
@property (weak) IBOutlet NSTextField *appnameTextField;
@property (weak) IBOutlet NSTextField *desTextField;
@property (weak) IBOutlet NSTextField *bundleidTextField;
@property (weak) IBOutlet NSTextField *versionTextField;
@property (weak) IBOutlet NSTextField *kindTextField;
@property (weak) IBOutlet NSTextField *ipaURLTextField;
@property (weak) IBOutlet WebView *webView;

@property (weak) IBOutlet NSTextField *displayImageURLTextField;
@property (weak) IBOutlet NSTextField *fullsizeImageURLTextField;

@property (weak) IBOutlet DragableButton *displayimageButton;
@property (weak) IBOutlet DragableButton *fullsizeimageButton;
@property (weak) IBOutlet NSTextField *plistTextField;
@property (weak) IBOutlet NSTextField *h5TextField;

@end

