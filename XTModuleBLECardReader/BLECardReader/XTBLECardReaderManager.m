//
//  BlueToothRequest.m
//  SuntrontBlueTooth
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "XTBLECardReaderManager.h"
#if TARGET_IPHONE_SIMULATOR
//nothing
#else
#import "iccreader.h"
#import "decardiccreader.h"
#endif

@interface XTBLECardReaderManager ()

#if TARGET_IPHONE_SIMULATOR
//nothing
#else
@property (nonatomic, strong) DecardIccReader *reader;
#endif

@end

@implementation XTBLECardReaderManager

static id _instace;

- (id)init
{
    static id obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((obj = [super init])) {
            _cardVerson = 1;
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

#if TARGET_IPHONE_SIMULATOR
//nothing
#else
/**
 * 扫描设备，发现并且过滤出支持的蓝牙设备。
 *
 * @param[in] time_s 扫描超时，秒为单位。
 *
 * @return 设备名称列表（即内部为NSString*列表）。
 */
- (NSArray *)scan:(int)time_s {
    return [self.reader scan:time_s];
}

/**
 * 打开设备，内部连接上蓝牙并且获取到正确的特征对象。
 *
 * @param[in] name 设备名称，即蓝牙名称。
 * @param[in] time_s 打开超时，秒为单位。
 */
- (void)openWithName:(NSString *)name time_s:(int)time_s error:(NSError **)error {
    if (name.length == 0) {
        *error = [NSError errorWithDomain:@"错误" code:110 userInfo:@{@"NSLocalizedDescription": @"请传入蓝牙名称"}];
        return;
    }
    BOOL result = [self.reader openWithName:name time_s:time_s];
    if (!result) {
        *error = [NSError errorWithDomain:@"错误" code:110 userInfo:@{@"NSLocalizedDescription": @"连接失败"}];
    }
}

/**
 * 关闭设备，内部断开蓝牙连接。
 */
- (void)closeDevice {
    [self.reader close];
}

/**
 * 设备是否打开。
 *
 * @return YES-设备已打开 NO-设备未打开。
 */
- (BOOL)isOpened {
    return [self.reader isOpened];
}

/**
 * 重新打开设备，将会使用上次成功打开的参数尝试再次打开设备。
 *
 * @return YES-成功 NO-失败。
 */
- (BOOL)reopen {
    return [self.reader reopen];
}

/**
 上电

 @param error 错误
 @return string
 */
- (NSString *)powerOnWithError:(NSError **)error {
    NSData *data = [XTUtils dataWithHexString:@"FF700200020002"];
    return [self sendData:data error:error];
}

/**
 下电
 
 @param error 错误
 @return string
 */
- (NSString *)powerOffWithError:(NSError **)error {
    NSData *data = [XTUtils dataWithHexString:@"FF700300020002"];
    return [self sendData:data error:error];
}


/**
 读卡

 @param error error
 @return CardInfoModel
 */
- (XTBlueCardInfo *)readCardWithError:(NSError **)error {
    NSString *appLen = @"00C8";
    NSString *returnLen = @"00C8";
    
    //1.进入目录
    NSString *data = [self sendData:[XTUtils dataWithHexString:@"00A40000023F00"] error:error];
    if (*error) {
        return nil;
    }
    NSLog(@"======进入目录(00)：%@======",data);
    
    //2.读二进制文件
    XTBlueCardInfo *cardInfo = [[XTBlueCardInfo alloc] init];
    data = [self sendData:[XTUtils dataWithHexString:@"00B095003C"] error:error];
    if (*error) {
        return cardInfo;
    }
    NSLog(@"======读二进制文件：%@======",data);
    [self parseCommonInfo:cardInfo string:data error:error];
    if (*error) {
        return cardInfo;
    }
    
    //3.进入目录(02)
    data = [self sendData:[XTUtils dataWithHexString:@"00A40000023F02"] error:error];
    if (*error) {
        return cardInfo;
    }
    NSLog(@"======进入目录(02)：%@======",data);
    
    //4.读钱包数据
    data = [self sendData:[XTUtils dataWithHexString:@"805C000204"] error:error];
    if (*error) {
        return cardInfo;
    }
    cardInfo.thisMoney = [NSString stringWithFormat:@"%ld",[XTUtils positiveLongWithData:[XTUtils dataWithHexString:data]]];
    NSLog(@"======读钱包数据：%@======",cardInfo.thisMoney);
    
    //5.读取卡中标志信息文件
    data = [self sendData:[XTUtils dataWithHexString:@"00B0990001"] error:error];
    if (!*error && data.length > 0) {
        _cardVerson = 2;
        appLen = @"00D3";
        returnLen = @"00E8";
    }
    NSLog(@"======卡中标志信息文件：%@======",data);
    
    //6.读用户应用信息文件
    data = [self sendData:[XTUtils dataWithHexString:[NSString stringWithFormat:@"00B081%@",appLen]] error:error];
    NSLog(@"======应用指令：%@======",[NSString stringWithFormat:@"00B081%@",appLen]);
    if (*error) {
        return cardInfo;
    }
    NSLog(@"======读用户应用信息文件：%@======",data);
    [self parseAppliInfo:cardInfo string:data len:appLen error:error];
    if (*error) {
        return cardInfo;
    }
    
    //7.读燃气表回馈信息文件
    data = [self sendData:[XTUtils dataWithHexString:[NSString stringWithFormat:@"00B083%@",returnLen]] error:error];
    NSLog(@"======反馈指令：%@======",[NSString stringWithFormat:@"00B083%@",returnLen]);
    if (*error) {
        return cardInfo;
    }
    NSLog(@"======燃气表回馈信息文件：%@======",data);
    [self parseReturnData:cardInfo string:data returnLen:returnLen error:error];
    if (*error) {
        return cardInfo;
    }
    
    return cardInfo;

    
}

/**
 获取用户卡序列号

 @param error 错误
 @return string
 */
- (NSString *)getSerialNumWithError:(NSError **)error {
    NSData *data = [XTUtils dataWithHexString:@"FF70060100"];
    NSString *zhengxu = [self sendData:data error:error];
    NSData *resultData = [XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:zhengxu]];
    return [XTUtils hexStringWithData:resultData];
}


/**
 进入3F02目录

 @param error 错误
 @return bool
 */
- (BOOL)enter3F02WithError:(NSError **)error {
    NSData *data = [XTUtils dataWithHexString:@"00A40000023F02"];
    [self sendData:data error:error];
    if (*error) {
        return NO;
    }
    return YES;
}


/**
 获取8个字节随机数

 @param error 错误
 @return bool
 */
- (NSString *)getRandom8HexWithError:(NSError **)error {
    NSData *data = [XTUtils dataWithHexString:@"0084000008"];
    return [self sendData:data error:error];
}

/**
 外部认证指令
 
 @param error 错误
 @return string
 */
- (NSString *)transOutAuth:(NSString *)auth error:(NSError **)error {
    NSData *data = [XTUtils dataWithHexString:[NSString stringWithFormat:@"0082000408%@",auth]];
    return [self sendData:data error:error];
}


/**
 获取4个字节随机数

 @param error error
 @return string
 */
- (NSString *)getRandom4HexWithError:(NSError **)error {
    NSData *data = [XTUtils dataWithHexString:@"0084000004"];
    NSString *random4Hex = [self sendData:data error:error];
    //补零操作
    NSMutableString *random8Hex = [[NSMutableString alloc] initWithString:random4Hex];
    [random8Hex appendString:@"00000000"];
    return random8Hex;
}

/**
 获取卡的应用信息文件
 
 @param error error
 @return string
 */
- (NSString *)getCardMsgWithError:(NSError **)error {
    //int cardType = [self getCardTypeWithError:error];
    
    NSString *cmd = @"00C8";
    if (_cardVerson == 2) {
        cmd = @"00D3";
    }
    //NSLog(@"======获取卡的应用信息文件：%@======",cmd);
    NSString *sendDataStr = [NSString stringWithFormat:@"00B081%@",cmd];
    NSString *res = [self sendData:[XTUtils dataWithHexString:sendDataStr] error:error];
    
    if (_cardVerson == 1) {
        return [res substringWithRange:NSMakeRange(0, 338)];
    } else if (_cardVerson == 2) {
        return [res substringWithRange:NSMakeRange(0, 422)];
    }

    return [res substringWithRange:NSMakeRange(0, [XTUtils positiveLongWithData:[XTUtils dataWithHexString:cmd]] * 2)];
    
}

/**
 发送加密数据指令

 @param desData desData
 @param mac mac
 */
- (NSString *)sendDesData:(NSString *)desData mac:(NSString *)mac error:(NSError **)error {
    NSString *len = [XTUtils hexStringWithData:[XTUtils dataWithLong:desData.length/2 + 4 length:1]];
    NSString *write = [NSString stringWithFormat:@"04D68100%@%@%@",len, desData, mac];
    return [self sendData:[XTUtils dataWithHexString:write] error:error];
}


/**
 发送金额数据

 @param money 分
 @param error 错误
 @return string
 */
- (NSString *)sendMoney:(int)money error:(NSError **)error {
    NSString *hexMoney = [XTUtils hexStringWithData:[XTUtils dataWithLong:money length:4]];
    NSString *quan = [NSString stringWithFormat:@"805000020B02%@112233445566",hexMoney];
    //NSLog(@"======发送金额数据前：%@======",quan);
    return [self sendData:[XTUtils dataWithHexString:quan] error:error];
}

/**
 发送加密后圈存数据

 @param time 时间
 @param mac 圈存数据
 @param error 错误
 @return string
 */
- (NSString *)sendQuanMac:(NSString *)time mac:(NSString *)mac error:(NSError **)error {
    int le = (int)(time.length + mac.length) / 2;
    NSString *len = [XTUtils hexStringWithData:[XTUtils dataWithLong:le length:1]];
    NSString *cmd = [NSString stringWithFormat:@"80520000%@%@%@",len, time, mac];
    //NSLog(@"======发送加密后圈存数据cmd：%@======",cmd);

    return [self sendData:[XTUtils dataWithHexString:cmd] error:error];
}

/**
 选择文件

 @param error 错误
 @return string
 */
- (NSString *)selectFileWithError:(NSError **)error {
    NSString *result = [self sendData:[XTUtils dataWithHexString:@"00A40000020003"] error:error];
    return result;
    
}


/**
 将反馈信息全部字节写0

 @param error 错误
 @return string
 */
- (NSString *)writeToZeroWithError:(NSError **)error {
    NSString *cmd = @"00C8";
    if (_cardVerson == 2) {
        cmd = @"00E9";
    }
    long count = [XTUtils longWithHexString:cmd];
    NSMutableString *zeroStr = [[NSMutableString alloc] init];
    for (int i = 0; i < count; i ++) {
        [zeroStr appendString:@"00"];
    }
    NSString *dataStr = [NSString stringWithFormat:@"00D600%@%@",cmd, zeroStr];
    return [self sendData:[XTUtils dataWithHexString:dataStr] error:error];
}

#pragma -mark private methods

/**
 解析用户卡基本信息

 @param cardInfo cardInfo
 @param string string
 @param error 错误
 */
- (void)parseCommonInfo:(XTBlueCardInfo *)cardInfo string:(NSString *)string error:(NSError **)error {
    
    *error = nil;
    @try {
        cardInfo.companyCode = [string substringWithRange:NSMakeRange(0, 4)];   //公司代码
        cardInfo.cityCode = [string substringWithRange:NSMakeRange(4, 4)];      //城市代码
        cardInfo.opneTime = [string substringWithRange:NSMakeRange(8, 14)];     //发卡时间
        cardInfo.userName = [string substringWithRange:NSMakeRange(22, 16)];    //用户名称
        cardInfo.userId = [string substringWithRange:NSMakeRange(38, 48)];      //身份证号
        cardInfo.checkSum1 = [string substringWithRange:NSMakeRange(86, 2)];  //校验和
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"错误" code:110 userInfo:@{@"NSLocalizedDescription": @"解析失败"}];
    } @finally {
        
    }
    
}

