//
//  simonPDFRenderer.m
//  SIMon
//
//  Created by Michael Enstone on 28/10/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import "simonPDFRenderer.h"

@implementation simonPDFRenderer

-(void)drawPDF:(NSString*)fileName withReport:(Reports *)report
{
    // Create the PDF context using the default page size of 612 x 792.
    UIGraphicsBeginPDFContextToFile(fileName, CGRectZero, nil);
    // Mark the beginning of a new page.
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
    
    [simonPDFRenderer drawHeaderTemplate:report];
    
    CGFloat position = 0;
    position = position + StartPoint;
    int count = 1;
    
    for (ReportItems *reportItem in report.reportItems) {
        CGFloat tableHeight = [simonPDFRenderer getHeight:reportItem];
        if ((position + tableHeight) > (792 - margin)) {
            position = margin;
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
        }
        [simonPDFRenderer drawItemTableTemplate:reportItem inPosition:position count:count type:[report.reportType boolValue]];
        CGPoint imageOrigin = CGPointMake(308, position + 31 + imagePadding);
        [simonPDFRenderer addImages:reportItem atPosition:imageOrigin];
        position = position + tableHeight;
        count = count+1;
    }
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
}

+(void)drawText:(NSString*)text withLabel:(UILabel*)label withColor:(CGColorRef)color
{
    //    create font
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)label.font.fontName, label.font.pointSize, NULL);
    
    CGFloat textColors[5] = {1,1,1,1,1};
    CGColorSpaceRef cmykColorSpace = CGColorSpaceCreateDeviceCMYK();
    CGColorRef textColor = CGColorCreate(cmykColorSpace, textColors);
    
    if (color) {
        textColor = color;
    }
    
    //    create attributed string
    CFMutableAttributedStringRef attrStr = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString (attrStr, CFRangeMake(0, 0), (CFStringRef) text);
    
    //    set font and color attribute
    CFAttributedStringSetAttribute(attrStr, CFRangeMake(0, CFAttributedStringGetLength(attrStr)), kCTFontAttributeName, font);
    CFAttributedStringSetAttribute(attrStr, CFRangeMake(0, CFAttributedStringGetLength(attrStr)), kCTForegroundColorAttributeName, textColor);
    
    //    create paragraph style and assign text alignment to it    return nil;
    CTTextAlignment alignment = NSTextAlignmentToCTTextAlignment(label.textAlignment);
    CTParagraphStyleSetting _settings[] = {    {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment} };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(_settings, sizeof(_settings) / sizeof(_settings[0]));
    
    //    set paragraph style attribute
    CFAttributedStringSetAttribute(attrStr, CFRangeMake(0, CFAttributedStringGetLength(attrStr)), kCTParagraphStyleAttributeName, paragraphStyle);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrStr);
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGRect frameRect = label.frame;
    CGPathAddRect(framePath, NULL, frameRect);
    
    // Get the frame that will do the rendering.
    CFRange currentRange = CFRangeMake(0, 0);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
    
    // Get the graphics context.
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    CGContextTranslateCTM(currentContext, 0, (frameRect.origin.y*2) + frameRect.size.height);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    // Draw the frame.
    CTFrameDraw(frameRef, currentContext);
    
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    CGContextTranslateCTM(currentContext, 0, (-1)*((frameRect.origin.y*2) + frameRect.size.height));
    
    CFRelease(font);
    CFRelease(paragraphStyle);
    CFRelease(frameRef);
    CFRelease(attrStr);
    CFRelease(framesetter);
}

+(void)drawLineFromPoint:(CGPoint)from toPoint:(CGPoint)to
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2.0);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat components[] = {0.2, 0.2, 0.2, 0.3};
    
    CGColorRef color = CGColorCreate(colorspace, components);
    
    CGContextSetStrokeColorWithColor(context, color);
    
    
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
    
    CGContextStrokePath(context);
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
    
}

+(void)drawImage:(UIImage*)image inRect:(CGRect)rect
{
    
    [image drawInRect:rect];
    
}

