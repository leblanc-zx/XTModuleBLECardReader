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


@end

NS_ASSUME_NONNULL_END