/**
 解析反馈文件
 
 @param cardInfo cardInfo
 @param string string
 @param returnLen returnLen
 */
- (void)parseReturnData:(XTBlueCardInfo *)cardInfo string:(NSString *)string returnLen:(NSString *)returnLen error:(NSError **)error {
    
    *error = nil;
    @try {
        cardInfo.nwTime = [string substringWithRange:NSMakeRange(0, 14)];   //表当前时间
        cardInfo.nwPrice = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(14, 4)]];//表当前单价
        cardInfo.nwRemainMoney = [NSString stringWithFormat:@"%ld",[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(18, 8)]]];//表剩余金额
        cardInfo.totalBuyMoney = [NSString stringWithFormat:@"%ld",[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(26, 8)]]];//表累计购气金额
        cardInfo.totalUseGas = [NSString stringWithFormat:@"%ld",[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(34, 8)]]];//累计用气量
        cardInfo.noUseDayCount = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(42, 2)]];//无用气天数
        cardInfo.noUseSecondsCount = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(44, 4)]];//无用气秒数
        cardInfo.nwStatus = [string substringWithRange:NSMakeRange(48, 4)];     //表当前状态
        cardInfo.dealWords = [string substringWithRange:NSMakeRange(52, 2)];    //消费交易字
        NSString *monthUse = [string substringWithRange:NSMakeRange(54, 192)];
        cardInfo.monthUseList = [self getUseList:monthUse];                     //月用量
        cardInfo.securityCounts = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(246, 2)]];//安检返写条数
        cardInfo.securityRecord = [self getRecordList:[string substringWithRange:NSMakeRange(248, 36)]];//安检返写记录
        cardInfo.recentClose = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(284, 2)]];//最近一次关阀记录
        cardInfo.nfcTimes = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(286, 2)]];//NFC购气次数
        cardInfo.nfcMoney = [NSString stringWithFormat:@"%ld",[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(288, 8)]]];     //NFC购气金额
        cardInfo.nfcTotalMoney = [NSString stringWithFormat:@"%ld",[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(296, 8)]]];     //NFC购气总金额
        cardInfo.checkSum3 = [string substringWithRange:NSMakeRange(304, 2)];   //验和
        if ([returnLen isEqualToString:@"00E8"]) {
            cardInfo.historyMonthList = [XTUtils fourStringArrayWithOriginString:[string substringWithRange:NSMakeRange(306, 96)]];//月记录
            cardInfo.addjustDate = [string substringWithRange:NSMakeRange(402, 6)];//TCIS调价日
            cardInfo.addjustBottom = [NSString stringWithFormat:@"%ld",[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(408, 8)]]];     //调价日底数
            cardInfo.payDate = [string substringWithRange:NSMakeRange(416, 6)];//充值日
            cardInfo.payBottom = [NSString stringWithFormat:@"%ld",[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(422, 8)]]];     //充值日底数
            cardInfo.backupData2 = [string substringWithRange:NSMakeRange(430, 32)];//被on个字节
            cardInfo.extSum2 = [string substringWithRange:NSMakeRange(462, 2)];//
        }

    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"错误" code:110 userInfo:@{@"NSLocalizedDescription": @"解析失败"}];
    } @finally {
        
    }
    
}

