/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageImageIOCoder.h"
#import "SDWebImageCoderHelper.h"
#import "NSImage+WebCache.h"
#import <ImageIO/ImageIO.h>
#import "NSData+ImageContentType.h"
#import "UIImage+MultiFormat.h"

#if SD_UIKIT || SD_WATCH
// 每个像素占用多少字节 4
static const size_t kBytesPerPixel = 4;
// 一个颜色的字节数
static const size_t kBitsPerComponent = 8;

/*
 * Defines the maximum size in MB of the decoded image when the flag `SDWebImageScaleDownLargeImages` is set
 * Suggested value for iPad1 and iPhone 3GS: 60.
 * Suggested value for iPad2 and iPhone 4: 120.
 * Suggested value for iPhone 3G and iPod 2 and earlier devices: 30.
 */
// 定义解码图像的最大大小为60MB
static const CGFloat kDestImageSizeMB = 60.0f;

/*
 * Defines the maximum size in MB of a tile used to decode image when the flag `SDWebImageScaleDownLargeImages` is set
 * Suggested value for iPad1 and iPhone 3GS: 20.
 * Suggested value for iPad2 and iPhone 4: 40.
 * Suggested value for iPhone 3G and iPod 2 and earlier devices: 10.
 */
// 定义用于解码图像的最大大小为20MB
static const CGFloat kSourceImageTileSizeMB = 20.0f;
// 每 MB 有多少字节
static const CGFloat kBytesPerMB = 1024.0f * 1024.0f;
// 每 MB 有多少个像素(一个像素是4节)
static const CGFloat kPixelsPerMB = kBytesPerMB / kBytesPerPixel;
// 定义解码完的图像的最大像素数
static const CGFloat kDestTotalPixels = kDestImageSizeMB * kPixelsPerMB;
// 定义用于解码的图像的最大像素数
static const CGFloat kTileTotalPixels = kSourceImageTileSizeMB * kPixelsPerMB;
// 定义重叠像素大小为2像素
static const CGFloat kDestSeemOverlap = 2.0f;   // the numbers of pixels to overlap the seems where tiles meet.
#endif

@implementation SDWebImageImageIOCoder {
        size_t _width, _height;
#if SD_UIKIT || SD_WATCH
        UIImageOrientation _orientation;
#endif
        CGImageSourceRef _imageSource;
}

- (void)dealloc {
    if (_imageSource) {
        CFRelease(_imageSource);
        _imageSource = NULL;
    }
}

+ (instancetype)sharedCoder {
    static SDWebImageImageIOCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[SDWebImageImageIOCoder alloc] init];
    });
    return coder;
}

#pragma mark - Decode
- (BOOL)canDecodeFromData:(nullable NSData *)data {
    switch ([NSData sd_imageFormatForImageData:data]) {
        case SDImageFormatWebP:
            // Do not support WebP decoding
            return NO;
        case SDImageFormatHEIC:
            // Check HEIC decoding compatibility
            return [[self class] canDecodeFromHEICFormat];
        default:
            return YES;
    }
}

- (BOOL)canIncrementallyDecodeFromData:(NSData *)data {
    switch ([NSData sd_imageFormatForImageData:data]) {
        case SDImageFormatWebP:
            // Do not support WebP progressive decoding
            return NO;
        case SDImageFormatHEIC:
            // iOS11 才支持
            // Check HEIC decoding compatibility
            return [[self class] canDecodeFromHEICFormat];
        default:
            return YES;
    }
}

/**
 * 根据 data(需要解码的图片数据？) 生成 image
 * 这个图片还没有被解码
 */
- (UIImage *)decodedImageWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    UIImage *image = [[UIImage alloc] initWithData:data];
    image.sd_imageFormat = [NSData sd_imageFormatForImageData:data];
    
    return image;
}

