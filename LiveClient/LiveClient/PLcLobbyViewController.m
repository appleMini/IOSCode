//
//  PLcLobbyViewController.m
//  PLLiveCourse
//
//  Created by 小布丁 on 2017/2/14.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "PLcLobbyViewController.h"
#import "PLBroadcastRoomViewController.h"
#import "SMAVPlayerViewController.h"
#import "Room.h"
#import "LCFileHandle.h"
#import "VideoModel.h"
#import <CoreFoundation/CoreFoundation.h>

@interface PLcLobbyViewController () {
    NSString *_uid;
    NSArray<Room *> *_roomList;
}

@end

@implementation PLcLobbyViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _uid = @"root_abc";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self _generateLiveListWithComplete:^(NSArray *roomList) {
        _roomList = roomList;
//        [self.tableView reloadData];
        //局部刷新
        NSIndexSet *indexSet=[[NSIndexSet alloc] initWithIndex:0];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = ({
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"大厅";
        [titleLabel sizeToFit];
        titleLabel;
    });
    
    self.navigationItem.rightBarButtonItem = ({
        UIBarButtonItem *button = [[UIBarButtonItem alloc] init];
        button.title = @"直播";
        button.target = self;
        button.action = @selector(_onPressBroadcaseButton:);
        button;
    });
    
}

- (void)_onPressBroadcaseButton:(id)sender{
    
    [self _generatePushURLWithComplete:^(NSDictionary *info) {
        PLBroadcastRoomViewController *roomVC = [[PLBroadcastRoomViewController alloc] init];
        roomVC.titleText = @"直播间";
        [self.navigationController pushViewController:roomVC animated:YES];
    }];
}

- (void)_generatePushURLWithComplete:(void(^)(NSDictionary *info))complete
{
    NSString *userid = @"SmartKiller";
    NSString *url = [NSString stringWithFormat:@"%@%@%@",kHost,@"/rest/room/",userid];
    NSSLog(@"connect to %@", url);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 15;
    //    [request setHTTPBody:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    //
    __weak typeof(self) weakSelf = self;
    [self showLoadingView];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable responseError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf dismissLoadingView];
            
            NSError *error = responseError;
            if (error != nil || response == nil || data == nil) {
                NSSLog(@"获取服务器信息 失败 %@", error);
                [MBProgressHUD showError:@"获取服务器信息失败" toView:strongSelf.view];
                return ;
            }
            
            NSDictionary *sJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            NSSLog(@"streamJSON: %@",sJSON);
            
            NSString *code = sJSON[@"code"];
            int backCode = [code intValue];
            if (backCode != 200) {
                NSString *errorMsg = sJSON[@"errorMsg"];
            
                [MBProgressHUD showError:errorMsg?errorMsg:@"服务器错误" toView:strongSelf.view];
                return;
            }
            
            //清除临时文件
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString *fileName = [NSString stringWithFormat:@"%@",userid];
            
            NSString *writablePath = [documentsDirectory stringByAppendingPathComponent:fileName];
            
            BOOL isDirectory = YES;
            if([[NSFileManager defaultManager] fileExistsAtPath:writablePath isDirectory:&isDirectory]){
                [[NSFileManager defaultManager] removeItemAtPath:writablePath error:nil];
                
                NSError *error = nil;
                [[NSFileManager defaultManager] createDirectoryAtPath:writablePath withIntermediateDirectories:YES attributes:nil error:&error];
                if(error){
                    [MBProgressHUD showError:@"文件夹创建失败！" toView:strongSelf.view];
                    return;
                }
            }else{
                NSError *error = nil;
                [[NSFileManager defaultManager] createDirectoryAtPath:writablePath withIntermediateDirectories:YES attributes:nil error:&error];
                
                if(error){
                    [MBProgressHUD showError:@"文件夹创建失败！" toView:strongSelf.view];
                    return;
                }
            }
            
            if (complete) {
                complete(sJSON);
            }
        });
    }];
    
    [task resume];
}

- (void)_generateLiveListWithComplete:(void(^)(NSArray *info))complete {
    NSString *url = [NSString stringWithFormat:@"%@%@",kHost,@"/rest/live/list"];
    NSSLog(@"connect to %@", url);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 15;
    __weak typeof(self) weakSelf = self;
    [self showLoadingView];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable responseError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf dismissLoadingView];
            
            NSError *error = responseError;
            if (error != nil || response == nil || data == nil) {
                NSSLog(@"获取服务器信息 失败 %@", error);
                [MBProgressHUD showError:@"获取服务器信息失败" toView:strongSelf.view];
                return ;
            }
            
            NSDictionary *sJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            NSSLog(@"streamJSON: %@",sJSON);
            
            NSString *code = sJSON[@"code"];
            int backCode = [code intValue];
            if (backCode != 200) {
                NSString *errorMsg = sJSON[@"errorMsg"];
                
                [MBProgressHUD showError:errorMsg?errorMsg:@"服务器错误" toView:strongSelf.view];
                return;
            }
            
            NSArray *arr = [Room mj_objectArrayWithKeyValuesArray:sJSON[@"obj"]];
            if (complete) {
                complete(arr);
            }
        });
    }];
    
    [task resume];
}

