//
//  BlueToothRequest.h
//  SuntrontBlueTooth
//
//  Created by apple on 2018/1/1.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XTBlueCardInfo.h"
#import "XTUtils.h"

@interface XTBLECardReaderManager : NSObject

@property (nonatomic, assign, readonly) int cardVerson;

+ (id)sharedManager;


/**
 * 扫描设备，发现并且过滤出支持的蓝牙设备。
 *
 * @param[in] time_s 扫描超时，秒为单位。
 *
 * @return 设备名称列表（即内部为NSString*列表）。
 */
- (NSArray *)scan:(int)time_s;

/**
 * 打开设备，内部连接上蓝牙并且获取到正确的特征对象。
 *
 * @param[in] name 设备名称，即蓝牙名称。
 * @param[in] time_s 打开超时，秒为单位。
 */
- (void)openWithName:(NSString *)name time_s:(int)time_s error:(NSError **)error;

/**
 * 关闭设备，内部断开蓝牙连接。
 */
- (void)closeDevice;

/**
 * 设备是否打开。
 *
 * @return YES-设备已打开 NO-设备未打开。
 */
- (BOOL)isOpened;

/**
 * 重新打开设备，将会使用上次成功打开的参数尝试再次打开设备。
 *
 * @return YES-成功 NO-失败。
 */
- (BOOL)reopen;

/**
 上电
 
 @param error 错误
 @return string
 */
- (NSString *)powerOnWithError:(NSError **)error;

/**
 下电
 
 @param error 错误
 @return string
 */
- (NSString *)powerOffWithError:(NSError **)error;

/**
 读卡
 
 @param error error
 @return CardInfoModel
 */
- (XTBlueCardInfo *)readCardWithError:(NSError **)error;

/**
 获取用户卡序列号
 
 @param error 错误
 @return string
 */
- (NSString *)getSerialNumWithError:(NSError **)error;

/**
 进入3F02目录
 
 @param error 错误
 @return bool
 */
- (BOOL)enter3F02WithError:(NSError **)error;

/**
 获取8个字节随机数
 
 @param error 错误
 @return bool
 */
- (NSString *)getRandom8HexWithError:(NSError **)error;

/**
 外部认证指令
 
 @param error 错误
 @return string
 */
- (NSString *)transOutAuth:(NSString *)auth error:(NSError **)error;

/**
 获取4个字节随机数
 
 @param error error
 @return string
 */
- (NSString *)getRandom4HexWithError:(NSError **)error;

/**
 获取卡的应用信息文件
 
 @param error error
 @return string
 */
- (NSString *)getCardMsgWithError:(NSError **)error;

/**
 发送加密数据指令
 
 @param desData desData
 @param mac mac
 */
- (NSString *)sendDesData:(NSString *)desData mac:(NSString *)mac error:(NSError **)error;

/**
 发送金额数据
 
 @param money 分
 @param error 错误
 @return string
 */
- (NSString *)sendMoney:(int)money error:(NSError **)error;

/**
 发送加密后圈存数据
 
 @param time 时间
 @param mac 圈存数据
 @param error 错误
 @return string
 */
- (NSString *)sendQuanMac:(NSString *)time mac:(NSString *)mac error:(NSError **)error;

/**
 选择文件
 
 @param error 错误
 @return string
 */
- (NSString *)selectFileWithError:(NSError **)error;

/**
 将反馈信息全部字节写0
 
 @param error 错误
 @return string
 */
- (NSString *)writeToZeroWithError:(NSError **)error;


@end
