//
//  AppDelegate.m
//  SmartOTA
//
//  Created by Jakey on 2017/8/4.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import "AppDelegate.h"
#import "DragableWindow.h"
#import "NSString+JKHTML.h"
#import "HelpWindowController.h"
#import "HelpViewController.h"
#import "NSData+JKBase64.h"
#import "NSString+JKBase64.h"
typedef NS_OPTIONS(NSUInteger, PreviewMode) {
    PreviewModeNONE = 1 << 0,
    PreviewModePLIST = 1 << 1,
    PreviewModeHTML = 1 << 2
};

@interface AppDelegate ()<WebUIDelegate>
{
    NSString *_workingPath;
    NSTask *_unzipTask;
    NSDictionary *_appInfo;
    PreviewMode _previewMode;
    
    NSString *_dragIPAPath;
    NSString *_dragDisplayImagePath;
    NSString *_dragFullsizeImageImagePath;
}
@property (weak) IBOutlet DragableWindow *window;
@property (nonatomic, strong) NSDrawer *drawer;
@property (nonatomic, strong) NSPopover *popover;
@property (nonatomic, strong) HelpWindowController *helpWindowController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.window.movableByWindowBackground = YES;
    [self.window center];
    self.webView.UIDelegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:nil];
    
    __weak typeof(self) weakSelf = self;
    DragableView *dragView =  (DragableView*)self.window.contentView;
    [dragView dragableViewDragEnd:^(NSArray *files) {
        NSLog(@"%@",files);
        NSString *file = [files firstObject];
        if ([[file.pathExtension lowercaseString]  isEqualToString:@"ipa"]) {
            _dragIPAPath = file;
            [weakSelf applayServerURL];
            [weakSelf loadMetaInfoWithIPA:file];
        }
    }];
    
    [self.displayimageButton dragableButtonDragEnd:^(NSArray *files) {
        NSLog(@"%@",files);
        NSString *file = [files firstObject];
        if ([[file.pathExtension lowercaseString]  isEqualToString:@"png"]) {
            _dragDisplayImagePath = file;
            weakSelf.displayimageButton.image = [[NSImage alloc] initWithContentsOfFile:_dragDisplayImagePath];
            [weakSelf applayServerURL];
            [weakSelf rePreview:(_previewMode == PreviewModePLIST) ?[weakSelf generatePLIST]:[weakSelf generateHTML]];
        }
    }];
    
    [self.fullsizeimageButton dragableButtonDragEnd:^(NSArray *files) {
        NSLog(@"%@",files);
        NSString *file = [files firstObject];
        if ([[file.pathExtension lowercaseString]  isEqualToString:@"png"]) {
            _dragFullsizeImageImagePath = [files firstObject];
            weakSelf.fullsizeimageButton.image = [[NSImage alloc] initWithContentsOfFile:_dragFullsizeImageImagePath];
            [weakSelf applayServerURL];
        }
    }];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (!flag)
    {
        [self.window makeKeyAndOrderFront:self];
    }
    return YES;
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

- (NSDrawer *)drawer{
    if (!_drawer) {
        _drawer = [[NSDrawer alloc]initWithContentSize:self.previewView.frame.size preferredEdge:NSRectEdgeMinX];
        _drawer.contentView = self.previewView;
        _drawer.parentWindow = self.window;
        _drawer.leadingOffset = 0.f;
        _drawer.trailingOffset = 0.f;
        _drawer.minContentSize = NSMakeSize(self.previewView.frame.size.width,  self.previewView.frame.size.height);
        _drawer.minContentSize = NSMakeSize(self.previewView.frame.size.width,  self.previewView.frame.size.height);
    }
    return _drawer;
}

- (HelpWindowController *)helpWindowController
{
    if (!_helpWindowController)
    {
        _helpWindowController = [[HelpWindowController alloc] initWithWindowNibName:@"HelpWindowController"];
    }
    return _helpWindowController;
}

- (NSPopover *)popover{
    if(!_popover){
        _popover = [[NSPopover alloc]init];
        _popover.behavior = NSPopoverBehaviorTransient;
        _popover.contentViewController = [[HelpViewController alloc]initWithNibName:@"HelpViewController" bundle:nil];
    }
    return _popover;
}

