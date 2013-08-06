//
//  HPCollectionViewCell.h
//  HorizontalPicker
//
//  Created by Bernd Rabe on 02.08.13.
//  Copyright (c) 2013 RABE_IT Services. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "HPickerDefinitions.h"
#import "HorizontalPickerGlobal.h"

@interface HPCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) NSString  *text;
@property (nonatomic, assign) HPStyle   style;
@property (nonatomic, strong) UIColor   *tintColor;             // center cell's text color when not HPStyle_iOS7

@end
