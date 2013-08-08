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

@protocol HPCollectionViewCellDelegate;

@interface HPCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id <HPCollectionViewCellDelegate> delegate;
@property (nonatomic, strong) NSString  *text;
@property (nonatomic, strong) NSDate *date;

@end

@protocol HPCollectionViewCellDelegate <NSObject>
@required
- (UIColor *)tintColorForCell:(HPCollectionViewCell *)cell;
- (HPStyle)styleForCell:(HPCollectionViewCell *)cell;
- (UIFont *)fontForCell:(HPCollectionViewCell *)cell;
- (id)notificationObjectForCell:(HPCollectionViewCell *)cell;
@end