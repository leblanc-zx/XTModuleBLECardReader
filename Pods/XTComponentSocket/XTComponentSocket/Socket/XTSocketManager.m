//
//  SuntorntSocket.m
//  BLECardReader
//
//  Created by apple on 2017/9/5.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "XTSocketManager.h"

NSString *const KK_AESPSW = @"xt0371@126.com|*";

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

#pragma -mark login
/**
 socket登录 
 
 @param userNo 用户编号
 @param success 成功
 @param failure 失败
 */
- (void)loginWithuserNo:(NSString *)userNo Socket:(void(^)())success failure:(void(^)(NSError *error))failure {
    
    NSString *loginRS = @"[Request],Command=Login,UserName=admin,Password=admin";
    NSString *loginData = [self getAESEncryptWithRequestStr:loginRS userNo:userNo];
    NSData *dataLen = [self getDataLen:loginData];
    NSData *pLen = [self getPLength:loginData];
    
    NSMutableData *sendData = [NSMutableData new];
    [sendData appendData:pLen];
    [sendData appendData:dataLen];
    [sendData appendData:[loginData dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self sendData:sendData success:^(NSData *receiveData) {
        
        if (receiveData.length > 8) {
            
            NSData *ivData = [receiveData subdataWithRange:NSMakeRange(11, 16)];
            NSData *parseData = [receiveData subdataWithRange:NSMakeRange(28, receiveData.length-28)];
            NSString *parseStr = [self aesDecryptWithData:parseData iv:ivData];
            NSError *error = [self getSocketErrorByCode:[self parseDataStr:parseStr key:@"Code"]];
            if (error) {
                if (failure) {
                    failure(error);
                }
            } else {
                if (success) {
                    success();
                }
            }
            
        } else {
            if (failure) {
                NSError *error =[NSError errorWithDomain:@"错误" code:110 userInfo:@{@"NSLocalizedDescription": @"数据长度不足8"}];
                failure(error);
            }
        }
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

#pragma -mark data
/**
 获取data长度
 
 @param str data
 @return data长度
 */
- (NSData *)getDataLen:(NSString *)str {
    int length = (int)str.length;
    Byte *len = malloc(4);
    len[3] = (Byte)(length >> 24);
    len[2] = (Byte)(length >> 16);
    len[1] = (Byte)(length >> 8);
    len[0] = (Byte)(length >> 0);
    return [NSData dataWithBytes:len length:4];
}

/**
 获取data包长度
 
 @param str data
 @return data包长度
 */
- (NSData *)getPLength:(NSString *)str {
    int length = (int)str.length + 4;
    Byte *pLen = malloc(4);
    pLen[3] = (Byte)(length >> 24);
    pLen[2] = (Byte)(length >> 16);
    pLen[1] = (Byte)(length >> 8);
    pLen[0] = (Byte)(length >> 0);
    return [NSData dataWithBytes:pLen length:4];
}

/**
 解析socket数据
 
 @param dataStr data
 @param key key
 @return 结果
 */
- (NSString *)parseDataStr:(NSString *)dataStr key:(NSString *)key {
    NSArray *array = [dataStr componentsSeparatedByString:@","];
    for (int i = 0; i < array.count; i ++) {
        NSString *res = [array objectAtIndex:i];
        if ([res containsString:key]) {
            NSString *resReturn = [[res componentsSeparatedByString:@"="] lastObject];
            return resReturn;
        }
    }
    return nil;
}

#pragma -mark socket error
/**
 根据code获取socket请求错误信息
 
 @param code 错误码
 @return error
 */
- (NSError *)getSocketErrorByCode:(NSString *)code {
    if ([code isEqualToString:@"0"]) {
        return nil;
    } else if ([code isEqualToString:@"1"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"不存在的命令"}];
    } else if ([code isEqualToString:@"2"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"数据长度错误"}];
    } else if ([code isEqualToString:@"3"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"数据包格式不正确，没有包含双回车换行"}];
    } else if ([code isEqualToString:@"4"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"发送未知错误"}];
    } else if ([code isEqualToString:@"5"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"命令不完整，如缺少命令关键字"}];
    } else if ([code isEqualToString:@"6"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"命令参数错误"}];
    } else if ([code isEqualToString:@"7"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"用户不存在或密码错误"}];
    } else if ([code isEqualToString:@"8"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"用户没有登录"}];
    } else if ([code isEqualToString:@"9"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"打开端口失败"}];
    } else if ([code isEqualToString:@"10"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"外部认证错误"}];
    } else if ([code isEqualToString:@"11"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"加密应用数据错误"}];
    } else if ([code isEqualToString:@"12"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"加密圈存错误"}];
    } else if ([code isEqualToString:@"13"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"NFC加密错误"}];
    }
    return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"未知错误"}];
}

#pragma -mark private AES
/**
 AES加密
 
 @param requestStr 请求值
 @param userNo 用户编号
 @return 结果
 */
- (NSString *)getAESEncryptWithRequestStr:(NSString *)requestStr userNo:(NSString *)userNo {
    NSMutableString *appendStr = [[NSMutableString alloc] initWithString:requestStr];
    [appendStr appendString:@",IMEI=A30217051680002"];
    [appendStr appendFormat:@",UserNo=%@",userNo];
    NSString *sign = [XTUtils sha256HashSign:appendStr, nil];
    [appendStr appendFormat:@",ABC=%@",sign];
    NSString *iv = sign.length >= 16 ? [sign substringWithRange:NSMakeRange(0, 16)] : KK_AESPSW;
    NSString *aes = [XTUtils aesEncryptWithString:appendStr key:KK_AESPSW iv:iv];
    NSString *result = [NSString stringWithFormat:@"IV=%@,%@", iv, aes];
    return result;
    
}

/**
 AES 解密
 
 @param data 数据
 @param ivData 偏移量
 @return 结果
 */
- (NSString *)aesDecryptWithData:(NSData *)data iv:(NSData *)ivData {
    return [XTUtils aesDecryptWithData:data key:KK_AESPSW iv:ivData];
}

@end

NS_ASSUME_NONNULL_END
