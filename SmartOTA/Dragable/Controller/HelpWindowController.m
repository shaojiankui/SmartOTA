//
//  HelpWindowController.m
//  SmartOTA
//
//  Created by Jakey on 2017/8/8.
//  Copyright © 2017年 Jakey. All rights reserved.
//

#import "HelpWindowController.h"

@interface HelpWindowController ()

@end

@implementation HelpWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSURL* fileURL = [NSURL URLWithString:@"http://www.skyfox.org/distributing-apple-developer-enterprise-program-apps.html"];
    NSURLRequest* request = [NSURLRequest requestWithURL:fileURL];
    [[self.webView mainFrame] loadRequest:request];
}

@end