- (void)loadMetaInfoWithIPA:(NSString*)ipaPath{
    if ([[[ipaPath pathExtension] lowercaseString] isEqualToString:@"ipa"]) {
        _workingPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"org.skyfox.SmartOTA"];
        [[NSFileManager defaultManager] removeItemAtPath:_workingPath error:nil];
        
        
        _unzipTask = [[NSTask alloc] init];
        [_unzipTask setLaunchPath:@"/usr/bin/unzip"];
        [_unzipTask setArguments:[NSArray arrayWithObjects:@"-q",ipaPath, @"-d", _workingPath, nil]];
        
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkUnzip:) userInfo:nil repeats:TRUE];
        [_unzipTask launch];
    }
    
}

- (void)checkUnzip:(NSTimer *)timer {
    if ([_unzipTask isRunning] == 0) {
        [timer invalidate];
        _unzipTask = nil;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[_workingPath stringByAppendingPathComponent:@"Payload"]])
        {
            NSLog(@"Unzipping done");
            NSString *payloadPath = [_workingPath stringByAppendingPathComponent:@"Payload"];
            
            NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:payloadPath error:nil];
            
            NSString *plistPath = nil;
            for (NSString *file in contents)
            {
                if ([[[file pathExtension] lowercaseString] isEqualToString:@"app"]) {
                    plistPath = [[payloadPath stringByAppendingPathComponent:file]  stringByAppendingPathComponent:@"Info.plist"];
                    break;
                }
            }
            _appInfo = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
            NSLog(@"appInfo:%@",_appInfo);
            [self bringMetaData:_appInfo];
        }
    }
}

- (void)bringMetaData:(NSDictionary *)appInfo{
    //  self.serverTextField.stringValue
    self.appnameTextField.stringValue = [appInfo objectForKey:@"CFBundleExecutable"];
    self.bundleidTextField.stringValue = [appInfo objectForKey:@"CFBundleIdentifier"];
    self.versionTextField.stringValue = [appInfo objectForKey:@"CFBundleShortVersionString"];
    self.kindTextField.stringValue = @"software";
    
    [self applayServerURL];
    [self rePreview:(_previewMode == PreviewModePLIST) ?[self generatePLIST]:[self generateHTML]];
}

- (void)applayServerURL{
    
    NSString *appName =  [[[[_appInfo objectForKey:@"CFBundleIdentifier"] lastPathComponent] componentsSeparatedByString:@"."] lastObject] ;
    
    self.ipaURLTextField.stringValue = [NSString stringWithFormat:@"%@%@",self.serverTextField.stringValue?:@"",[_dragIPAPath lastPathComponent]?:@""];
    
    self.plistTextField.stringValue = [NSString stringWithFormat:@"%@%@",self.serverTextField.stringValue?:@"",[appName stringByAppendingPathExtension:@"plist"]?:@""];
    
    self.h5TextField.stringValue = [NSString stringWithFormat:@"%@%@",self.serverTextField.stringValue?:@"",[appName stringByAppendingPathExtension:@"html"]?:@""];
    
    self.displayImageURLTextField.stringValue = [NSString stringWithFormat:@"%@%@",self.serverTextField.stringValue?:@"",[_dragDisplayImagePath lastPathComponent]?:@""];
    
    self.fullsizeImageURLTextField.stringValue = [NSString stringWithFormat:@"%@%@",self.serverTextField.stringValue?:@"",[_dragFullsizeImageImagePath lastPathComponent]?:@""];
}

- (void)controlTextDidChange:(NSNotification *)obj{
    if(obj.object == self.serverTextField)
    {
        [self applayServerURL];
    }
    if (self.drawer.state == NSDrawerOpenState) {
        [self rePreview:(_previewMode == PreviewModePLIST) ?[self generatePLIST]:[self generateHTML]];
    }
}

#pragma --mark button action
- (IBAction)previewPlistTouched:(NSButton*)sender {
    if (self.drawer.state == NSDrawerClosedState) {
        [self.drawer openOnEdge:NSRectEdgeMaxX];
        _previewMode = PreviewModePLIST;
    }else{
        if (_previewMode == PreviewModePLIST) {
            _previewMode = PreviewModeNONE;
            [self.drawer close];
        }else{
            _previewMode = PreviewModePLIST;
        }
    }
    if (_previewMode == PreviewModePLIST) {
        [self rePreview:[self generatePLIST]];
    }
}
- (IBAction)previewH5Touched:(id)sender {
    if (self.drawer.state == NSDrawerClosedState) {
        [self.drawer openOnEdge:NSRectEdgeMaxX];
        _previewMode = PreviewModeHTML;
    }else{
        if (_previewMode == PreviewModeHTML) {
            [self.drawer close];
            _previewMode = PreviewModeNONE;
        }else{
            _previewMode = PreviewModeHTML;
        }
    }
    
    if (_previewMode == PreviewModeHTML) {
        [self rePreview:[self generateHTML]];
    }
}