/**
 解析应用文件信息

 @param cardInfo cardInfo
 @param string string
 @param len len
 */
- (void)parseAppliInfo:(XTBlueCardInfo *)cardInfo string:(NSString *)string len:(NSString *)len error:(NSError **)error {
    
    *error = nil;
    @try {
        cardInfo.cardType = [self getCardType:[string substringWithRange:NSMakeRange(0, 2)]];//用户卡类型
        cardInfo.userFlag = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(2, 2)]];//用户卡标志
        cardInfo.paramModifyFlag = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(4, 2)]];//参数修改标志
        cardInfo.keyVerson = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(6, 2)]];//密钥版本号
        cardInfo.buyTime = [string substringWithRange:NSMakeRange(8, 6)];   //购气时间
        cardInfo.validTime = [string substringWithRange:NSMakeRange(14, 6)];//充值有效期
        cardInfo.userCode = [string substringWithRange:NSMakeRange(20, 20)];//用户编号
        cardInfo.userType = [string substringWithRange:NSMakeRange(40, 2)]; //用户类型
        cardInfo.buyTimes = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(42, 2)]];//购气次数
        cardInfo.leakFunction = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(44, 2)]];//漏气功能
        cardInfo.continuousHours = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(46, 2)]];//连续用气小时数
        cardInfo.wanrAutoLock = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(48, 2)]];//报警联动自动锁功能
        cardInfo.noUseAutoLock = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(50, 2)]];//长期不用自动锁功能
        cardInfo.lockDay1 = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(52, 2)]];//不用气自锁天数1
        cardInfo.lockDay2 = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(54, 2)]];//不用气自锁天数2
        cardInfo.overflowFun = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(56, 2)]];//过流功能
        cardInfo.overflowCount = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(58, 4)]];//过流量
        cardInfo.overflowTimeStart = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(62, 2)]];//过流时间启用
        cardInfo.overflowTime = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(64, 2)]];//过流时间
        cardInfo.limitBuy = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(66, 2)]];//限购功能
        cardInfo.limitMoney = [NSString stringWithFormat:@"%ld",[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(68, 8)]]];//限购充值上限
        cardInfo.lowWarnMoney = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(76, 4)]];//蜂鸣器低额提醒金额
        cardInfo.autoWarnStart1 = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(80, 2)]];//启动自动报警1
        cardInfo.warnValue1 = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(82, 2)]];//报警值1
        cardInfo.autoWarnStart2 = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(84, 2)]];//启动自动报警2
        cardInfo.warnValue2 = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(86, 2)]];//报警值2
        cardInfo.zeroClose = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(88, 2)]];//0元关阀功能
        cardInfo.securityCheckStart = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(90, 2)]];//启动安检功能
        cardInfo.securityMonth = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(92, 2)]];//安检月份
        cardInfo.scrapStart = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(94, 2)]];//启动报废表功能
        cardInfo.scrapYear = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(96, 2)]];//报废表年期
        cardInfo.versonFlag = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(98, 2)]];//版本标志
        cardInfo.userFlag2 = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(100, 2)]];//用户卡标志2
        cardInfo.recordDate = (int)[XTUtils longWithHexString:[string substringWithRange:NSMakeRange(102, 2)]];//累计消耗记录日
        cardInfo.priceGroupC1 = [self getPriceG:[XTUtils dataWithHexString:[string substringWithRange:NSMakeRange(104, 44)]]];//当前价格组1
        cardInfo.priceGroupC2 = [self getPriceG:[XTUtils dataWithHexString:[string substringWithRange:NSMakeRange(148, 44)]]];//当前价格组2
        cardInfo.priceGroupN1 = [self getPriceG:[XTUtils dataWithHexString:[string substringWithRange:NSMakeRange(192, 44)]]];//新价格组1
        cardInfo.priceGroupN2 = [self getPriceG:[XTUtils dataWithHexString:[string substringWithRange:NSMakeRange(236, 44)]]];//新价格组2
        cardInfo.nwPriceStart = [string substringWithRange:NSMakeRange(280, 8)];//新单价生效日期
        cardInfo.priceStartCycling = [XTUtils fourStringArrayWithOriginString:[string substringWithRange:NSMakeRange(288, 48)]];//价格启用循环
        cardInfo.checkSum2 = [string substringWithRange:NSMakeRange(336, 2)];//校验和
        if ([len isEqualToString:@"00D3"]) {
            cardInfo.nwPriceStartRepeat = [XTUtils fourStringArrayWithOriginString:[string substringWithRange:NSMakeRange(338, 48)]];//新价格启用循环
            cardInfo.valWay = [[string substringWithRange:NSMakeRange(386, 2)] intValue];//计费方式
            cardInfo.backupData = [string substringWithRange:NSMakeRange(388, 32)];//备用字段
            cardInfo.extSum = [string substringWithRange:NSMakeRange(420, 2)];//
        }
        
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"错误" code:110 userInfo:@{@"NSLocalizedDescription": @"解析失败"}];
    } @finally {
        
    }
}

