//
//  XTSocketManager+BLECardReader.m
//  XTSocket
//
//  Created by apple on 2018/11/6.
//  Copyright © 2018年 新天科技股份有限公司. All rights reserved.
//

#import "XTSocketManager+BLECardReader.h"

@implementation XTSocketManager (BLECardReader)

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
- (void)sendToAuthWithIp:(NSString *)ip port:(NSString *)port seriaNum:(NSString *)seriaNum random8Hex:(NSString *)random8Hex userNo:(NSString *)userNo success:(void(^)(NSString *auth))success failure:(void(^)(NSError *error))failure {
    
    [self connectSocketWithIP:ip port:port success:^{
        
        __weak typeof(self) weakSelf = self;
        //socket登录
        [self loginWithuserNo:userNo Socket:^{
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            //外部认证
            [strongSelf getSocketAuthString:seriaNum random:random8Hex userNo:userNo success:^(NSString *authData) {
                [self.clientSocket disconnect];
                if (success) {
                    success(authData);
                }
                
            } failure:^(NSError *error) {
                [self.clientSocket disconnect];
                if (failure) {
                    failure(error);
                }
            }];
            
        } failure:^(NSError *error) {
            [self.clientSocket disconnect];
            if (failure) {
                failure(error);
            }
        }];
        
    } failure:^(NSError *error) {
        [self.clientSocket disconnect];
        if (failure) {
            failure(error);
        }
    }];
    
}

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
- (void)getSocketDesResultWithIp:(NSString *)ip port:(NSString *)port times:(NSString *)times random:(NSString *)random cardMsg:(NSString *)cardMsg userNo:(NSString *)userNo priceChangeDic:(NSDictionary *)priceChangeDic validDays:(int)validDays cardVerson:(int)cardVerson success:(void(^)(NSString *desData, NSString *mac))success failure:(void(^)(NSError *error))failure {
    
    [self connectSocketWithIP:ip port:port success:^{
        
        __weak typeof(self) weakSelf = self;
        //socket登录
        [self loginWithuserNo:userNo Socket:^{
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            //获取加密结果
            [strongSelf getSocketDesResult:times random:random cardMsg:cardMsg userNo:userNo priceChangeDic:priceChangeDic validDays:validDays cardVerson:cardVerson success:^(NSString * _Nonnull desData, NSString * _Nonnull mac) {
                
                [self.clientSocket disconnect];
                if (success) {
                    success(desData, mac);
                }
                
            } failure:^(NSError * _Nonnull error) {
                [self.clientSocket disconnect];
                if (failure) {
                    failure(error);
                }
            }];
            
        } failure:^(NSError *error) {
            [self.clientSocket disconnect];
            if (failure) {
                failure(error);
            }
        }];
        
    } failure:^(NSError *error) {
        [self.clientSocket disconnect];
        if (failure) {
            failure(error);
        }
    }];
    
}

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
- (void)sendQuanWithIp:(NSString *)ip port:(NSString *)port cardID:(NSString *)cardID quanRes:(NSString *)quanRes money:(int)money time:(NSString *)time userNo:(NSString *)userNo success:(void(^)(NSString *sendQuan))success failure:(void(^)(NSError *error))failure {
    
    [self connectSocketWithIP:ip port:port success:^{
        
        __weak typeof(self) weakSelf = self;
        //socket登录
        [self loginWithuserNo:userNo Socket:^{
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            //获取圈存初始化结果
            [strongSelf sendQuan:cardID quanRes:quanRes money:money time:time userNo:userNo success:^(NSString * _Nonnull sendQuan) {
                
                [self.clientSocket disconnect];
                if (success) {
                    success(sendQuan);
                }
                
            } failure:^(NSError * _Nonnull error) {
                [self.clientSocket disconnect];
                if (failure) {
                    failure(error);
                }
            }];
            
        } failure:^(NSError *error) {
            [self.clientSocket disconnect];
            if (failure) {
                failure(error);
            }
        }];
        
    } failure:^(NSError *error) {
        [self.clientSocket disconnect];
        if (failure) {
            failure(error);
        }
    }];
}

#pragma -mark private socket

/**
 获取 socket外部认证数据
 
 @param cardID 卡号
 @param random 随机数
 @param userNo 用户编号
 @return string
 */
- (NSString *)getSocketAuData:(NSString *)cardID random:(NSString *)random userNo:(NSString *)userNo {
    NSString *auData = [NSString stringWithFormat:@"[Request],Command=GetOuAuth,UserCardNo=00000000%@,Randm=%@,CmdInfo=2705",cardID, random];
    return [self getAESEncryptWithRequestStr:auData userNo:userNo];
}

/**
 外部认证
 
 @param cardID 用户卡号
 @param random 随机数
 @param userNo 用户编号
 */
