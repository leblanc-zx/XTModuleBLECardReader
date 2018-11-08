#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "XTAsyncSocket.h"
#import "XTAsyncUdpSocket.h"
#import "XTSocketManager.h"

FOUNDATION_EXPORT double XTComponentSocketVersionNumber;
FOUNDATION_EXPORT const unsigned char XTComponentSocketVersionString[];