+(void)drawHeaderTemplate:(Reports *)report
{
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"simonPDFTemplate" owner:nil options:nil];
    
    UIView* mainView = [objects objectAtIndex:0];
    
    for (UIView* view in [mainView subviews]) {
        if([view isKindOfClass:[UILabel class]])
        {
            UILabel* label = (UILabel*)view;
            NSMutableString *text = [[NSMutableString alloc] init];
            int64_t tag = label.tag;
            
            switch (tag) {
                case 1: {
                    if ([report.reportType boolValue]) {
                        [text appendString:@"Site Visit Report - "];
                    } else {
                        [text appendString:@"Progress Report - "];
                    }
                    NSDate *myDate = report.reportDate;
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"dd/MM/yyyy"];
                    NSString *prettyVersion = [dateFormat stringFromDate:myDate];
                    [text appendString:prettyVersion];
                    break;
                }
                case 2: {
                    [text appendString:report.project.projectName];
                    break;
                }
                case 3: {
                    [text appendString:report.supervisor];
                    break;
                }
                case 4: {
                    [text appendString:@"Report Ref: "];
                    [text appendString:report.reportRef];
                    break;
                }
                    
            }
            
            [self drawText:text withLabel:label withColor:nil];
            
        } else if ([view isKindOfClass:[UIImageView class]]) {
            
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            NSString *logoPath = [defaults objectForKey:@"PDFLogoPath_simon"];
            
            NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            UIImage *image = [[UIImage alloc] init];
            UIImageView *imageView = (UIImageView*)view;
            
            if ([logoPath length] > 4) {
                image = [UIImage imageWithContentsOfFile:[docDirPath stringByAppendingPathComponent:logoPath]];
                CGFloat imageHeight = (image.size.height / image.size.width) * imageView.frame.size.width;
                if (imageHeight <= imageView.frame.size.height) {
                    imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, imageHeight);
                } else {
                    CGFloat imageWidth = (image.size.width / image.size.height) * imageView.frame.size.height;
                    imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageWidth, imageView.frame.size.height);
                }
            } else {
                image = imageView.image;
            }
            
            [simonPDFRenderer drawImage:image inRect:imageView.frame];
            
        }
    }
}

+(void)drawItemTableTemplate:(ReportItems *)reportItem inPosition:(CGFloat)position count:(int)count type:(BOOL)type
{
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"simonPDFTableTemplate" owner:nil options:nil];
    
    UIView* mainView = [objects objectAtIndex:0];
    
    for (UIView* view in [mainView subviews]) {
        if([view isKindOfClass:[UILabel class]])
        {
            UILabel* label = (UILabel*)view;
            NSMutableString *text = [[NSMutableString alloc] init];
            int64_t tag = label.tag;
            label.frame = CGRectMake(label.frame.origin.x, (label.frame.origin.y + position), label.frame.size.width, label.frame.size.height);
            
            CGColorRef textColor;
            CGColorSpaceRef cmykColorSpace = CGColorSpaceCreateDeviceCMYK();
            CGColorRef headerColor;
            CGColorRef headerTextColor = nil;
            CGFloat textColors[5] = {1,1,1,1,1};
            textColor = CGColorCreate(cmykColorSpace, textColors);
            
            if ([reportItem.onTime isEqualToString: @"Ahead"] && !type) {
                CGFloat headerColors[5] = {0.17,0.0,0.52,0.27,1};
                headerColor = CGColorCreate(cmykColorSpace, headerColors);
            } else if ([reportItem.onTime isEqualToString: @"Behind"] && !type) {
                CGFloat headerColors[5] = {0.0,1.0,1.0,0.39,1};
                headerColor = CGColorCreate(cmykColorSpace, headerColors);
                CGFloat textColors[5] = {0.0,0.0,0.0,0.0,1};
                headerTextColor = CGColorCreate(cmykColorSpace, textColors);
            } else {
                CGFloat headerColors[5] = {0.0,0.2,1.0,0.0,1};
                headerColor = CGColorCreate(cmykColorSpace, headerColors);
            }
            
            switch (tag) {
                case 0: {
                    [text appendString:@" Item "];
                    [text appendString:[NSString stringWithFormat:@"%i",count]];
                    [simonPDFRenderer drawFilledRect:label.frame withColor:headerColor];
                    textColor = headerTextColor;
                    break;
                }
                case 1: {
                    if (!type) {
                        [text appendString:@"Progress: "];
                        [text appendString:[reportItem.progress stringValue]];
                        [text appendString:@"% "];
                        textColor = headerTextColor;
                    }
                    [simonPDFRenderer drawFilledRect:label.frame withColor:headerColor];
                    break;
                }
                case 3: {
                    [text appendString:reportItem.location.locationName];
                    break;
                }
                case 5: {
                    [text appendString:reportItem.activityOrItem];
                    break;
                }
                case 6: {
                    [text appendString:@"Description: "];
                    [text appendString:reportItem.itemDescription];
                    NSAttributedString *attributedText =
                    [[NSAttributedString alloc]
                     initWithString:text
                     attributes:@
                     {
                     NSFontAttributeName: label.font
                     }];
                    CGRect rect = [attributedText boundingRectWithSize:(CGSize){label.frame.size.width, CGFLOAT_MAX}
                                                               options:NSStringDrawingUsesLineFragmentOrigin
                                                               context:nil];
                    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, rect.size.width, rect.size.height + 21);
                    break;
                }
                default: {
                    [text appendString:label.text];
                    break;
                }
            }
            
            [self drawText:text withLabel:label withColor:textColor];
            
        } else if ([view isKindOfClass:[UIImageView class]]) {
            
            UIImageView *imageView = (UIImageView*)view;
            
            [simonPDFRenderer drawImage:imageView.image inRect:imageView.frame];
            
        }
    }
}

