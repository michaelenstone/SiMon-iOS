//
//  simonPDFRenderer.h
//  SIMon
//
//  Created by Michael Enstone on 28/10/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <CoreGraphics/CoreGraphics.h>
#import "Reports.h"
#import "ReportItems.h"
#import "Photo.h"
#import "Projects.h"
#import "Locations.h"

@interface simonPDFRenderer : NSObject

-(void)drawPDF:(NSString*)pdfFileName withReport:(Reports *)report;
+(void)drawText:(NSString*)text withLabel:(UILabel*)label withColor:(CGColorRef)color;

@end

static const CGFloat StartPoint = 177;
static const CGFloat margin = 60;
static const CGFloat imagePadding = 10;