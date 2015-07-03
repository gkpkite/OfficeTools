//
//  ViewController.m
//  OfficeTools
//
//  Created by kitegkp on 15/6/6.
//  Copyright (c) 2015年 kitegkp. All rights reserved.
//

#import "ViewController.h"
#import "ReadViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableViewController * _tableViewController;
    NSMutableArray * _dataArr;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self.view setBackgroundColor:[UIColor clearColor]];
    
    if (!_tableViewController) {
        _tableViewController=[[UITableViewController alloc] init];
        [self.view addSubview:_tableViewController.view];
         self.navigationItem.title=@"文档工具";
//        [_tableViewController.view setBackgroundColor:[UIColor clearColor]];
        _tableViewController.tableView.delegate=self;
        _tableViewController.tableView.dataSource=self;
    }
    if (!_dataArr) {
        _dataArr=[[NSMutableArray alloc] initWithCapacity:0];
    }
    [_dataArr removeAllObjects];
    
    [_dataArr addObjectsFromArray:[self getFiles:[self documentsFilePath:nil] withFilterString:nil]];
    
    [_tableViewController.tableView reloadData];
    

}

#pragma mark - 获取文稿下文件
-(NSArray*) getFiles:(NSString*)dirPath withFilterString:(NSString *)filterString {
    NSMutableArray* filesArray = (NSMutableArray*)[[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    NSMutableArray* dirsArray = [[NSMutableArray alloc] init];
    
    for (NSString* file in filesArray) {
        BOOL flag = YES;
        BOOL match = YES;
        
        if (filterString != nil && filterString.length > 0) {
            NSRange range = [file rangeOfString:filterString];
            if (range.length < 1) match = NO;
        }
        flag = (!match || ([[NSFileManager defaultManager] fileExistsAtPath:[[self documentsFilePath:nil] stringByAppendingPathComponent:file] isDirectory:&flag] && flag));
        if (flag) [dirsArray addObject:file];
    }
    [filesArray removeObjectsInArray:dirsArray];
 
    return (NSArray*)filesArray;
}

-(NSString *) documentsFilePath:(NSString *)fileName {
    
//    NSString *documentsDirectory0 = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//      NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    
//    NSLog(@"documentsDirectory0 %@ ,dir %@  %@  %@",documentsDirectory0,dir,[[NSBundle mainBundle] bundlePath],NSTemporaryDirectory());
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return (fileName == nil || fileName.length < 1) ? documentsDirectory : [documentsDirectory stringByAppendingPathComponent:fileName];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ReadViewController * _readViewController=[[ReadViewController alloc] init];
    [self.navigationController pushViewController:_readViewController animated:YES];
    
    
    NSString* fileName = [_dataArr objectAtIndex:indexPath.row];
    _readViewController.navigationItem.title=fileName;
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    

    
    NSString* _urlStr=[NSString stringWithFormat:@"%@/%@",documentsDirectory,[fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"_urlStr %@",_urlStr);
    
    [_readViewController loadOfficeData:_urlStr];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *tableViewIdentifier = @"ControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:tableViewIdentifier];
    }
     NSString* fileName = [_dataArr objectAtIndex:indexPath.row];
    cell.textLabel.text=fileName;

    return cell;

}






@end
