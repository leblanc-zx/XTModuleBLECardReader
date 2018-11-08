//
//  XTBLECardReaderMinimalis.m
//  XTBlueCard
//
//  Created by apple on 2018/11/6.
//  Copyright © 2018年 新天科技股份有限公司. All rights reserved.
//

#import "XTBLECardReaderMinimalis.h"

@interface XTBLECardReaderMinimalis ()

@property (nonatomic, copy, readonly) NSString *ip;             //加密机ip
@property (nonatomic, copy, readonly) NSString *port;           //加密机端口
@property (nonatomic, copy, readonly) NSString *userCode;       //用户编号
@property (nonatomic, assign, readonly) int valWay;             //计费方式(55：计量 11：计金额)
@property (nonatomic, copy, readonly) NSString *rechargeNumber; //充值金额(0.01)/量(1.0)
@property (nonatomic, assign, readonly) int rechargeCount;      //充值次数
@property (nonatomic, assign, readonly) int validDays;          //购气有效期
@property (nonatomic, copy, readonly) NSDictionary *priceChangeDic; //调价信息
@property (nonatomic, copy, readonly) NSString *serialNum;      //序列号
@property (nonatomic, copy) void(^rechargeSuccess)(BOOL isWriteZero);//充值成功block
@property (nonatomic, copy) void(^rechargeFailure)(NSError *error); //充值失败block

@end

@implementation XTBLECardReaderMinimalis

static id _instace;

- (id)init
{
    static id obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((obj = [super init])) {
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
 扫描设备
 
 @param times 扫描时长
 @param result NSArray<<peripheralName>>
 */
- (void)scanWithTimes:(int)times result:(void(^)(NSArray *array))result {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XTBLECardReaderManager *manager = [XTBLECardReaderManager sharedManager];
        NSArray *array = [[NSArray alloc] initWithArray:[manager scan:times]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) {
                result(array);
            }
        });
    });
}

/**
 打开设备，内部连接上蓝牙并且获取到正确的特征对象
 
 @param peripheralName 蓝牙对象名称
 @param result 结果
 */
- (void)openWithPeripheralName:(NSString *)peripheralName result:(void(^)(BOOL isSuccess, NSError *error))result {
    
    if (peripheralName.length <= 0) {
        if (result) {
            result(NO, [NSError errorWithDomain:@"错误" code:110 userInfo:@{@"NSLocalizedDescription": @"请选择蓝牙"}]);
        }
        return;
    }
    
    XTBLECardReaderManager *card = [XTBLECardReaderManager sharedManager];
    
    if (![card isOpened]) {
        
        //连接蓝牙
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSError *error;
            [card openWithName:peripheralName time_s:10 error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [card closeDevice];
                    if (result) {
                        result(NO, error);
                    }
                    return;
                }
                if (result) {
                    result(YES, nil);
                }
            });
            
        });
        
    } else {
        if (result) {
            result(YES, nil);
        }
    }
}

/**
 * 关闭设备，内部断开蓝牙连接。
 */
- (void)closeDevice {
    [[XTBLECardReaderManager sharedManager] closeDevice];
}

/**
 读卡
 
 @param userCode 用户编号
 @param success 成功：返回XTBlueCardInfo
 @param failure 失败
 */
- (void)readCardWithUserCode:(NSString *)userCode success:(void(^)(XTBlueCardInfo *model))success failure:(void(^)(NSError *error))failure {
    
    XTBLECardReaderManager *cardManager = [XTBLECardReaderManager sharedManager];
    if ([cardManager isOpened]) {
        //1.上电
        [self powerOnWithCard:cardManager result:^(BOOL isSuccess, NSError *error) {
            if (isSuccess) {
                
                //2.开始读卡
                [self readCardWithUserCode:userCode result:^(XTBlueCardInfo *blueCardInfo, NSError *error) {
                    if (error) {
                        if (failure) {
                            failure(error);
                        }
                    } else {
                        success(blueCardInfo);
                    }
                }];
                
            } else {
                if (failure) {
                    failure(error);
                }
            }
        }];
    } else {
        if (failure) {
            failure([NSError errorWithDomain:@"错误" code:110 userInfo:@{@"NSLocalizedDescription": @"请连接蓝牙"}]);
        }
    }
   
}

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
 @param success 成功<<isWriteZero:反馈信息是否回写l0>>
 @param failure 失败
 }
 */