/**
 *  获取4阶5价
 *  curPriceG1
 */
- (XTPriceGroupInfo *)getPriceG:(NSData *)curPriceG1Data {
    XTPriceGroupInfo *model = [[XTPriceGroupInfo alloc] init];
    model.price1 = [XTUtils positiveLongWithData:[curPriceG1Data subdataWithRange:NSMakeRange(0, 2)]];
    model.devideCount1 = (int)[XTUtils positiveLongWithData:[curPriceG1Data subdataWithRange:NSMakeRange(2, 3)]];
    model.price2 = [XTUtils positiveLongWithData:[curPriceG1Data subdataWithRange:NSMakeRange(5, 2)]];
    model.devideCount2 = (int)[XTUtils positiveLongWithData:[curPriceG1Data subdataWithRange:NSMakeRange(7, 3)]];
    model.price3 = [XTUtils positiveLongWithData:[curPriceG1Data subdataWithRange:NSMakeRange(10, 2)]];
    model.devideCount3 = (int)[XTUtils positiveLongWithData:[curPriceG1Data subdataWithRange:NSMakeRange(12, 3)]];
    model.price4 = [XTUtils positiveLongWithData:[curPriceG1Data subdataWithRange:NSMakeRange(15, 2)]];
    model.devideCount4 = (int)[XTUtils positiveLongWithData:[curPriceG1Data subdataWithRange:NSMakeRange(17, 3)]];
    model.price5 = [XTUtils positiveLongWithData:[curPriceG1Data subdataWithRange:NSMakeRange(20, 2)]];
    return model;
}