-(IBAction)helpTouched:(id)sender{
    [self.helpWindowController.window makeKeyAndOrderFront:nil];
    [self.helpWindowController.window center];
    [self.helpWindowController showWindow:nil];
    
    //    [[NSApplication sharedApplication].keyWindow.contentViewController presentViewControllerAsModalWindow:help];
    //macappstore://itunes.apple.com/app/ssh-tunnel/
}

- (IBAction)help2Touched:(NSButton*)sender {
    [self.popover showRelativeToRect:sender.bounds ofView:sender preferredEdge:NSRectEdgeMaxY];
}

- (IBAction)makeTouched:(id)sender {
    NSDateFormatter *dateForrmatter = [[NSDateFormatter alloc] init];
    [dateForrmatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    NSString *dateString = [dateForrmatter stringFromDate:[NSDate date]];
    
    //    NSString *appName =  [[[[_appInfo objectForKey:@"CFBundleIdentifier"] lastPathComponent] componentsSeparatedByString:@"."] lastObject]?:@"SmartOTA";
    
    [self browse:nil isFile:NO complete:^(NSString *url) {
        if (url.length == 0) {
            return;
        }
        NSError *error;
        NSString *dest = [url stringByAppendingPathComponent:[@"SmartOTA " stringByAppendingString:dateString]];
        [[NSFileManager defaultManager] createDirectoryAtPath:dest withIntermediateDirectories:YES attributes:nil error:nil];
        
        [[self generatePLIST] writeToFile:[self createFolderWithFile:self.plistTextField.stringValue?:@"" baseURL:dest] atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        [[self generateHTML] writeToFile:[self createFolderWithFile:self.h5TextField.stringValue?:@"" baseURL:dest] atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        [self copyItemAtPath:_dragIPAPath toPath:[self createFolderWithFile:self.ipaURLTextField.stringValue?:@"" baseURL:dest]];
        
        [self copyItemAtPath:_dragDisplayImagePath toPath:[self createFolderWithFile:self.displayImageURLTextField.stringValue?:@"" baseURL:dest]];
        
        [self copyItemAtPath:_dragFullsizeImageImagePath toPath:[self createFolderWithFile:self.self.fullsizeImageURLTextField.stringValue?:@"" baseURL:dest]];
        
        [self copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"Template" ofType:@"mime"] toPath:[dest stringByAppendingPathComponent:@"Template.mime"]];

        [[NSWorkspace sharedWorkspace] selectFile:dest inFileViewerRootedAtPath:@""];
    }];
}

- (IBAction)selectIpaTouched:(id)sender {
    __weak typeof(self) weakSelf = self;
    [self browse:@[@"ipa",@"IPA"] isFile:YES complete:^(NSString *file) {
        NSLog(@"%@",file);
        if (file.length>0) {
            _dragIPAPath = file;
            [weakSelf applayServerURL];
            [weakSelf loadMetaInfoWithIPA:file];
        }
    }];
}

- (IBAction)selectDisplayImageTouched:(id)sender {
    __weak typeof(self) weakSelf = self;
    [self browse:@[@"png",@"PNG"] isFile:YES complete:^(NSString *file) {
        NSLog(@"%@",file);
        if (file.length>0) {
            _dragDisplayImagePath = file;
            weakSelf.displayimageButton.image = [[NSImage alloc] initWithContentsOfFile:_dragDisplayImagePath];
            [weakSelf applayServerURL];
            [weakSelf rePreview:(_previewMode == PreviewModePLIST) ?[weakSelf generatePLIST]:[weakSelf generateHTML]];
        }
    }];
}

- (IBAction)selectFullImageTouched:(id)sender {
    __weak typeof(self) weakSelf = self;
    [self browse:@[@"png",@"PNG"] isFile:YES complete:^(NSString *file) {
        if (file.length>0) {
            _dragFullsizeImageImagePath = file;
            weakSelf.fullsizeimageButton.image = [[NSImage alloc] initWithContentsOfFile:_dragFullsizeImageImagePath];
            [weakSelf applayServerURL];
        }
    }];
}

#pragma --mark helper
- (void)browse:(NSArray *)fileTypes isFile:(BOOL)isFile complete:(void (^)(NSString *file))complete{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseFiles = isFile;
    openPanel.canChooseDirectories = !isFile;
    openPanel.allowsMultipleSelection = NO;
    openPanel.allowsOtherFileTypes = NO;
    openPanel.allowedFileTypes = fileTypes;
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK)
        {
            complete( [[[openPanel URLs] objectAtIndex:0] path]);
        }else {
            complete(nil);
        }
    }];
}