+(CGFloat)getHeight:(ReportItems *)reportItem {
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"simonPDFTableTemplate" owner:nil options:nil];
    UIView* mainView = [objects objectAtIndex:0];
    CGFloat heightText = 0;
    CGFloat heightImages = 0;
    
    for (UIView* view in [mainView subviews]) {
        if([view isKindOfClass:[UILabel class]])
        {
            UILabel* label = (UILabel*)view;
            NSMutableString *text = [[NSMutableString alloc] init];
            int64_t tag = label.tag;
            
            switch (tag) {
                
                case 6: {
                    [text appendString:@"Description: "];
                    [text appendString:reportItem.itemDescription];
                    NSAttributedString *attributedText =
                    [[NSAttributedString alloc]
                     initWithString:text
                     attributes:@
                     {
                     NSFontAttributeName: label.font
                     }];
                    CGRect rect = [attributedText boundingRectWithSize:(CGSize){label.frame.size.width, CGFLOAT_MAX}
                                                               options:NSStringDrawingUsesLineFragmentOrigin
                                                               context:nil];
                    heightText = label.frame.origin.y + rect.size.height + 21;
                    break;
                }
                default: {
                    break;
                }
            }
            
        }
    }

    CGFloat rowHeight = 0;
    CGFloat firstImageHeight = 0;
    int columncount = 1;
    CGFloat totalWidth = 208;
    
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    if (reportItem.photos.count > 1) {
        CGFloat smallWidth = (totalWidth-imagePadding)/2;
        for (Photo *photo in reportItem.photos) {
            UIImage *image = [UIImage imageWithContentsOfFile:[docDirPath stringByAppendingPathComponent:photo.photoPath]];
            CGFloat imageHeight = (image.size.height / image.size.width) * smallWidth;
            if (columncount == 1) {
                firstImageHeight = imageHeight;
                columncount = 2;
            } else {
                rowHeight = rowHeight + MAX(firstImageHeight,imageHeight) + imagePadding;
                firstImageHeight = 0;
                columncount = 1;
            }
        }
        heightImages = rowHeight + firstImageHeight + imagePadding + 31;
    } else if (reportItem.photos.count == 1) {
        for (Photo *photo in reportItem.photos) {
            UIImage *image = [UIImage imageWithContentsOfFile:[docDirPath stringByAppendingPathComponent:photo.photoPath]];
            heightImages = (image.size.height / image.size.width) * totalWidth + imagePadding * 2 + 31;
        }
    } else {
        UIImage *image = [UIImage imageNamed:@"placeholder.png"];
        heightImages = (image.size.height / image.size.width) * totalWidth + imagePadding * 2 + 31;
    }
    
    return MAX(heightText,heightImages);
}

+(void)drawFilledRect:(CGRect)rect withColor:(CGColorRef)color {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextAddRect(context, rect);
    CGContextStrokePath(context);
    CGContextSetFillColorWithColor(context, color);
    CGContextFillRect(context, rect);
}

+(void)addImages:(ReportItems *)reportItem atPosition:(CGPoint)position {
    
    CGFloat rowHeight = 0;
    CGFloat firstImageHeight = 0;
    int columncount = 1;
    CGFloat totalWidth = 208;
    
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    if (reportItem.photos.count > 1) {
        CGFloat smallWidth = (totalWidth-imagePadding)/2;
        for (Photo *photo in reportItem.photos) {
            UIImage *image = [UIImage imageWithContentsOfFile:[docDirPath stringByAppendingPathComponent:photo.photoPath]];
            CGFloat imageHeight = (image.size.height / image.size.width) * smallWidth;
            if (columncount == 1) {
                CGRect frame = CGRectMake(position.x, position.y + rowHeight, smallWidth, imageHeight);
                [simonPDFRenderer drawImage:image inRect:frame];
                firstImageHeight = imageHeight;
                columncount = 2;
            } else {
                CGRect frame = CGRectMake(position.x + smallWidth + imagePadding, position.y + rowHeight, smallWidth, imageHeight);
                [simonPDFRenderer drawImage:image inRect:frame];
                rowHeight = rowHeight + MAX(firstImageHeight,imageHeight) + imagePadding;
                columncount = 1;
            }
        }
    } else if (reportItem.photos.count == 1) {
        for (Photo *photo in reportItem.photos) {
            UIImage *image = [UIImage imageWithContentsOfFile:[docDirPath stringByAppendingPathComponent:photo.photoPath]];
            CGFloat imageHeight = (image.size.height / image.size.width) * totalWidth;
            CGRect frame = CGRectMake(position.x, position.y, totalWidth, imageHeight);
            [simonPDFRenderer drawImage:image inRect:frame];
        }
    } else {
        UIImage *image = [UIImage imageNamed:@"placeholder.jpg"];
        CGFloat imageHeight = (image.size.height / image.size.width) * totalWidth;
        CGRect frame = CGRectMake(position.x, position.y, totalWidth, imageHeight);
        [simonPDFRenderer drawImage:image inRect:frame];
    }
    
}
@end