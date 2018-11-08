//
//  SuntorntSocket.m
//  BLECardReader
//
//  Created by apple on 2017/9/5.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "XTSocketManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface XTSocketManager ()<XTAsyncSocketDelegate,XTAsyncUdpSocketDelegate>

{
    NSTimer *_dataTimer;
}

@property (nonatomic, copy) void(^connectSuccess)();
@property (nonatomic, copy) void(^connectFailure)(NSError *error);
@property (nonatomic, copy) void(^receiveDataSuccess)(NSData *receiveData);
@property (nonatomic, copy) void(^receiveDataFailure)(NSError *error);

@end

@implementation XTSocketManager

static id _instace;

- (id)init
{
    static id obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((obj = [super init])) {
            // 1、初始化服务器socket，在主线程力回调
            self.clientSocket = [[XTAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        }
    });
    self = obj;
    return self;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [super allocWithZone:zone];
    });
    return _instace;
}

+ (id)sharedManager
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    
    return _instace;
}



/**
 连接socket

 @param ip 地址
 @param port 端口号
 @param success 成功
 @param failure 失败
 */
- (void)connectSocketWithIP:(NSString *)ip port:(NSString *)port success:(void(^)())success failure:(void(^)(NSError *error))failure {
    
    self.connectSuccess = success;
    self.connectFailure = failure;
    
    NSError *error = nil;
    [self.clientSocket disconnect];
    if (self.clientSocket.isDisconnected) {
        
        BOOL result = [self.clientSocket connectToHost:ip onPort:[port intValue] withTimeout:10 error:&error];
        if (result && error == nil) {
            //开放成功
            //NSLog(@"======socket开放成功======");
            
        }  else {
            if (self.connectFailure) {
                self.connectFailure(error);
            }
        }
    }

}


/**
 发送消息

 @param data 数据
 @param success 成功
 @param failure 失败
 */
- (void)sendData:(NSData *)data success:(void(^)(NSData *receiveData))success failure:(void(^)(NSError *error))failure {
    
    self.receiveDataSuccess = success;
    self.receiveDataFailure = failure;
    
    if (self.clientSocket.isConnected == NO) {
        if (self.receiveDataFailure) {
            NSError *error = [NSError errorWithDomain:@"错误" code:110 userInfo:@{@"NSLocalizedDescription": @"socket未连接"}];
            self.receiveDataFailure(error);
            return;
        }
    }
    
    if (!_dataTimer) {
        _dataTimer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(stopWriteData) userInfo:nil repeats:NO];
    }
    [_dataTimer setFireDate: [[NSDate date]dateByAddingTimeInterval:10]];
    [[NSRunLoop currentRunLoop] addTimer:_dataTimer forMode:NSRunLoopCommonModes];
    
    
    NSLog(@"======socket写入数据data:%@======",data);
    //withTimeout -1:无穷大，一直等
    //tag:消息标记
    [self.clientSocket writeData:data withTimeout:10 tag:0];
    
}

/**
 断开连接
 */
- (void)disconnect {
    [self.clientSocket disconnect];
}

#pragma -mark timer
- (void)stopWriteData {
    [_dataTimer invalidate];
    _dataTimer = nil;
    if (self.receiveDataFailure) {
        NSError *error = [NSError errorWithDomain:@"错误" code:110 userInfo:@{@"NSLocalizedDescription": @"write超时"}];
        self.receiveDataFailure(error);
    }
}

- (void)stopReadData {
    [_dataTimer invalidate];
    _dataTimer = nil;
    if (self.receiveDataFailure) {
        NSError *error = [NSError errorWithDomain:@"错误" code:110 userInfo:@{@"NSLocalizedDescription": @"read超时"}];
        self.receiveDataFailure(error);
    }
}

#pragma -mark XTAsyncSocketDelegate
- (void)socket:(XTAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    //连接成功
    
    [self.clientSocket readDataWithTimeout:10 tag:0];
    
    NSLog(@"======socket连接成功======");
    if (self.connectFailure) {
        _connectFailure = nil;
    }
    if (self.connectSuccess) {
        self.connectSuccess();
        _connectSuccess = nil;
    }
    
}

- (void)socketDidDisconnect:(XTAsyncSocket *)sock withError:(nullable NSError *)err {
    NSLog(@"======socket断开连接======");
    if (self.connectFailure) {
        self.connectFailure(err);
        _connectFailure = nil;
    }
}

- (void)socket:(XTAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
    [_dataTimer invalidate];
    _dataTimer = nil;
    
    if (!_dataTimer) {
        _dataTimer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(stopReadData) userInfo:nil repeats:NO];
    }
    [_dataTimer setFireDate: [[NSDate date]dateByAddingTimeInterval:10]];
    [[NSRunLoop currentRunLoop] addTimer:_dataTimer forMode:NSRunLoopCommonModes];
    
    [self.clientSocket readDataWithTimeout:10 tag:tag];
   
}

//收到消息
- (void)socket:(XTAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    [_dataTimer invalidate];
    _dataTimer = nil;
    
    NSLog(@"======socket收到数据data:%@======",data);
    
    if (self.receiveDataSuccess) {
        self.receiveDataSuccess(data);
    }
    
    [self.clientSocket readDataWithTimeout:10 tag:0];
    
}

@end

NS_ASSUME_NONNULL_END