#pragma -mark tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return _roomList.count;
    }else if(section == 1){
        return 1;
    }else{
        return 1;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return @"直播间";
    }if(section == 1){
        return @"HLS（m3u8）";
    }else if(section == 2){
        return @"在线视频";
    }else if(section == 3){
        return @"在线视频(no asset loader)";
    }else if(section == 4){
        return @"在线点播";
    }else if(section == 5){
        return @"本地视频";
    }else{
        return @"设置";
    }
}

static NSString *reuserid = @"reuserID";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuserid];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserid];
    }
    
    if(indexPath.section == 0){
        cell.textLabel.text = [_roomList[indexPath.row] roomid];
    }else if(indexPath.section == 1){ //在线视频
        cell.textLabel.text = @"HLS直播";
    }else if(indexPath.section == 2){ //在线视频
        cell.textLabel.text = @"火影忍者";
    }else if(indexPath.section == 3){ //在线视频
        cell.textLabel.text = @"火影忍者";
    }else if(indexPath.section == 4){ //在线视频
        cell.textLabel.text = @"测试";
    }else if(indexPath.section == 5){ //本地视频
        cell.textLabel.text = @"广告";
    }else{ //本地视频
        cell.textLabel.text = @"清除缓存文件";
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    VideoModel *model = [VideoModel sharedVideoModel];
    
    if(indexPath.section == 0){
        //播放本地视频
        NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"cctv.mp4" ofType:nil];
        model.strURL = [NSURL fileURLWithPath:urlStr];
        model.subTitile = @"广告";
        
    }else if(indexPath.section == 1){
        SMAVPlayerViewController *moviePlayer = [[SMAVPlayerViewController alloc] initWithType:PlayerLocationLiveType];
        
        NSString *urlString = @"http://192.168.1.103:8080/PLLiveService/h264/index0.m3u8";
        model.strURL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
//        NSString *url = @"http://flv2.bn.netease.com/tvmrepo/2017/3/D/I/ECFBCR8DI/SD/movie_index.m3u8";
        model.subTitile = @"HLS直播";
        
        moviePlayer.video = model;
        [self.navigationController pushViewController:moviePlayer animated:YES];
        
    }else if(indexPath.section == 2){
        SMAVPlayerViewController *moviePlayer = [[SMAVPlayerViewController alloc] initWithType:PlayerURLType];
        NSString *urlStr = [NSString stringWithFormat:@"%@/rest/movie/loader/test.mp4",kHost];
        
        NSString *playUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)urlStr,(CFStringRef)@"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ",NULL,kCFStringEncodingUTF8));
        
        model.strURL = [NSURL URLWithString:playUrl];
        model.subTitile = @"边下边播";
        
        moviePlayer.video = model;
        [self.navigationController pushViewController:moviePlayer animated:YES];
    }else if(indexPath.section == 3){
        SMAVPlayerViewController *moviePlayer = [[SMAVPlayerViewController alloc] initWithType:PlayerNoLoaderURLType];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@/h264/test.mp4",kHost];
        
        NSString *playUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)urlStr,(CFStringRef)@"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ",NULL,kCFStringEncodingUTF8));
        //下面注释的方法有问题
        //            NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
        //            NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
        //            NSString *urlStr = [videoModel.strURL stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];

        model.strURL = [NSURL URLWithString:playUrl];
        model.subTitile = @"在线视频";
        
        moviePlayer.video = model;
        [self.navigationController pushViewController:moviePlayer animated:YES];
    }else if(indexPath.section == 4){
        SMAVPlayerViewController *moviePlayer = [[SMAVPlayerViewController alloc] initWithType:PlayerVODType];
//        NSString *urlStr = [NSString stringWithFormat:@"%@/rest/movie/loader/test.mp4",kHost];
        NSString *urlStr = [NSString stringWithFormat:@"%@/h264/test.mp4",kHost];
        
        NSString *playUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)urlStr,(CFStringRef)@"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ",NULL,kCFStringEncodingUTF8));
        //下面注释的方法有问题
        //            NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
        //            NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
        //            NSString *urlStr = [videoModel.strURL stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
        
        model.strURL = [NSURL URLWithString:playUrl];
        model.subTitile = @"点播";
        
        moviePlayer.video = model;
        [self.navigationController pushViewController:moviePlayer animated:YES];
    }else if(indexPath.section == 5){
        SMAVPlayerViewController *moviePlayer = [[SMAVPlayerViewController alloc] initWithType:PlayerLocationType];
        VideoModel *model = [VideoModel sharedVideoModel];
        //播放本地视频  Ripple-600k.mp4  cctv.mp4
        NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"2017-03-31_10_52_35b86b6_H.mp4" ofType:nil];
        model.strURL = [NSURL fileURLWithPath:urlStr];
        model.subTitile = @"广告";
        
        moviePlayer.video = model;
        [self.navigationController pushViewController:moviePlayer animated:YES];
    }else{
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"确定要删除缓存吗？下次需要重新下载奥。" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //删除缓存文件
            [LCFileHandle clearDocumentCache];
            [LCFileHandle clearCache];
            
            [alertVC dismissViewControllerAnimated:YES completion:nil];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"考虑一下" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertVC dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alertVC addAction:action];
        [alertVC addAction:cancelAction];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}
@end
