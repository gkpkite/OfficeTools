//
//  ReadViewController.m
//  OfficeTools
//
//  Created by kitegkp on 15/6/7.
//  Copyright (c) 2015年 kitegkp. All rights reserved.
//

#import "ReadViewController.h"

@interface ReadViewController ()
{
    UIWebView * _dataView;
    NSString* _urlStr;
}
@end

@implementation ReadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)])
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
         self.modalPresentationCapturesStatusBarAppearance = NO;
    }

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {    self.edgesForExtendedLayout = UIRectEdgeNone;   }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)loadOfficeData:(NSString *)officePath{
    _urlStr=officePath;
    
    if (!_dataView) {
        _dataView=[[UIWebView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:_dataView];

    }
    _dataView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

    NSURL *url = [[NSURL alloc] initWithString:_urlStr];
    _dataView.scalesPageToFit = YES;
    NSURLRequest *requestDoc = [NSURLRequest requestWithURL:url];
    [_dataView loadRequest:requestDoc];
    

    
}


@end