// 这里获取的渐进图是没有解码的
- (UIImage *)incrementallyDecodedImageWithData:(NSData *)data finished:(BOOL)finished {
    if (!_imageSource) {
        // 创建一个增量图像源
        _imageSource = CGImageSourceCreateIncremental(NULL);
    }
    UIImage *image;
    
    // The following code is from http://www.cocoaintheshell.com/2011/05/progressive-images-download-imageio/
    // Thanks to the author @Nyx0uf
    
    // Update the data source, we must pass ALL the data, not just the new bytes
    CGImageSourceUpdateData(_imageSource, (__bridge CFDataRef)data, finished);
    
    // 获取 image 的宽高和方向
    if (_width + _height == 0) {
        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(_imageSource, 0, NULL);
        if (properties) {
            NSInteger orientationValue = 1;
            CFTypeRef val = CFDictionaryGetValue(properties, kCGImagePropertyPixelHeight);
            if (val) CFNumberGetValue(val, kCFNumberLongType, &_height);
            val = CFDictionaryGetValue(properties, kCGImagePropertyPixelWidth);
            if (val) CFNumberGetValue(val, kCFNumberLongType, &_width);
            // 获取图片的方向
            val = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
            if (val) CFNumberGetValue(val, kCFNumberNSIntegerType, &orientationValue);
            CFRelease(properties);
            
            // When we draw to Core Graphics, we lose orientation information,
            // which means the image below born of initWithCGIImage will be
            // oriented incorrectly sometimes. (Unlike the image born of initWithData
            // in didCompleteWithError.) So save it here and pass it on later.
#if SD_UIKIT || SD_WATCH
            _orientation = [SDWebImageCoderHelper imageOrientationFromEXIFOrientation:orientationValue];
#endif
        }
    }
    
    if (_width + _height > 0) {
        // Create the image 位图
        CGImageRef partialImageRef = CGImageSourceCreateImageAtIndex(_imageSource, 0, NULL);
        // 好像不解码，是不是不在乎呢?
        if (partialImageRef) {
#if SD_UIKIT || SD_WATCH
            // 根据位图获取图片
            image = [[UIImage alloc] initWithCGImage:partialImageRef scale:1 orientation:_orientation];
#elif SD_MAC
            image = [[UIImage alloc] initWithCGImage:partialImageRef size:NSZeroSize];
#endif
            CGImageRelease(partialImageRef);
            image.sd_imageFormat = [NSData sd_imageFormatForImageData:data];
        }
    }
    
    if (finished) {
        // 如果图片的所有数据都下载好了，就不需要渐进图了
        if (_imageSource) {
            CFRelease(_imageSource);
            _imageSource = NULL;
        }
    }
    
    return image;
}

- (UIImage *)decompressedImageWithImage:(UIImage *)image
                                   data:(NSData *__autoreleasing  _Nullable *)data
                                options:(nullable NSDictionary<NSString*, NSObject*>*)optionsDict {
#if SD_MAC
    return image;
#endif
#if SD_UIKIT || SD_WATCH
    BOOL shouldScaleDown = NO;
    if (optionsDict != nil) {
        NSNumber *scaleDownLargeImagesOption = nil;
        if ([optionsDict[SDWebImageCoderScaleDownLargeImagesKey] isKindOfClass:[NSNumber class]]) {
            scaleDownLargeImagesOption = (NSNumber *)optionsDict[SDWebImageCoderScaleDownLargeImagesKey];
        }
        if (scaleDownLargeImagesOption != nil) {
            shouldScaleDown = [scaleDownLargeImagesOption boolValue];
        }
    }
    if (!shouldScaleDown) {
        // 按原尺寸解码
        return [self sd_decompressedImageWithImage:image];
    } else {
        // 缩放解码
        UIImage *scaledDownImage = [self sd_decompressedAndScaledDownImageWithImage:image];
        if (scaledDownImage && !CGSizeEqualToSize(scaledDownImage.size, image.size)) {
            // if the image is scaled down, need to modify the data pointer as well
            SDImageFormat format = [NSData sd_imageFormatForImageData:*data];
            NSData *imageData = [self encodedDataWithImage:scaledDownImage format:format];
            if (imageData) {
                *data = imageData;
            }
        }
        return scaledDownImage;
    }
#endif
}

