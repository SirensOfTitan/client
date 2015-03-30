//
//  KBProgressView.m
//  Keybase
//
//  Created by Gabriel on 3/6/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import "KBProgressView.h"

#import "KBProgressOverlayView.h"
#import "KBErrorView.h"
#import "AppDelegate.h"

@interface KBProgressView ()
@property KBProgressOverlayView *progressView;
@property KBErrorView *errorView;
@property (copy) dispatch_block_t close;
@property (weak) id sender;
@end

@implementation KBProgressView

- (void)viewInit {
  [super viewInit];
  self.wantsLayer = YES;
  self.layer.backgroundColor = NSColor.whiteColor.CGColor;

  _progressView = [[KBProgressOverlayView alloc] init];
  _progressView.animating = YES;
  [self addSubview:_progressView];

  _errorView = [[KBErrorView alloc] init];
  _errorView.hidden = YES;
  [self addSubview:_errorView];

  YOSelf yself = self;
  self.viewLayout = [YOLayout layoutWithLayoutBlock:^CGSize(id<YOLayout> layout, CGSize size) {
    [layout setSize:size view:yself.errorView options:0];
    [layout setSize:size view:yself.progressView options:0];
    return size;
  }];
}

- (void)setError:(NSError *)error {
  [_errorView setError:error];
  _errorView.hidden = NO;
  CGSize size = [_errorView sizeThatFits:self.frame.size];
  CGRect rect = self.frame;
  rect.size = size;
  [self.window setFrame:rect display:YES animate:YES];
  [self setNeedsLayout];
}

- (void)doIt:(dispatch_block_t)close {
  //GHWeakSelf gself = self;
  self.work(^(NSError *error) {
    if (error) {
      /*
      gself.progressView.animating = NO;
      [self setError:error];
      gself.errorView.closeButton.targetBlock = ^{
        [self close:self];
        close();
      };
       */
      [self close:self close:close];
      [AppDelegate setError:error sender:self.sender];
    } else {
      [self close:self close:close];
    }
  });
}

- (void)openAndDoIt:(id)sender {
  [self open:sender];
  [self doIt:^{}];
}

- (void)setProgressTitle:(NSString *)progressTitle {
  _progressView.title = progressTitle;
}

- (void)open:(id)sender {
  self.sender = sender;
  //KBNavigationView *navigationView = [[KBNavigationView alloc] initWithView:self title:_title];
  self.close = [AppDelegate openSheetWithView:self size:CGSizeMake(200, 200) sender:sender closeButton:nil];
}

- (void)close:(id)sender close:(dispatch_block_t)close {
  self.close();
  if (close) dispatch_async(dispatch_get_main_queue(), close);
  //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), close);
}

@end
