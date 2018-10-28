//
//  HGJunkCodeController.m
//  MJCodeObfuscation
//
//  Created by ZhuHong on 2018/10/28.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "HGJunkCodeController.h"
#import "MJObfuscationTool.h"

@interface HGJunkCodeController ()

@property (weak) IBOutlet NSButton *chooseBtn;
@property (weak) IBOutlet NSButton *openBtn;
@property (weak) IBOutlet NSButton *startBtn;
@property (weak) IBOutlet NSTextField *filepathLabel;

@property (copy) NSString *filepath;
@property (copy) NSString *destFilepath;

@property (weak) IBOutlet NSTextField *destFilepathLabel;
@property (weak) IBOutlet NSTextField *tipLabel;

@end

@implementation HGJunkCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.tipLabel.stringValue = @"";
    self.filepathLabel.stringValue = @"";
    self.destFilepathLabel.stringValue = @"";
    
    self.openBtn.enabled = NO;
    self.startBtn.enabled = NO;
}

// 选择文件
- (IBAction)chooseFile:(NSButton *)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.prompt = @"选择";
    openPanel.canChooseDirectories = YES;
    openPanel.canChooseFiles = NO;
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
        if (result != NSModalResponseOK) return;
        
        self.filepath = openPanel.URLs.firstObject.path;
        self.filepathLabel.stringValue = [@"需要进行混淆的目录：\n" stringByAppendingString:self.filepath];
        self.destFilepath = nil;
        self.destFilepathLabel.stringValue = @"";
        self.openBtn.enabled = YES;
        self.startBtn.enabled = YES;
    }];
}

// 打开目录
- (IBAction)openFile:(NSButton *)sender {
    NSString *file = self.destFilepath ? self.destFilepath : self.filepath;
    NSArray *fileURLs = @[[NSURL fileURLWithPath:file]];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
}

// 开始混淆
- (IBAction)start:(NSButton *)sender {
    self.chooseBtn.enabled = NO;
    self.openBtn.enabled = NO;
    self.startBtn.enabled = NO;
    
    // 进度 回馈
    void (^progress)(NSString* detail) = ^(NSString* detail) {
        NSLog(@"进度 --> %@", detail);
        self.tipLabel.stringValue = detail;
    };
    
    void (^completion)(NSString *) = ^(NSString *tips) {
        self.destFilepathLabel.stringValue = tips;
        self.chooseBtn.enabled = YES;
        self.openBtn.enabled = YES;
        self.startBtn.enabled = YES;
    };
    
    [MJObfuscationTool junkCodeAtDir:self.filepath progress:progress completion:completion];
}

@end
