//
//  NSImage+GDQrCodeImage.h
//  Package
//
//  Created by Whirlwind on 16/4/24.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import <AppKit/AppKit.h>
@interface NSImage (GDQrCodeImage)

/**
 *  创建一个有大小颜色的二维码图片(没有背景色)
 *
 *  @param size         二维码的大小(宽高相等)
 *  @param codeColor    二维码的颜色
 *  @param codeMessage 二维码的内容
 *
 *  @return 返回一个二维码
 */
- (instancetype)initWithSize:(CGFloat)size color:(NSColor *)codeColor message:(NSString *)codeMessage;
+ (instancetype)gd_QrCodeImageWithSize:(CGFloat)size color:(NSColor *)codeColor message:(NSString *)codeMessage;


/**
 *  创建一个二维码图片(没有背景色)
 *
 *  @param codeMessage 二维码内容
 *
 *  @return 返回一个二维码
 */
- (instancetype)initWithMessage:(NSString *)codeMessage;
+ (instancetype)gd_QrCodeImageWithMessage:(NSString *)codeMessage;

/**
 *  创建一个自定义大小的二维码(没有背景色)
 *
 *  @param size         二维码的大小
 *  @param codeMessage 二维码的内容
 *
 *  @return 返回一个二维码
 */
- (instancetype)initWithSize:(CGFloat)size message:(NSString *)codeMessage;
+ (instancetype)gd_QrCodeImageWithSize:(CGFloat)size message:(NSString *)codeMessage;

/**
 *  创建一个自定义颜色的二维码(没有背景色)
 *
 *  @param codeColor    二维码的颜色
 *  @param codeMessage 二维码的内容
 *
 *  @return 返回一个二维码
 */
- (instancetype)initWithColor:(NSColor *)codeColor message:(NSString *)codeMessage;
+ (instancetype)gd_QrCodeImageWithColor:(NSColor *)codeColor message:(NSString *)codeMessage;

/**
 *  创建一个有大小颜色的二维码图片(含有logo)(没有背景色)
 *
 *  @param size         二维码的大小(宽高相等)
 *  @param codeColor    二维码的颜色
 *  @param codeMessage 二维码的内容
 *  @param codeMessage 中心图片
 *
 *  @return 返回一个二维码
 */
- (instancetype)initWithSize:(CGFloat)size color:(NSColor *)codeColor message:(NSString *)codeMessage centerImage:(NSImage *)centerImage;
+ (instancetype)gd_QrCodeImageWithSize:(CGFloat)size color:(NSColor *)codeColor message:(NSString *)codeMessage centerImage:(NSImage *)centerImage;

/**
 *  创建一个二维码图片(含有logo)(没有背景色)
 *
 *  @param codeMessage 二维码内容
 *  @param codeMessage 中心图片
 *
 *  @return 返回一个二维码
 */
- (instancetype)initWithMessage:(NSString *)codeMessage centerImage:(NSImage *)centerImage;
+ (instancetype)gd_QrCodeImageWithMessage:(NSString *)codeMessage centerImage:(NSImage *)centerImage;

/**
 *  创建一个自定义大小的二维码(含有logo)(没有背景色)
 *
 *  @param size         二维码的大小
 *  @param codeMessage 二维码的内容
 *  @param codeMessage 中心图片
 *
 *  @return 返回一个二维码
 */
- (instancetype)initWithSize:(CGFloat)size message:(NSString *)codeMessage centerImage:(NSImage *)centerImage;
+ (instancetype)gd_QrCodeImageWithSize:(CGFloat)size message:(NSString *)codeMessage centerImage:(NSImage *)centerImage;

/**
 *  创建一个自定义颜色的二维码(含有logo)(没有背景色)
 *
 *  @param codeColor    二维码的颜色
 *  @param codeMessage 二维码的内容
 *  @param codeMessage 中心图片
 *
 *  @return 返回一个二维码(没有背景色)
 */
- (instancetype)initWithColor:(NSColor *)codeColor message:(NSString *)codeMessage centerImage:(NSImage *)centerImage;
+ (instancetype)gd_QrCodeImageWithColor:(NSColor *)codeColor message:(NSString *)codeMessage centerImage:(NSImage *)centerImage;



/**
 *  创建一个有大小 颜色 背景色 (含有logo)
 *
 *  @param size         二维码的大小
 *  @param codeColor    二维码的颜色
 *  @param bgColor      二维码的背景色
 *  @param codeMessage 二维码信息
 *  @param centerImage  二维码中心图片
 *
 *  @return 创建的二维码
 */
- (instancetype)initWithSize:(CGFloat)size color:(NSColor *)codeColor bgColor:(NSColor *)bgColor message:(NSString *)codeMessage centerImage:(NSImage *)centerImage;
+ (instancetype)gd_QrCodeImageWithSize:(CGFloat)size color:(NSColor *)codeColor bgColor:(NSColor *)bgColor message:(NSString *)codeMessage centerImage:(NSImage *)centerImage;

