/**
 * @file   iccreader.h
 * @author Wei Yang
 * @date   Mon Jun  8 13:57:15 2015
 *
 * @brief  Integrated Circuit Card Reader Interface.
 *
 *
 */

#import <Foundation/Foundation.h>

@protocol IccReader <NSObject>

/**
 * 获取软件版本号，软件指的是实现此接口的软件库。
 *
 * @return 版本号，如@“1.0.0.1”。
 */
- (NSString *)softwareVersion;

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
 *
 * @return YES-成功 NO-失败。
 */
- (BOOL)openWithName:(NSString *)name time_s:(int)time_s;

/**
 * 关闭设备，内部断开蓝牙连接。
 */
- (void)close;

/**
 * 数据交互。
 *
 * @param[in] data 发送到设备的数据。
 * @param[in] time_s 交互帧超时，秒为单位。
 *
 * @return nil表示错误，否则表示设备返回的数据。
 */
- (NSData *)exchangeWithData:(NSData *)data time_s:(int)time_s;

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


@end