#if SD_UIKIT || SD_WATCH
- (nullable UIImage *)sd_decompressedImageWithImage:(nullable UIImage *)image {
    if (![[self class] shouldDecodeImage:image]) {
        return image;
    }
    
    // autorelease the bitmap context and all vars to help system to free memory when there are memory warning.
    // on iOS7, do not forget to call [[SDImageCache sharedImageCache] clearMemory];
    @autoreleasepool{
        
        CGImageRef imageRef = image.CGImage;
        // device color space
        CGColorSpaceRef colorspaceRef = SDCGColorSpaceGetDeviceRGB();
        BOOL hasAlpha = SDCGImageRefContainsAlpha(imageRef);
        // iOS display alpha info (BRGA8888/BGRX8888)
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        // 当图片不包含 alpha 的时候使用 kCGImageAlphaNoneSkipFirst ，否则使用 kCGImageAlphaPremultipliedFirst 。另外，这里也提到了字节顺序应该使用 32 位的主机字节顺序 kCGBitmapByteOrder32Host
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        
        // kCGImageAlphaNone is not supported in CGBitmapContextCreate.
        // Since the original image here has no alpha info, use kCGImageAlphaNoneSkipLast
        // to create bitmap graphics contexts without alpha info.
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     width,
                                                     height,
                                                     kBitsPerComponent,
                                                     0,
                                                     colorspaceRef,
                                                     bitmapInfo);
        if (context == NULL) {
            return image;
        }
        
        // Draw the image into the context and retrieve the new bitmap image without alpha
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGImageRef imageRefWithoutAlpha = CGBitmapContextCreateImage(context);
        UIImage *imageWithoutAlpha = [[UIImage alloc] initWithCGImage:imageRefWithoutAlpha scale:image.scale orientation:image.imageOrientation];
        CGContextRelease(context);
        CGImageRelease(imageRefWithoutAlpha);
        
        return imageWithoutAlpha;
    }
}

