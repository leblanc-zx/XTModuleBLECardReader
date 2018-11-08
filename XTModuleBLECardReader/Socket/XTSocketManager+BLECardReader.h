//
//  XTSocketManager+BlueCard.h
//  XTSocket
//
//  Created by apple on 2018/11/6.
//  Copyright © 2018年 新天科技股份有限公司. All rights reserved.
//

#import "XTSocketManager.h"
#import "XTUtils+Date.h"
#import "XTUtils+PriceGroup.h"

NS_ASSUME_NONNULL_BEGIN

/**
 蓝牙读卡器Socket管理
 */
@interface XTSocketManager (BLECardReader)

/**
 发送外部认证消息
 
 @param ip socket ip
 @param port socket port
 @param seriaNum 卡序列号
 @param random8Hex 8位随机数
 @param userNo 用户编号
 @param success 成功
 @param failure 失败
 */
- (void)sendToAuthWithIp:(NSString *)ip port:(NSString *)port seriaNum:(NSString *)seriaNum random8Hex:(NSString *)random8Hex userNo:(NSString *)userNo success:(void(^)(NSString *auth))success failure:(void(^)(NSError *error))failure;

/**
 获取加密结果
 
 @param ip socket ip
 @param port socket port
 @param times 充值次数
 @param random 随机数
 @param cardMsg 卡信息
 @param userNo 用户编号
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
 @param validDays 购气有效期
 @param cardVerson 卡版本
 @param success 成功
 @param failure 失败
 */
- (void)getSocketDesResultWithIp:(NSString *)ip port:(NSString *)port times:(NSString *)times random:(NSString *)random cardMsg:(NSString *)cardMsg userNo:(NSString *)userNo priceChangeDic:(NSDictionary *)priceChangeDic validDays:(int)validDays cardVerson:(int)cardVerson success:(void(^)(NSString *desData, NSString *mac))success failure:(void(^)(NSError *error))failure;

/**
 获取圈存初始化结果
 
 @param ip socket ip
 @param port socket port
 @param cardID 卡号
 @param quanRes 发送的金额
 @param money 金额
 @param time 时间
 @param userNo 用户编号
 */
- (void)sendQuanWithIp:(NSString *)ip port:(NSString *)port cardID:(NSString *)cardID quanRes:(NSString *)quanRes money:(int)money time:(NSString *)time userNo:(NSString *)userNo success:(void(^)(NSString *sendQuan))success failure:(void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
