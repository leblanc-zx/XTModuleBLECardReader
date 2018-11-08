//
//  CardInfoModel.h
//  BLECardReader
//
//  Created by apple on 2017/9/8.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XTPriceGroupInfo.h"

@interface XTBlueCardInfo : NSObject

/*----------基本信息----------*/
@property (nonatomic, strong) NSString *companyCode;//公司代码
@property (nonatomic, strong) NSString *cityCode;   //城市代码
@property (nonatomic, strong) NSString *opneTime;   //发卡时间
@property (nonatomic, strong) NSString *userName;   //用户名称
@property (nonatomic, strong) NSString *userId;     //身份证号
@property (nonatomic, strong) NSString *checkSum1;  //校验和
/*----------应用信息----------*/
@property (nonatomic, strong) NSString *cardType;   //用户卡类型
@property (nonatomic, assign) int userFlag;         //用户卡标志
@property (nonatomic, assign) int paramModifyFlag;  //参数修改标志
@property (nonatomic, assign) int keyVerson;        //秘钥版本号
@property (nonatomic, strong) NSString *buyTime;    //购气时间
@property (nonatomic, strong) NSString *validTime;  //充值有效期
@property (nonatomic, strong) NSString *userCode;   //用户编号
@property (nonatomic, strong) NSString *userType;   //用户类型
@property (nonatomic, assign) int buyTimes;         //购气次数
@property (nonatomic, assign) int leakFunction;     //漏气功能
@property (nonatomic, assign) int continuousHours;  //连续用气小时数
@property (nonatomic, assign) int wanrAutoLock;     //报警联动自动锁功能
@property (nonatomic, assign) int noUseAutoLock;    //长期不用自动锁功能
@property (nonatomic, assign) int lockDay1;         //不用气自锁天数1
@property (nonatomic, assign) int lockDay2;         //不用气自锁天数2
@property (nonatomic, assign) int overflowFun;      //过流功能
@property (nonatomic, assign) int overflowCount;    //过流量
@property (nonatomic, assign) int overflowTimeStart;//过流时间启用
@property (nonatomic, assign) int overflowTime;     //过流时间
@property (nonatomic, assign) int limitBuy;         //限购功能
@property (nonatomic, strong) NSString *limitMoney; //限购充值上限
@property (nonatomic, assign) int lowWarnMoney;     //蜂鸣器低额提醒金额
@property (nonatomic, assign) int autoWarnStart1;   //启动自动报警1
@property (nonatomic, assign) int warnValue1;       //报警值1
@property (nonatomic, assign) int autoWarnStart2;   //启动自动报警2
@property (nonatomic, assign) int warnValue2;       //报警值2
@property (nonatomic, assign) int zeroClose;        //0元关阀功能
@property (nonatomic, assign) int securityCheckStart;//启动安检功能
@property (nonatomic, assign) int securityMonth;    //安检月份
@property (nonatomic, assign) int scrapStart;       //启动报废表功能
@property (nonatomic, assign) int scrapYear;        //报废表年期
@property (nonatomic, assign) int versonFlag;       //结算方式
@property (nonatomic, assign) int userFlag2;        //单价类型
@property (nonatomic, assign) int recordDate;       //累计消耗记录日
@property (nonatomic, strong) XTPriceGroupInfo *priceGroupC1;   //当前价格组1
@property (nonatomic, strong) XTPriceGroupInfo *priceGroupC2;   //当前价格组2
@property (nonatomic, strong) XTPriceGroupInfo *priceGroupN1;   //新价格组1
@property (nonatomic, strong) XTPriceGroupInfo *priceGroupN2;   //新价格组2
@property (nonatomic, strong) NSString *nwPriceStart;           //新单价生效日期
@property (nonatomic, strong) NSArray *priceStartCycling;       //价格启用循环
@property (nonatomic, strong) NSString *checkSum2;              //校验和
@property (nonatomic, strong) NSArray *nwPriceStartRepeat;      //新价格启用循环
@property (nonatomic, assign) int valWay;                       //计费方式(55：计量 11：计金额)
@property (nonatomic, strong) NSString *backupData;             //备用字段
@property (nonatomic, strong) NSString *extSum;                 //
/*----------钱包文件----------*/
@property (nonatomic, strong) NSString *thisMoney;              //本次购气金额
/*----------反馈信息----------*/
@property (nonatomic, strong) NSString *nwTime;         //表当前时间
@property (nonatomic, assign) int nwPrice;              //表当前单价
@property (nonatomic, strong) NSString *nwRemainMoney;  //表剩余金额
@property (nonatomic, strong) NSString *totalBuyMoney;  //表累计购气金额
@property (nonatomic, strong) NSString *totalUseGas;    //累计用气量
@property (nonatomic, assign) int noUseDayCount;        //无用气天数
@property (nonatomic, assign) int noUseSecondsCount;    //无用气秒数
@property (nonatomic, strong) NSString *nwStatus;       //表当前状态
@property (nonatomic, strong) NSString *dealWords;      //消费交易字
@property (nonatomic, strong) NSArray *monthUseList;    //月用量
@property (nonatomic, assign) int securityCounts;       //安检返写条数
@property (nonatomic, strong) NSArray *securityRecord;  //安检返写记录
@property (nonatomic, assign) int recentClose;          //最近一次关阀记录
@property (nonatomic, assign) int nfcTimes;             //NFC购气次数
@property (nonatomic, strong) NSString *nfcMoney;       //NFC购气金额
@property (nonatomic, strong) NSString *nfcTotalMoney;  //NFC购气总金额
@property (nonatomic, strong) NSString *checkSum3;      //校验和
@property (nonatomic, strong) NSArray *historyMonthList;//月记录
@property (nonatomic, strong) NSString *addjustDate;    //TCIS调价日
@property (nonatomic, strong) NSString *addjustBottom;  //调价日底数
@property (nonatomic, strong) NSString *payDate;        //充值日
@property (nonatomic, strong) NSString *payBottom;      //充值日底数
@property (nonatomic, strong) NSString *backupData2;    //被on个字节
@property (nonatomic, strong) NSString *extSum2;        //

@end
