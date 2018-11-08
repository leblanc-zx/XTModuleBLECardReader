//
//  SuntorntSocket.h
//  BLECardReader
//
//  Created by apple on 2017/9/5.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XTAsyncSocket.h"
#import "XTAsyncUdpSocket.h"
#import "XTUtils+AES.h"

NS_ASSUME_NONNULL_BEGIN

@interface XTSocketManager : NSObject

@property (nonatomic) XTAsyncSocket *clientSocket;

+ (id)sharedManager;

/**
 连接socket
 
 @param ip 地址
 @param port 端口号
 @param success 成功
 @param failure 失败
 */
- (void)connectSocketWithIP:(NSString *)ip port:(NSString *)port success:(void(^)())success failure:(void(^)(NSError *error))failure;

/**
 发送消息
 
 @param data 数据
 @param success 成功
 @param failure 失败
 */
- (void)sendData:(NSData *)data success:(void(^)(NSData *receiveData))success failure:(void(^)(NSError *error))failure;

/**
 断开连接
 */
- (void)disconnect;

#pragma -mark login
/**
 socket登录
 
 @param userNo 用户编号
 @param success 成功
 @param failure 失败
 */
- (void)loginWithuserNo:(NSString *)userNo Socket:(void(^)())success failure:(void(^)(NSError *error))failure;

#pragma -mark data
/**
 获取data长度
 
 @param str data
 @return data长度
 */
- (NSData *)getDataLen:(NSString *)str;

/**
 获取data包长度
 
 @param str data
 @return data包长度
 */
- (NSData *)getPLength:(NSString *)str;

/**
 解析socket数据
 
 @param dataStr data
 @param key key
 @return 结果
 */
- (NSString *)parseDataStr:(NSString *)dataStr key:(NSString *)key;

#pragma -mark socket error
/**
 根据code获取socket请求错误信息
 
 @param code 错误码
 @return error
 */
- (NSError *)getSocketErrorByCode:(NSString *)code;

#pragma -mark private AES
/**
 AES加密
 
 @param requestStr 请求值
 @param userNo 用户编号
 @return 结果
 */
- (NSString *)getAESEncryptWithRequestStr:(NSString *)requestStr userNo:(NSString *)userNo;

/**
 AES 解密
 
 @param data 数据
 @param ivData 偏移量
 @return 结果
 */
- (NSString *)aesDecryptWithData:(NSData *)data iv:(NSData *)ivData;

@end

NS_ASSUME_NONNULL_END