/**
 使用量

 @param str str
 @return array
 */
- (NSArray *)getUseList:(NSString *)str {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (int i = 0; i < str.length; i += 8) {
        NSString *sub = [NSString stringWithFormat:@"%ld",[XTUtils longWithHexString:[str substringWithRange:NSMakeRange(i, 8)]]];
        [list addObject:sub];
    }
    return list;
}


/**
 记录

 @param str str
 @return array
 */
- (NSArray *)getRecordList:(NSString *)str {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (int i = 0; i < str.length; i += 12) {
        NSString *sub = [str substringWithRange:NSMakeRange(i, 12)];
        [list addObject:sub];
    }
    return list;
}

/**
 获取用户卡类型

 @param str 卡类型字符串
 @return 类型
 */
- (NSString *)getCardType:(NSString *)str {
    if ([str isEqualToString:@"50"]) {
        return @"用户卡";
    } else if ([str isEqualToString:@"51"]) {
        return @"检查卡";
    } else if ([str isEqualToString:@"52"]) {
        return @"生产数据设置卡";
    } else if ([str isEqualToString:@"53"]) {
        return @"密钥修改卡";
    } else if ([str isEqualToString:@"54"]) {
        return @"清零卡";
    } else if ([str isEqualToString:@"55"]) {
        return @"换表卡";
    } else if ([str isEqualToString:@"56"]) {
        return @"校时卡";
    } else if ([str isEqualToString:@"57"]) {
        return @"应急卡";
    } else if ([str isEqualToString:@"58"]) {
        return @"参数设置卡";
    } else if ([str isEqualToString:@"59"]) {
        return @"安检卡";
    } else if ([str isEqualToString:@"5A"]) {
        return @"历史卡";
    }
    return @"未知类型";
}

