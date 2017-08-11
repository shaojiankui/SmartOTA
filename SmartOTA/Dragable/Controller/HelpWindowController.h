//
//  HelpWindowController.h
//  SmartOTA
//
//  Created by Jakey on 2017/8/8.
//  Copyright © 2017年 Jakey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
@interface HelpWindowController : NSWindowController
@property (weak) IBOutlet WebView *webView;

@end
