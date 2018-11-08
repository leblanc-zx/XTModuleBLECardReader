//
//  XTBLECardReaderMinimalis.h
//  XTBlueCard
//
//  Created by apple on 2018/11/6.
//  Copyright © 2018年 新天科技股份有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XTBLECardReaderManager.h"
#import "XTSocketManager+BLECardReader.h"
#import "XTUtils+Date.h"

NS_ASSUME_NONNULL_BEGIN

@interface XTBLECardReaderMinimalis : NSObject

+ (id)sharedManager;

/**
 扫描设备

 @param times 扫描时长
 @param result NSArray<<peripheralName>>
 */
- (void)scanWithTimes:(int)times result:(void(^)(NSArray *array))result;

/**
 打开设备，内部连接上蓝牙并且获取到正确的特征对象

 @param peripheralName 蓝牙对象名称
 @param result 结果
 */
- (void)openWithPeripheralName:(NSString *)peripheralName result:(void(^)(BOOL isSuccess, NSError *error))result;

/**
 * 关闭设备，内部断开蓝牙连接。
 */
- (void)closeDevice;

/**
 读卡

 @param userCode 用户编号
 @param success 成功：返回XTBlueCardInfo
 @param failure 失败
 */
- (void)readCardWithUserCode:(NSString *)userCode success:(void(^)(XTBlueCardInfo *model))success failure:(void(^)(NSError *error))failure;


/**
 充卡
 
 @param ip 加密机ip
 @param port 加密机端口
 @param userCode 用户编号
 @param rechargeNumber 充值金额(0.01元)/量(1.0)
 @param rechargeCount 充值次数
 @param validDays 购气有效期
 @param priceChangeDic 调价信息
 @{
    @"modPriceFlag": @"value",       <<是否需要调价：value=0不需要，value=1需要>>
    @"modPriceData1": @"value",      <<当前价格1信息集合，例：0.010000;1;0.010000;2;0.010000;3;0.010000;4;0.010000>>
    @"modPriceData2": @"value",      <<当前价格1信息集合，例：同modPriceData1>>
    @"newPriceData1": @"value",      <<新价格1信息集合，例：同modPriceData1>>
    @"newPriceData2": @"value",      <<新价格2信息集合，例：同modPriceData1>>
    @"newPriceStart": @"value",      <<新单价生效日期，16进制字符串>>
    @"priceEnableData": @"value",    <<价格启用循环，例：1&1&1;2&1&1;3&1&1;4&18&2;5&1&1;6&1&1;7&1&1;8&1&1;9&1&1;10&1&1;11&1&1;12&1&1>>
    @"prePriceEnableData": @"value", <<新价格启用循环，例：同priceEnableData>>
 }
 @param success 成功<<isWriteZero:反馈信息是否回写l0>>
 @param failure 失败
 */
- (void)rechargeWithIp:(NSString *)ip port:(NSString *)port userCode:(NSString *)userCode rechargeNumber:(NSString *)rechargeNumber rechargeCount:(int)rechargeCount validDays:(int)validDays priceChangeDic:(NSDictionary *)priceChangeDic success:(void(^)(BOOL isWriteZero))success failure:(void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