/**
 *  创建一个有颜色 背景色 (含有logo)默认大小
 *
 *  @param codeColor    二维码的颜色
 *  @param bgColor      二维码的背景色
 *  @param codeMessage 二维码信息
 *  @param centerImage  二维码中心图片
 *
 *  @return 创建的二维码
 */
- (instancetype)initWithColor:(NSColor *)codeColor bgColor:(NSColor *)bgColor message:(NSString *)codeMessage centerImage:(NSImage *)centerImage;
+ (instancetype)gd_QrCodeImageWithColor:(NSColor *)codeColor bgColor:(NSColor *)bgColor message:(NSString *)codeMessage centerImage:(NSImage *)centerImage;

/**
 *  创建一个有大小  背景色 (含有logo)默认颜色
 *
 *  @param size         二维码的大小
 *  @param bgColor      二维码的背景色
 *  @param codeMessage 二维码信息
 *  @param centerImage  二维码中心图片
 *
 *  @return 创建的二维码
 */
- (instancetype)initWithSize:(CGFloat)size bgColor:(NSColor *)bgColor message:(NSString *)codeMessage centerImage:(NSImage *)centerImage;
+ (instancetype)gd_QrCodeImageWithSize:(CGFloat)size bgColor:(NSColor *)bgColor message:(NSString *)codeMessage centerImage:(NSImage *)centerImage;

/**
 *  创建一个有大小 颜色 背景色 (不含有logo)
 *
 *  @param size         二维码的大小
 *  @param codeColor    二维码的颜色
 *  @param bgColor      二维码的背景色
 *  @param codeMessage 二维码信息
 *
 *  @return 创建的二维码
 */
- (instancetype)initWithSize:(CGFloat)size color:(NSColor *)codeColor bgColor:(NSColor *)bgColor message:(NSString *)codeMessage;
+ (instancetype)gd_QrCodeImageWithSize:(CGFloat)size color:(NSColor *)codeColor bgColor:(NSColor *)bgColor message:(NSString *)codeMessage;




+ (void)gd_asyncGetQrCodeImageWithSize:(CGFloat)size color:(NSColor *)codeColor message:(NSString *)codeMessage completion:(void (^)(NSImage *qrCodeImage))completion;


+ (void)gd_asyncGetQrCodeImageWithMessage:(NSString *)codeMessage completion:(void (^)(NSImage *qrCodeImage))completion;



+ (void)gd_asyncGetQrCodeImageWithSize:(CGFloat)size message:(NSString *)codeMessage completion:(void (^)(NSImage *qrCodeImage))completion;



+ (void)gd_asyncGetQrCodeImageWithColor:(NSColor *)codeColor message:(NSString *)codeMessage completion:(void (^)(NSImage *qrCodeImage))completion;



+ (void)gd_asyncGetQrCodeImageWithSize:(CGFloat)size color:(NSColor *)codeColor message:(NSString *)codeMessage centerImage:(NSImage *)centerImage completion:(void (^)(NSImage *qrCodeImage))completion;



+ (void)gd_asyncGetQrCodeImageWithMessage:(NSString *)codeMessage centerImage:(NSImage *)centerImage completion:(void (^)(NSImage *qrCodeImage))completion;



+ (void)gd_asyncGetQrCodeImageWithSize:(CGFloat)size message:(NSString *)codeMessage centerImage:(NSImage *)centerImage completion:(void (^)(NSImage *qrCodeImage))completion;


+ (void)gd_asyncGetQrCodeImageWithColor:(NSColor *)codeColor message:(NSString *)codeMessage centerImage:(NSImage *)centerImage completion:(void (^)(NSImage *qrCodeImage))completion;



+ (void)gd_asyncGetQrCodeImageWithSize:(CGFloat)size color:(NSColor *)codeColor bgColor:(NSColor *)bgColor message:(NSString *)codeMessage centerImage:(NSImage *)centerImage completion:(void (^)(NSImage *qrCodeImage))completion;



+ (void)gd_asyncGetQrCodeImageWithColor:(NSColor *)codeColor bgColor:(NSColor *)bgColor message:(NSString *)codeMessage centerImage:(NSImage *)centerImage completion:(void (^)(NSImage *qrCodeImage))completion;



+ (void)gd_asyncGetQrCodeImageWithSize:(CGFloat)size bgColor:(NSColor *)bgColor message:(NSString *)codeMessage centerImage:(NSImage *)centerImage completion:(void (^)(NSImage *qrCodeImage))completion;


+ (void)gd_asyncGetQrCodeImageWithSize:(CGFloat)size color:(NSColor *)codeColor bgColor:(NSColor *)bgColor message:(NSString *)codeMessage completion:(void (^)(NSImage *qrCodeImage))completion;


@end