/**
 获取卡类型，判断是新卡还是老卡
 
 @return 1--新卡
 */
- (int)getCardTypeWithError:(NSError **)error {
    NSString *enter02 = [self sendData:[XTUtils dataWithHexString:@"00A40000023F02"] error:error];
    if (*error) {
        return 0;
    }
    NSLog(@"======进入目录(02)：%@======",enter02);
    
    NSString *userInfo = [self sendData:[XTUtils dataWithHexString:@"00B08100C8"] error:error];
    if (*error) {
        return 0;
    }
    NSLog(@"======读用户应用信息文件：%@======",userInfo);
    if (![[userInfo substringWithRange:NSMakeRange(386, 2)] isEqualToString:@"00"]) {
        return 1;
    }
    
    return 0;
}

#pragma -mark private cardReader

/**
 获取读卡准备工作

 @return reader
 */
- (DecardIccReader *)reader {
    if (!_reader) {
        _reader = [[DecardIccReader alloc] init];
    }
    return _reader;
}

/**
 发送数据
 
 @param data data
 */
- (NSString *)sendData:(NSData *)data error:(NSError **)error {
    
    *error = nil;
    
    if (![self isOpened]) {
        *error = [NSError errorWithDomain:@"错误" code:110 userInfo:@{@"NSLocalizedDescription": @"请连接读卡器"}];
        return nil;
    }
    
    //long lResult = [self.reader SendApdu:data receivedData:revRespondData withSW:revSWData];
    long lResult = 0;
    NSData *revRespondData = [self.reader exchangeWithData:data time_s:10];
    
    if ((0 == lResult) && (0 != [revRespondData length]))
    {
        
        NSString *BCD_revRespond = [XTUtils hexStringWithData:revRespondData];
        
        *error = [self getCardErrorCode:BCD_revRespond];
        
        if (!*error) {
            if ([BCD_revRespond hasSuffix:@"9000"] && BCD_revRespond.length > 4) {
                BCD_revRespond = [BCD_revRespond substringWithRange:NSMakeRange(0, BCD_revRespond.length - 4)];
            }
        }
        
        return BCD_revRespond;
        
    }
    else if(0 != lResult)
    {
        *error = [NSError errorWithDomain:@"错误" code:110 userInfo:@{@"NSLocalizedDescription": @"数据异常"}];
        return nil;
        
    }
    
    else if (0 == [revRespondData length])
    {
        *error = [NSError errorWithDomain:@"错误" code:110 userInfo:@{@"NSLocalizedDescription": @"数据异常"}];
        return nil;
    }
    return nil;
}