- (void)getSocketAuthString:(NSString *)cardID random:(NSString *)random userNo:(NSString *)userNo success:(void(^)(NSString *authData))success failure:(void(^)(NSError *error))failure {
    
    NSString *auData = [self getSocketAuData:cardID random:random userNo:userNo];
    NSData *auDataLen = [self getDataLen:auData];
    NSData *auPlen = [self getPLength:auData];
    
    NSMutableData *sendData = [NSMutableData new];
    [sendData appendData:auPlen];
    [sendData appendData:auDataLen];
    
    [sendData appendData:[auData dataUsingEncoding:NSUTF8StringEncoding]];
    
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
                
                NSString *authData = [self parseDataStr:parseStr key:@"DesRandm"];
                if (success) {
                    success(authData);
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

/**
 获取加密结果 数据
 
 @param times 充值次数
 @param random 随机数
 @param cardMsg 卡信息
 @param userNo 用户编号
 @param priceChangeDic 价格修改字典
 @param validDays 购气有效期
 @param cardVerson 卡版本
 @return string
 */
- (NSString *)getSocketDesData:(NSString *)times random:(NSString *)random cardMsg:(NSString *)cardMsg userNo:(NSString *)userNo priceChangeDic:(NSDictionary *)priceChangeDic validDays:(int)validDays cardVerson:(int)cardVerson {
    
    NSMutableData *msgData = [[NSMutableData alloc] init];
    
    Byte byte[] = {[times intValue] & 0xff};
    
    //购气次数
    NSString *hexTimes = [XTUtils hexStringWithData:[NSData dataWithBytes:byte length:1]];
    
    //购气时间 + 充值有效期
    //NSString *oldTime = [cardMsg substringWithRange:NSMakeRange(8, 6)];
    //NSString *oldValidTime = [cardMsg substringWithRange:NSMakeRange(14, 6)];
    long time = validDays * 24 * 60 * 60;//[Utils getDayGap:oldTime s2:oldValidTime];
    NSString *newTime = [XTUtils timeStringFromDate:[NSDate date] formatter:@"yyMMdd"];
    NSString *newValidTime = [XTUtils timeStringWithTimeInterval:time sinceTime:newTime formatter:@"yyMMdd"];
    
    BOOL needChangePrice = [[priceChangeDic objectForKey:@"modPriceFlag"] isEqualToString:@"0"];
    NSString *str;
    //当前价格组
    if (needChangePrice) {
        //需要调价
        //当前价格1信息集合
        NSString *hexPriceArray1 = [XTUtils priceGroupHexStringWithPriceString:[priceChangeDic objectForKey:@"modPriceData1"]];
        //当前价格2信息集合
        NSString *hexPriceArray2 = [XTUtils priceGroupHexStringWithPriceString:[priceChangeDic objectForKey:@"modPriceData2"]];
        //新价格1信息集合
        NSString *hexNewPriceArray1 = [XTUtils priceGroupHexStringWithPriceString:[priceChangeDic objectForKey:@"newPriceData1"]];
        //新价格2信息集合
        NSString *hexNewPriceArray2 = [XTUtils priceGroupHexStringWithPriceString:[priceChangeDic objectForKey:@"newPriceData2"]];
        //新单价生效日期
        NSString *newPriceStart = [priceChangeDic objectForKey:@"newPriceStart"];
        //价格启用循环
        NSString *priceStartCycle = [XTUtils priceStartRepeatHexStringWithPriceStartString:[priceChangeDic objectForKey:@"priceEnableData"]];
        //336
        str = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@",[cardMsg substringWithRange:NSMakeRange(0, 8)], newTime, newValidTime, [cardMsg substringWithRange:NSMakeRange(20, 22)], hexTimes, [cardMsg substringWithRange:NSMakeRange(44, 60)],hexPriceArray1,hexPriceArray2,hexNewPriceArray1,hexNewPriceArray2,newPriceStart,priceStartCycle];
        
    } else {
        //不需要调价
        str = [NSString stringWithFormat:@"%@%@%@%@%@%@",[cardMsg substringWithRange:NSMakeRange(0, 8)], newTime, newValidTime, [cardMsg substringWithRange:NSMakeRange(20, 22)], hexTimes, [cardMsg substringWithRange:NSMakeRange(44, 292)]];
    }
    
    NSData *data = [XTUtils dataWithHexString:str];
    [msgData appendData:data];
    
    //校验和
    NSData *sumData = [XTUtils checksumDataWithOriginData:data];
    [msgData appendData:sumData];
    
    if (cardVerson == 2) {
        if (needChangePrice) {
            //新价格启用循环
            NSString *newPriceStartCycle = [XTUtils priceStartRepeatHexStringWithPriceStartString:[priceChangeDic objectForKey:@"prePriceEnableData"]];
            NSString *lastStr = [NSString stringWithFormat:@"%@%@",newPriceStartCycle,[cardMsg substringWithRange:NSMakeRange(386, 36)]];
            [msgData appendData:[XTUtils dataWithHexString:lastStr]];
        } else {
            [msgData appendData:[XTUtils dataWithHexString:[cardMsg substringWithRange:NSMakeRange(338, 84)]]];
        }
    }
    
    NSString *msg = [XTUtils hexStringWithData:msgData];
    
    NSLog(@"======需加密的参数修改后：%@======",msg);
    
    NSString *desData = [NSString stringWithFormat:@"[Request],Command=GetDesMac,UserData=%@,Randm=%@",msg,random];
    return [self getAESEncryptWithRequestStr:desData userNo:userNo];
}

/**
 获取加密结果
 
 @param times 充值次数
 @param random 随机数
 @param cardMsg 卡信息
 @param userNo 用户编号
 @param priceChangeDic 价格修改字典 @{
 @"modPriceFlag": @"value",      //价格修改标志
 @"modPriceData1": @"value",     //当前价格1信息集合
 @"modPriceData2": @"value",     //当前价格2信息集合
 @"newPriceData1": @"value",     //新价格1信息集合
 @"newPriceData2": @"value",     //新价格2信息集合
 @"newPriceStart": @"value",     //新价格启用时间
 @"priceEnableData": @"value",   //价格启用循环信息
 @"prePriceEnableData": @"value",//预调价格启用循环信息
 }
 @param validDays 购气有效期
 @param cardVerson 卡版本
 @param success 成功
 @param failure 失败
 */
- (void)getSocketDesResult:(NSString *)times random:(NSString *)random cardMsg:(NSString *)cardMsg userNo:(NSString *)userNo priceChangeDic:(NSDictionary *)priceChangeDic validDays:(int)validDays cardVerson:(int)cardVerson success:(void(^)(NSString *desData, NSString *mac))success failure:(void(^)(NSError *error))failure {
    
    NSString *macData = [self getSocketDesData:times random:random cardMsg:cardMsg userNo:userNo priceChangeDic:priceChangeDic validDays:validDays cardVerson:cardVerson];
    NSData *macPLength = [self getPLength:macData];
    NSData *macDLen = [self getDataLen:macData];
    
    NSMutableData *sendData = [[NSMutableData alloc] init];
    [sendData appendData:macPLength];
    [sendData appendData:macDLen];
    [sendData appendData:[macData dataUsingEncoding:NSUTF8StringEncoding]];
    
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
                
                NSString *desData = [self parseDataStr:parseStr key:@"DesData"];
                NSString *mac = [self parseDataStr:parseStr key:@"MAC"];
                if (success) {
                    success(desData, mac);
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

/**
 访问圈存加密
 
 @param cardID 卡号
 @param quanRes 金额数据
 @param money 金额
 @param time 时间
 @param userNo 用户编号
 @return string
 */
- (NSString *)getQuanData:(NSString *)cardID quanRes:(NSString *)quanRes money:(int)money time:(NSString *)time userNo:(NSString *)userNo {
    NSString *moneyStr = [XTUtils hexStringWithData:[XTUtils dataWithLong:money length:4]];
    NSString *loadData = [NSString stringWithFormat:@"[Request],Command=GetLoadMac,UserCardNo=00000000%@,InitializeLoad=%@,LoadMoney=%@,LoadDayTime=%@",cardID,quanRes,moneyStr,time];
    return [self getAESEncryptWithRequestStr:loadData userNo:userNo];
}

/**
 获取圈存初始化结果
 
 @param cardID 卡号
 @param quanRes 发送的金额
 @param money 金额
 @param time 时间
 @param userNo 用户编号
 */
- (void)sendQuan:(NSString *)cardID quanRes:(NSString *)quanRes money:(int)money time:(NSString *)time userNo:(NSString *)userNo success:(void(^)(NSString *sendQuan))success failure:(void(^)(NSError *error))failure {
    
    NSString *loadD = [self getQuanData:cardID quanRes:quanRes money:money time:time userNo:userNo];
    //NSLog(@"======loadD：%@======",loadD);
    NSData *loadPlength = [self getPLength:loadD];
    NSData *loadDlen = [self getDataLen:loadD];
    
    NSMutableData *sendData = [NSMutableData new];
    [sendData appendData:loadPlength];
    [sendData appendData:loadDlen];
    [sendData appendData:[loadD dataUsingEncoding:NSUTF8StringEncoding]];
    
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
                
                NSString *sendQuan = [self parseDataStr:parseStr key:@"MAC"];
                if (success) {
                    success(sendQuan);
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

@end
