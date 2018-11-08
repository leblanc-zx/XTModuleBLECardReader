//
//  XTSocketManager+BLECardReader.m
//  XTSocket
//
//  Created by apple on 2018/11/6.
//  Copyright © 2018年 新天科技股份有限公司. All rights reserved.
//

#import "XTSocketManager+BLECardReader.h"

NSString *const KK_AESPSW = @"xt0371@126.com|*";

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

/**
 外部认证
 
 @param cardID 用户卡号
 @param random 随机数
 @param userNo 用户编号
 */
- (void)getSocketAuthString:(NSString *)cardID random:(NSString *)random userNo:(NSString *)userNo success:(void(^)(NSString *authData))success failure:(void(^)(NSError *error))failure {
    
    NSString *auStr = [NSString stringWithFormat:@"[Request],Command=GetOuAuth,UserCardNo=00000000%@,Randm=%@,CmdInfo=2705",cardID, random];
    NSString *auData = [self getAESEncryptWithRequestStr:auStr userNo:userNo];
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
 获取圈存初始化结果
 
 @param cardID 卡号
 @param quanRes 发送的金额
 @param money 金额
 @param time 时间
 @param userNo 用户编号
 */
- (void)sendQuan:(NSString *)cardID quanRes:(NSString *)quanRes money:(int)money time:(NSString *)time userNo:(NSString *)userNo success:(void(^)(NSString *sendQuan))success failure:(void(^)(NSError *error))failure {
    
    NSString *moneyStr = [XTUtils hexStringWithData:[XTUtils dataWithLong:money length:4]];
    NSString *loadStr = [NSString stringWithFormat:@"[Request],Command=GetLoadMac,UserCardNo=00000000%@,InitializeLoad=%@,LoadMoney=%@,LoadDayTime=%@",cardID,quanRes,moneyStr,time];
    NSString *loadD = [self getAESEncryptWithRequestStr:loadStr userNo:userNo];
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
    return [XTUtils aesDecryptWithData:data key:KK_AESPSW iv:[XTUtils UTF8StringWithData:ivData]];
}

@end