/**
 根据code获取卡错误信息

 @param code code
 @return error
 */
- (NSError *)getCardErrorCode:(NSString *)code {
    
    code = [code uppercaseString];
    
    if ([[code substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"61"]) {
        //正常处理
        return nil;
    } else if ([code isEqualToString:@"6200"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"无信息提供"}];
    } else if ([code isEqualToString:@"6281"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"回送的数据可能有错"}];
    } else if ([code isEqualToString:@"6282"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"文件长度<Le"}];
    } else if ([code isEqualToString:@"6283"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"选择的文件无效"}];
    } else if ([code isEqualToString:@"6284"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"FCI格式与P2指定的不符"}];
    } else if ([code isEqualToString:@"6300"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"认证失败"}];
    } else if ([[code substringWithRange:NSMakeRange(0, 3)] isEqualToString:@"63C"]) {
        long lastCount = [XTUtils positiveLongWithData:[XTUtils dataWithHexString:[code substringWithRange:NSMakeRange(3, 1)]]];
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": [NSString stringWithFormat:@"验证失败，还剩下%ld次尝试机会",lastCount]}];
    } else if ([code isEqualToString:@"6400"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"状态标志位未变"}];
    } else if ([code isEqualToString:@"6581"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"内存错误"}];
    } else if ([code isEqualToString:@"6700"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"长度错误"}];
    } else if ([code isEqualToString:@"6882"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"不支持安全报文"}];
    } else if ([code isEqualToString:@"6900"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"不能处理"}];
    } else if ([code isEqualToString:@"6901"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"命令不接受（无效状态）"}];
    } else if ([code isEqualToString:@"6981"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"命令与文件结构不相容"}];
    } else if ([code isEqualToString:@"6982"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"不满足安全状态"}];
    } else if ([code isEqualToString:@"6983"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"验证方法锁定"}];
    } else if ([code isEqualToString:@"6984"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"引用数据无效"}];
    } else if ([code isEqualToString:@"6985"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"使用条件不满足"}];
    } else if ([code isEqualToString:@"6986"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"不满足命令执行的条件(非当前EF)"}];
    } else if ([code isEqualToString:@"6987"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"安全报文数据项丢失"}];
    } else if ([code isEqualToString:@"6988"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"安全信息数据对象不正确"}];
    } else if ([code isEqualToString:@"6A80"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"数据域参数不正确"}];
    } else if ([code isEqualToString:@"6A81"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"功能不支持"}];
    } else if ([code isEqualToString:@"6A82"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"未找到文件"}];
    } else if ([code isEqualToString:@"6A83"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"未找到记录"}];
    } else if ([code isEqualToString:@"6A84"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"文件中存储空间不够"}];
    } else if ([code isEqualToString:@"6A86"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"P1、P2参数不正确"}];
    } else if ([code isEqualToString:@"6A88"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"引用数据找不到"}];
    } else if ([code isEqualToString:@"6B00"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"参数错误(偏移地址超出了EF)"}];
    } else if ([[code substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"6C"]) {
        NSString *length = [code substringWithRange:NSMakeRange(2, 2)];
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": [NSString stringWithFormat:@"长度错误(Le 错误：'%@'为实际长度)",length]}];
    } else if ([code isEqualToString:@"6F00"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"数据无效"}];
    } else if ([code isEqualToString:@"6F01"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"未输入PIN"}];
    } else if ([code isEqualToString:@"9000"]) {
        //成功执行，无错误
        return nil;
    } else if ([code isEqualToString:@"9301"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"金额不足"}];
    } else if ([code isEqualToString:@"9302"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"MAC 无效"}];
    } else if ([code isEqualToString:@"9303"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"应用永久锁住"}];
    } else if ([code isEqualToString:@"9401"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"金额不足"}];
    } else if ([code isEqualToString:@"9402"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"交易计数器到达最大值"}];
    } else if ([code isEqualToString:@"9403"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"密钥索引不支持"}];
    } else if ([code isEqualToString:@"9406"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"所需MAC 不可用"}];
    } else if ([code isEqualToString:@"6E00"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"不支持的类：CLA错"}];
    } else if ([code isEqualToString:@"6D00"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"不支持的指令代码"}];
    } else if ([code isEqualToString:@"6600"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"接收通讯超时"}];
    } else if ([code isEqualToString:@"6601"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"接收字符奇偶错"}];
    } else if ([code isEqualToString:@"6602"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"校验和不对"}];
    } else if ([code isEqualToString:@"6603"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"当前DF文件无FCI"}];
    } else if ([code isEqualToString:@"6604"]) {
        return [NSError errorWithDomain:@"错误" code:[code intValue] userInfo:@{@"NSLocalizedDescription": @"当前DF下无SF或KF"}];
    }
    return nil;
}
#endif

@end