- (BOOL)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath{
    if (srcPath && dstPath) {
        return  [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dstPath error:nil];
    }
    return NO;
}

- (NSString *)createFolderWithFile:(NSString*)url baseURL:(NSString*)baseURL{
    NSURL *nurl = [NSURL URLWithString:url?:@""];
    NSString *folder = [[baseURL stringByAppendingPathComponent:nurl.host] stringByAppendingPathComponent:[nurl.path stringByDeletingLastPathComponent]];
    [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    return [folder stringByAppendingPathComponent:[nurl.path lastPathComponent]];
}

- (void)rePreview:(NSString *)html{
    NSString *finalHMTL = html;
    if (_previewMode == PreviewModePLIST) {
        finalHMTL = [NSString stringWithFormat:@"<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\"><title>xx</title></head><body><pre>%@</pre></body></html>",[html jk_stringByEscapingForHTML] ];
    }
    [[self.webView mainFrame] loadHTMLString:finalHMTL?:@"" baseURL:nil];
}

- (NSString *)generatePLIST{
    NSDictionary *item =  @{ @"assets":@[@{@"kind":@"software-package",@"url":self.ipaURLTextField.stringValue?:@""},
                                           @{@"kind":@"display-image",@"url":self.displayImageURLTextField.stringValue?:@""},
                                           @{@"kind":@"full-size-image",@"url":self.fullsizeImageURLTextField.stringValue?:@""}],
                             @"metadata":@{
                                     @"bundle-identifier":self.bundleidTextField.stringValue?:@"",
                                     @"bundle-version":self.versionTextField.stringValue?:@"",
                                     @"kind":self.kindTextField.stringValue?:@"software",
                                     @"subtitle":self.appnameTextField.stringValue?:@"",
                                     @"title":self.appnameTextField.stringValue?:@"",
                                     }};
    
    NSDictionary *plistDict = @{@"items":@[item]};
    NSError *error;
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 options:NSPropertyListMutableContainersAndLeaves error:&error];
    NSString *plistString = [[NSString alloc] initWithData:plistData encoding:NSUTF8StringEncoding];
    return plistString;
}

- (NSString *)generateHTML{
    NSData *HTMLData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Template" ofType:@"html"]];
    NSString *string = [[NSString alloc]initWithData:HTMLData encoding:NSUTF8StringEncoding];
    
    string = [string stringByReplacingOccurrencesOfString:@"{{name}}" withString:self.appnameTextField.stringValue?:@""];
    string = [string stringByReplacingOccurrencesOfString:@"{{description}}" withString:self.desTextField.stringValue?:@""];
    string = [string stringByReplacingOccurrencesOfString:@"{{version}}" withString:self.versionTextField.stringValue?:@""];

    string = [string stringByReplacingOccurrencesOfString:@"{{plist}}" withString:self.plistTextField.stringValue?:@""];

//    string = [string stringByReplacingOccurrencesOfString:@"{{iconString}}" withString:self.displayImageURLTextField.stringValue?:@""];
    
    string = [string stringByReplacingOccurrencesOfString:@"{{iconString}}" withString:[@"data:image/png;base64," stringByAppendingString:[[NSData dataWithContentsOfFile:_dragDisplayImagePath?:@""] jk_base64EncodedString]?:@""]];

    string = [string stringByReplacingOccurrencesOfString:@"{{tip}}" withString:NSLocalizedString(@"【wechat scan qrcode cant install directly】，please click top right corner “open in Safari”", nil)];
    string = [string stringByReplacingOccurrencesOfString:@"{{installtip}}" withString:NSLocalizedString(@"click install will auto download and install app,please back device destop", nil)];
    string = [string stringByReplacingOccurrencesOfString:@"{{download}}" withString:NSLocalizedString(@"install", nil)];
    return string;
}
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{


}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{

}
@end
