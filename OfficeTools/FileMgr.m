//
//  FieldMgr.m
//  OfficeTools
//
//  Created by kitegkp on 15/6/23.
//  Copyright (c) 2015年 kitegkp. All rights reserved.
//

#import "FileMgr.h"

@implementation FileMgr

// 获取应用程序 文件夹路径
+ (NSString *)getDocumentDirectory
{
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return dir;
}

//判断文件是否存在
+(BOOL)fileExistsAtPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}

// 复制单个文件
+ (BOOL)copySingleFileFromFilePath:(NSString *)src toFilePath:(NSString *)dest
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:src]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:dest]) {
            [[NSFileManager defaultManager] removeItemAtPath:dest error:nil];
        }
        //NSLog(@"%@", src);
        
        //NSLog(@"%@", dest);
        
        NSError *error = nil;
        
        BOOL success = [[NSFileManager defaultManager] copyItemAtPath:src toPath:dest error:&error];
        
        if (!success) {
            NSLog(@"%@", [error localizedDescription]);
            
            return FALSE;
        }
    }
    return YES;
}

//确保路径存在 一层层确定文件夹存在
+(BOOL)makeSure:(NSString*)path{
    NSArray *array = [path componentsSeparatedByString:@"/Documents/"]; //以“/”分割
    NSArray *arrayTemp=[[array objectAtIndex:(array.count-1)]  componentsSeparatedByString:@"/"]; //以/分割
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* tempPath = [self getDocumentDirectory];
    //[[FileHelper getDocumentDirectory]stringByAppendingString:@"/Sys/"];
    
    for (int i=0; i<arrayTemp.count; i++) {
        if ( [arrayTemp objectAtIndex:i] &&[[arrayTemp objectAtIndex:i] rangeOfString:@"."].location!= NSNotFound)
        {   //有后缀代表是 文件，而不是文件夹
            continue;
        }
        if (![arrayTemp objectAtIndex:i]){  //字符串空情况
            continue;
        }
        NSString* textPath=[tempPath stringByAppendingFormat:@"/%@/",[arrayTemp objectAtIndex:i]];
        if(![fileManager fileExistsAtPath:path]) {  //不存在则建立
            [[NSFileManager defaultManager] createDirectoryAtPath:textPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        tempPath=[tempPath stringByAppendingFormat:@"/%@",[arrayTemp objectAtIndex:i]];
    }
    return  YES;
}

// 根据修改的时间 判断是否覆盖文件
+(void)copyNewFilesFromFilePath:(NSString *)src toPath:(NSString *)dest
{
    [self makeSure:dest];
    NSError *error = nil;
    //    NSArray *dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:src error:&error];
    //由于采用了目标dest 存在的图片才刷新方式，所以以dest做参考
    NSArray *dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:src error:&error];
    for (NSString *item in dirs) {  //这里只处理到两层文件夹
        NSString *srcPath = [NSString stringWithFormat:@"%@/%@", src, item];
        NSString *destPath = [NSString stringWithFormat:@"%@/%@", dest, item];
        NSArray *srcDirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:srcPath error:&error];
        if (srcDirs && srcDirs.count>0) {
            [self copyNewFilesFromFilePath:srcPath toPath:destPath];
        }else{
            [self copyFile:srcPath toPath:destPath];
            NSLog(@"srcPath %@ destPath %@",srcPath,destPath);
        }
    }
}

//保证只传过来的是文件 而不是文件夹
+(void)copyFile:(NSString *)srcPath toPath:(NSString *)destPath
{
    [self makeSure:destPath];
    if ([self fileExistsAtPath:destPath]) {//如果已经存在 则比较时间是否更新
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDictionary *srcAttributes = [fileManager attributesOfItemAtPath:srcPath error:nil];
        NSDictionary *destAttributes = [fileManager attributesOfItemAtPath:destPath error:nil];
        if (srcAttributes && destAttributes) {
            NSDate *srcFileModDate=[srcAttributes objectForKey:NSFileModificationDate];
            NSDate *destFileModDate=[destAttributes objectForKey:NSFileModificationDate];
            NSTimeInterval distanceBetweenDates = [destFileModDate timeIntervalSinceDate:srcFileModDate]; //文稿下修改时间新比app下文件则不覆盖
            if (distanceBetweenDates>=0) {
                return;
            }
        }
    }
    if (![self copySingleFileFromFilePath:srcPath toFilePath:destPath]) {
        NSLog(@"覆盖文件出错 %@",srcPath);
    }
}

//初始化文件
+(void)initFile{
    NSString *oldSysPath=[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"/data"];
    NSString *newSysPath=[self getDocumentDirectory];
    //比较文稿下图片 由于多个项目图片存到一起，所以文稿下只放当前项目图片。
    if ([self makeSure:newSysPath]) {
        [self copyNewFilesFromFilePath:oldSysPath toPath:newSysPath];
    }
}


@end