// 如果是很大的图片，那么一点点绘制到一个指定大小的小图上？
- (nullable UIImage *)sd_decompressedAndScaledDownImageWithImage:(nullable UIImage *)image {
    if (![[self class] shouldDecodeImage:image]) {
        return image;
    }
    
    if (![[self class] shouldScaleDownImage:image]) {
        return [self sd_decompressedImageWithImage:image];
    }
    
    CGContextRef destContext;
    
    // autorelease the bitmap context and all vars to help system to free memory when there are memory warning.
    // on iOS7, do not forget to call [[SDImageCache sharedImageCache] clearMemory];
    @autoreleasepool {
        CGImageRef sourceImageRef = image.CGImage;
        
        CGSize sourceResolution = CGSizeZero;
        sourceResolution.width = CGImageGetWidth(sourceImageRef);
        sourceResolution.height = CGImageGetHeight(sourceImageRef);
        float sourceTotalPixels = sourceResolution.width * sourceResolution.height;
        // Determine the scale ratio to apply to the input image
        // that results in an output image of the defined size.
        // see kDestImageSizeMB, and how it relates to destTotalPixels.
        //计算压缩比例，目标图片的像素总数／源图的像素总数 => 如果是压缩的大图，SD 设置最大的就是 kDestTotalPixels
        float imageScale = kDestTotalPixels / sourceTotalPixels;
        CGSize destResolution = CGSizeZero;
        destResolution.width = (int)(sourceResolution.width*imageScale);
        destResolution.height = (int)(sourceResolution.height*imageScale);
        
        // device color space
        CGColorSpaceRef colorspaceRef = SDCGColorSpaceGetDeviceRGB();
        BOOL hasAlpha = SDCGImageRefContainsAlpha(sourceImageRef);
        // iOS display alpha info (BGRA8888/BGRX8888)
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        
        // kCGImageAlphaNone is not supported in CGBitmapContextCreate.
        // Since the original image here has no alpha info, use kCGImageAlphaNoneSkipLast
        // to create bitmap graphics contexts without alpha info.
        destContext = CGBitmapContextCreate(NULL,
                                            destResolution.width,
                                            destResolution.height,
                                            kBitsPerComponent,
                                            0,
                                            colorspaceRef,
                                            bitmapInfo);
        
        if (destContext == NULL) {
            return image;
        }
        // 设置图像上下文的绘图质量
        CGContextSetInterpolationQuality(destContext, kCGInterpolationHigh);
        
        // Now define the size of the rectangle to be used for the
        // incremental blits from the input image to the output image.
        // we use a source tile width equal to the width of the source
        // image due to the way that iOS retrieves image data from disk.
        // iOS must decode an image from disk in full width 'bands', even
        // if current graphics context is clipped to a subrect within that
        // band. Therefore we fully utilize all of the pixel data that results
        // from a decoding opertion by achnoring our tile size to the full
        // width of the input image.
        //源图的切割块Size
        CGRect sourceTile = CGRectZero;
        sourceTile.size.width = sourceResolution.width;
        // The source tile height is dynamic. Since we specified the size
        // of the source tile in MB, see how many rows of pixels high it
        // can be given the input image width.
         // 计算来源块的高度
        sourceTile.size.height = (int)(kTileTotalPixels / sourceTile.size.width );
        sourceTile.origin.x = 0.0f;
        // The output tile is the same proportions as the input tile, but
        // scaled to image scale.
        CGRect destTile;
        destTile.size.width = destResolution.width;
        destTile.size.height = sourceTile.size.height * imageScale;
        destTile.origin.x = 0.0f;
        // The source seem overlap is proportionate to the destination seem overlap.
        // this is the amount of pixels to overlap each tile as we assemble the ouput image.
        float sourceSeemOverlap = (int)((kDestSeemOverlap/destResolution.height)*sourceResolution.height);
        CGImageRef sourceTileImageRef;
        // calculate the number of read/write operations required to assemble the
        // output image.
        int iterations = (int)( sourceResolution.height / sourceTile.size.height );
        // If tile height doesn't divide the image height evenly, add another iteration
        // to account for the remaining pixels.
        int remainder = (int)sourceResolution.height % (int)sourceTile.size.height;
        if(remainder) {
            iterations++;
        }
        // Add seem overlaps to the tiles, but save the original tile height for y coordinate calculations.
        float sourceTileHeightMinusOverlap = sourceTile.size.height;
        sourceTile.size.height += sourceSeemOverlap;
        destTile.size.height += kDestSeemOverlap;
        for( int y = 0; y < iterations; ++y ) {
            // 分段绘制到目标上下文上
            @autoreleasepool {
                //源块的纵坐标
                sourceTile.origin.y = y * sourceTileHeightMinusOverlap + sourceSeemOverlap;
                //目标块的纵坐标
                destTile.origin.y = destResolution.height - (( y + 1 ) * sourceTileHeightMinusOverlap * imageScale + kDestSeemOverlap);
                //根据计算的源图的数据和sourceTile，创建源图的一个子块
                sourceTileImageRef = CGImageCreateWithImageInRect( sourceImageRef, sourceTile );
                if( y == iterations - 1 && remainder ) {
                    float dify = destTile.size.height;
                    destTile.size.height = CGImageGetHeight( sourceTileImageRef ) * imageScale;
                    dify -= destTile.size.height;
                    destTile.origin.y += dify;
                }
                // 分段绘制到目标上下文上
                CGContextDrawImage( destContext, destTile, sourceTileImageRef );
                CGImageRelease( sourceTileImageRef );
            }
        }
        
        CGImageRef destImageRef = CGBitmapContextCreateImage(destContext);
        CGContextRelease(destContext);
        if (destImageRef == NULL) {
            return image;
        }
        UIImage *destImage = [[UIImage alloc] initWithCGImage:destImageRef scale:image.scale orientation:image.imageOrientation];
        CGImageRelease(destImageRef);
        if (destImage == nil) {
            return image;
        }
        return destImage;
    }
}
#endif

#pragma mark - Encode
- (BOOL)canEncodeToFormat:(SDImageFormat)format {
    switch (format) {
        case SDImageFormatWebP:
            // Do not support WebP encoding
            return NO;
        case SDImageFormatHEIC:
            // Check HEIC encoding compatibility
            return [[self class] canEncodeToHEICFormat];
        default:
            return YES;
    }
}

/**
 *  将 image 转成 NSData，以便缓存
 */