- (void)rechargeWithIp:(NSString *)ip port:(NSString *)port userCode:(NSString *)userCode rechargeNumber:(NSString *)rechargeNumber rechargeCount:(int)rechargeCount validDays:(int)validDays priceChangeDic:(NSDictionary *)priceChangeDic success:(void(^)(BOOL isWriteZero))success failure:(void(^)(NSError *error))failure {
    
    _ip = ip;
    _port = port;
    _userCode = userCode;
    _rechargeNumber = rechargeNumber;
    _rechargeCount = rechargeCount;
    _validDays = validDays;
    _priceChangeDic = priceChangeDic;
    self.rechargeSuccess = success;
    self.rechargeFailure = failure;
    
    //1.充值前先读卡
    //__weak typeof(self) weakSelf = self;
    [self readCardWithUserCode:userCode success:^(XTBlueCardInfo * _Nonnull model) {
        
        if (!model) {
            if (self.rechargeFailure) {
                self.rechargeFailure([NSError errorWithDomain:@"错误" code:110 userInfo:@{@"NSLocalizedDescription": @"请先读卡"}]);
            }
            return;
        }
        
//        if ([model.thisMoney intValue] != 0) {
//            if (self.rechargeFailure) {
//                self.rechargeFailure([NSError errorWithDomain:@"错误" code:110 userInfo:@{@"NSLocalizedDescription": @"请先刷表"}]);
//            }
//            return;
//        }
        
        _valWay = model.valWay;
        //2.开始充值
        [self rechargeStart];
        
    } failure:^(NSError * _Nonnull error) {
        if (self.rechargeFailure) {
            self.rechargeFailure(error);
        }
    }];
}

#pragma -mark private methods
/**
 上电
 */
- (void)powerOnWithCard:(XTBLECardReaderManager *)card result:(void(^)(BOOL isSuccess, NSError *error))result {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error;
        [card powerOnWithError:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (result) {
                    result(NO, error);
                }
                return;
            }
            if (result) {
                result(YES, nil);
            }
            
        });
    });
    
}

/**
 下电
 */
- (void)powerOffResult:(void(^)(BOOL isSuccess, NSError *error))result {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XTBLECardReaderManager *card = [XTBLECardReaderManager sharedManager];
        NSError *error;
        [card powerOffWithError:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error) {
                if (result) {
                    result(NO, error);
                }
                return;
            }
            
            if (result) {
                result(YES, nil);
            }
        });
    });
    
    
}

/**
 读卡信息
 */
- (void)readCardWithUserCode:(NSString *)userCode result:(void(^)(XTBlueCardInfo *blueCardInfo, NSError *error))result {
    
    XTBLECardReaderManager *card = [XTBLECardReaderManager sharedManager];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error;
        XTBlueCardInfo *model = [card readCardWithError:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error) {
                if (result) {
                    result(nil, error);
                }
                return;
            }
            
            if ([model.userCode isEqualToString:@"00000000000000000000"]) {
                if (result) {
                    result(nil, [NSError errorWithDomain:@"错误" code:110 userInfo:@{@"NSLocalizedDescription": @"此卡未开户，请到管理系统开户"}]);
                }
                return;
            }
            //判断两个用户是否一致
            if (![userCode isEqualToString:model.userCode]) {
                NSLog(@"用户卡号==%@",model.userCode);
                if (result) {
                    result(nil, [NSError errorWithDomain:@"错误" code:110 userInfo:@{@"NSLocalizedDescription": @"用户编号不一致，请更换正确的用户卡"}]);
                }
                return;
            }
            
            if (result) {
                result(model, nil);
            }
            
        });
    });
    
}

/*------------------------以下是充值方法-------------------------*/
- (void)rechargeStart {
    
    //1.获取用户卡序列号
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XTBLECardReaderManager *card = [XTBLECardReaderManager sharedManager];
        NSError *error;
        NSString *serialNum = [card getSerialNumWithError:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (self.rechargeFailure) {
                    self.rechargeFailure(error);
                }
                return;
            }
            
            _serialNum = serialNum;
            NSLog(@"======获取用户卡序列号：%@======",serialNum);
            
            [self enter3F02];
            
        });
    });
    
}

- (void)enter3F02 {
    
    //2.进入3F02目录
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XTBLECardReaderManager *card = [XTBLECardReaderManager sharedManager];
        NSError *error;
        BOOL enter = [card enter3F02WithError:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (self.rechargeFailure) {
                    self.rechargeFailure(error);
                }
                return;
            }
            if (!enter) {
                if (self.rechargeFailure) {
                    self.rechargeFailure([NSError errorWithDomain:@"错误" code:110 userInfo:@{@"NSLocalizedDescription": @"进入3F02目录失败"}]);
                }
                return;
            }
            NSLog(@"======进入3F02目录======");
            
            [self getRandom8Hex];
            
        });
    });
}

- (void)getRandom8Hex {
    //3.取8个字节随机数
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XTBLECardReaderManager *card = [XTBLECardReaderManager sharedManager];
        NSError *error;
        NSString *random8Hex = [card getRandom8HexWithError:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (self.rechargeFailure) {
                    self.rechargeFailure(error);
                }
                return;
            }
            NSLog(@"======8个字节随机数：%@======",random8Hex);
            
            [self sendToAuth_4WithSerialNum:self.serialNum random8Hex:random8Hex];
            
        });
    });
    
}

- (void)sendToAuth_4WithSerialNum:(NSString *)serialNum random8Hex:(NSString *)random8Hex {
    //4.发送外部认证消息
    XTSocketManager *socket = [XTSocketManager sharedManager];
    __weak typeof(self) weakSelf = self;
    
    [socket sendToAuthWithIp:self.ip port:self.port seriaNum:serialNum random8Hex:random8Hex userNo:self.userCode success:^(NSString * _Nonnull auth) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSLog(@"======发送外部认证消息：%@======",auth);
        
        [strongSelf transOutAuth:auth];
    } failure:^(NSError * _Nonnull error) {
        if (self.rechargeFailure) {
            self.rechargeFailure(error);
        }
    }];
}

- (void)transOutAuth:(NSString *)auth {
    //5.外部认证指令
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XTBLECardReaderManager *card = [XTBLECardReaderManager sharedManager];
        NSError *error;
        [card transOutAuth:auth error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (self.rechargeFailure) {
                    self.rechargeFailure(error);
                }
                return;
            }
            NSLog(@"======外部认证指令成功======");
            
            [self random4Hex];
        });
    });
    
}

- (void)random4Hex {
    //6.获取4个字节随机数
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XTBLECardReaderManager *card = [XTBLECardReaderManager sharedManager];
        NSError *error;
        NSString *random4Hex = [card getRandom4HexWithError:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (self.rechargeFailure) {
                    self.rechargeFailure(error);
                }
                return;
            }
            NSLog(@"======获取4个字节随机数：%@======",random4Hex);
            
            [self getCardMsgWithRandom4Hex:random4Hex];
            
        });
    });
    
}

- (void)getCardMsgWithRandom4Hex:(NSString *)random4Hex {
    //7.获取卡的应用信息文件
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XTBLECardReaderManager *card = [XTBLECardReaderManager sharedManager];
        NSError *error;
        NSString *cardMsg = [card getCardMsgWithError:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (self.rechargeFailure) {
                    self.rechargeFailure(error);
                }
                return;
            }
            NSLog(@"======获取卡的应用信息文件：%@======",cardMsg);
            
            [self getSocketDesWithRandom4Hex:random4Hex cardMsg:cardMsg];
            
        });
    });
    
}

- (void)getSocketDesWithRandom4Hex:(NSString *)random4Hex cardMsg:(NSString *)cardMsg {
    //8.获取加密结果
    XTSocketManager *socket = [XTSocketManager sharedManager];
    XTBLECardReaderManager *card = [XTBLECardReaderManager sharedManager];
    __weak typeof(self) weakSelf = self;
    
    [socket getSocketDesResultWithIp:self.ip port:self.port times:[NSString stringWithFormat:@"%d",self.rechargeCount] random:random4Hex cardMsg:cardMsg userNo:self.userCode priceChangeDic:self.priceChangeDic validDays:self.validDays cardVerson:card.cardVerson success:^(NSString * _Nonnull desData, NSString * _Nonnull mac) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSLog(@"======获取加密结果：desData=%@,mac=%@======",desData, mac);
        [strongSelf desData:desData mac:mac];
        
    } failure:^(NSError * _Nonnull error) {
        if (self.rechargeFailure) {
            self.rechargeFailure(error);
        }
    }];
   
}

- (void)desData:(NSString *)desData mac:(NSString *)mac {
    
    //9.发送加密数据指令
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XTBLECardReaderManager *card = [XTBLECardReaderManager sharedManager];
        NSError *error;
        [card sendDesData:desData mac:mac error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (self.rechargeFailure) {
                    self.rechargeFailure(error);
                }
                return;
            }
            NSLog(@"======送加密数据指令成功======");
            
            [self sendMoney];
        });
    });
    
}

- (void)sendMoney {
    //10.发送金额数据
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XTBLECardReaderManager *card = [XTBLECardReaderManager sharedManager];
        NSError *error;
        
        int fen;
        if (self.valWay == 55) {
            //计量
            fen = (int)ceil([self.rechargeNumber doubleValue] * 10);
        } else {
            //计金额
            fen = (int)ceil([self.rechargeNumber doubleValue] * 100);
        }
        NSString *sendMoney = [card sendMoney:fen error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (self.rechargeFailure) {
                    self.rechargeFailure(error);
                }
                return;
            }
            NSLog(@"======发送金额数据成功：%@======",sendMoney);
            [self sendQuanWithMoney:sendMoney fen:fen];
        });
    });
    
    
}