- (NSData *)encodedDataWithImage:(UIImage *)image format:(SDImageFormat)format {
    if (!image) {
        return nil;
    }
    
    // 如果没有图片格式，那么就当着 PNG 或者 JPEG
    if (format == SDImageFormatUndefined) {
        BOOL hasAlpha = SDCGImageRefContainsAlpha(image.CGImage);
        if (hasAlpha) {
            format = SDImageFormatPNG;
        } else {
            format = SDImageFormatJPEG;
        }
    }
    
    // 用于接受 image.CGImage 的data的？
    NSMutableData *imageData = [NSMutableData data];
    CFStringRef imageUTType = [NSData sd_UTTypeFromSDImageFormat:format];
    

    // 创建图像目的地
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, imageUTType, 1, NULL);
    if (!imageDestination) {
        // Handle failure.
        return nil;
    }
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
#if SD_UIKIT || SD_WATCH
    // 获取图片方向
    NSInteger exifOrientation = [SDWebImageCoderHelper exifOrientationFromImageOrientation:image.imageOrientation];
    [properties setValue:@(exifOrientation) forKey:(__bridge NSString *)kCGImagePropertyOrientation];
#endif
    
    // 添加图片和选项到目的地中，自动就会转成 NSData 放入到 imageData 中
    CGImageDestinationAddImage(imageDestination, image.CGImage, (__bridge CFDictionaryRef)properties);
    
    // Finalize the destination.
    if (CGImageDestinationFinalize(imageDestination) == NO) {
        // Handle failure.
        imageData = nil;
    }
    
    CFRelease(imageDestination);
    
    return [imageData copy];
}

#pragma mark - Helper
+ (BOOL)shouldDecodeImage:(nullable UIImage *)image {
    // Prevent "CGBitmapContextCreateImage: invalid context 0x0" error
    if (image == nil) {
        return NO;
    }
    
    // 动态图不需要解码
    if (image.images != nil) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)canDecodeFromHEICFormat {
    static BOOL canDecode = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#if TARGET_OS_SIMULATOR || SD_WATCH
        canDecode = NO;
#elif SD_MAC
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        if ([processInfo respondsToSelector:@selector(operatingSystemVersion)]) {
            // macOS 10.13+
            canDecode = processInfo.operatingSystemVersion.minorVersion >= 13;
        } else {
            canDecode = NO;
        }
#elif SD_UIKIT
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        if ([processInfo respondsToSelector:@selector(operatingSystemVersion)]) {
            // iOS 11+ && tvOS 11+
            canDecode = processInfo.operatingSystemVersion.majorVersion >= 11;
        } else {
            canDecode = NO;
        }
#endif
#pragma clang diagnostic pop
    });
    return canDecode;
}

+ (BOOL)canEncodeToHEICFormat {
    static BOOL canEncode = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableData *imageData = [NSMutableData data];
        CFStringRef imageUTType = [NSData sd_UTTypeFromSDImageFormat:SDImageFormatHEIC];
        
        // Create an image destination.
        CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, imageUTType, 1, NULL);
        if (!imageDestination) {
            // Can't encode to HEIC
            canEncode = NO;
        } else {
            // Can encode to HEIC
            CFRelease(imageDestination);
            canEncode = YES;
        }
    });
    return canEncode;
}

#if SD_UIKIT || SD_WATCH
/**
 * 判断图片是否比预定的大小要大，如果大，那么需要缩小
 */
+ (BOOL)shouldScaleDownImage:(nonnull UIImage *)image {
    BOOL shouldScaleDown = YES;
    
    CGImageRef sourceImageRef = image.CGImage;
    CGSize sourceResolution = CGSizeZero;
    sourceResolution.width = CGImageGetWidth(sourceImageRef);
    sourceResolution.height = CGImageGetHeight(sourceImageRef);
    float sourceTotalPixels = sourceResolution.width * sourceResolution.height;
    float imageScale = kDestTotalPixels / sourceTotalPixels;
    if (imageScale < 1) {
        shouldScaleDown = YES;
    } else {
        shouldScaleDown = NO;
    }
    
    return shouldScaleDown;
}
#endif

@end