- (void)sendQuanWithMoney:(NSString *)sendMoney fen:(int)fen {
    //11.加密圈存
    XTSocketManager *socket = [XTSocketManager sharedManager];
    __weak typeof(self) weakSelf = self;
    NSString *time = [XTUtils timeStringFromDate:[NSDate date] formatter:@"yyyyMMddHHmmss"];
    
    [socket sendQuanWithIp:self.ip port:self.port cardID:self.serialNum quanRes:sendMoney money:fen time:time userNo:self.userCode success:^(NSString * _Nonnull sendQuan) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSLog(@"======加密圈存结果：sendQuan=%@======",sendQuan);
        [strongSelf sendQuanMac:sendQuan time:time];
        
    } failure:^(NSError * _Nonnull error) {
        
        if (self.rechargeFailure) {
            self.rechargeFailure(error);
        }
        
    }];
}

- (void)sendQuanMac:(NSString *)sendQuan time:(NSString *)time {
    
    //12.发送加密后圈存数据---在这一步的时候，金额已经充值成功了
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XTBLECardReaderManager *card = [XTBLECardReaderManager sharedManager];
        NSError *error;
        NSString *sendQuanMac = [card sendQuanMac:time mac:sendQuan error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (self.rechargeFailure) {
                    self.rechargeFailure(error);
                }
                return;
            }
            NSLog(@"======发送加密后圈存数据成功：%@======",sendQuanMac);
            
            [self getRandom8Hex_13];
            
        });
    });
    
}

- (void)getRandom8Hex_13 {
    //13.获取8个字节随机数
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XTBLECardReaderManager *card = [XTBLECardReaderManager sharedManager];
        NSError *error;
        NSString *random8Hex = [card getRandom8HexWithError:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                //在这一步卡已经充值成功了，但是还没将反馈信息回写0
                if (self.rechargeSuccess) {
                    self.rechargeSuccess(NO);
                }
                return;
            }
            NSLog(@"======获取8个字节随机数2：%@======",random8Hex);
            [self sendToAuth_14WithRandom8Hex:random8Hex];
        });
    });
    
}

- (void)sendToAuth_14WithRandom8Hex:(NSString *)random8Hex {
    //14.发送外部认证消息
    XTSocketManager *socket = [XTSocketManager sharedManager];
    __weak typeof(self) weakSelf = self;
    
    [socket sendToAuthWithIp:self.ip port:self.port seriaNum:self.serialNum random8Hex:random8Hex userNo:self.userCode success:^(NSString * _Nonnull auth) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSLog(@"======发送外部认证消息：%@======",auth);
        
        [strongSelf transOutAuth2:auth];
    } failure:^(NSError * _Nonnull error) {
        //在这一步卡已经充值成功了，但是还没将反馈信息回写0
        if (self.rechargeSuccess) {
            self.rechargeSuccess(NO);
        }
    }];

}

- (void)transOutAuth2:(NSString *)auth {
    
    //15.外部认证指令
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XTBLECardReaderManager *card = [XTBLECardReaderManager sharedManager];
        NSError *error;
        [card transOutAuth:auth error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                //在这一步卡已经充值成功了，但是还没将反馈信息回写0
                if (self.rechargeSuccess) {
                    self.rechargeSuccess(NO);
                }
                return;
            }
            NSLog(@"======外部认证指令2成功======");
            [self selectFile];
        });
    });
    
    
}

- (void)selectFile {
    //16.选择文件
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XTBLECardReaderManager *card = [XTBLECardReaderManager sharedManager];
        NSError *error;
        [card selectFileWithError:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                //在这一步卡已经充值成功了，但是还没将反馈信息回写0
                if (self.rechargeSuccess) {
                    self.rechargeSuccess(NO);
                }
                return;
            }
            NSLog(@"======选择文件成功======");
            [self writeToZero];
        });
    });
    
    
}

- (void)writeToZero {
    //17.将反馈信息全部字节写0
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XTBLECardReaderManager *card = [XTBLECardReaderManager sharedManager];
        NSError *error;
        [card writeToZeroWithError:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error) {
                //在这一步卡已经充值成功了，但是还没将反馈信息回写0
                if (self.rechargeSuccess) {
                    self.rechargeSuccess(NO);
                }
                return;
            }
            NSLog(@"======将反馈信息全部字节写0成功======");
            
            //在这一步卡已经充值成功了，但是还没将反馈信息回写0
            if (self.rechargeSuccess) {
                self.rechargeSuccess(YES);
            }
            
            //下电
            [self powerOffResult:nil];
            
        });
    });
    
}


@end
