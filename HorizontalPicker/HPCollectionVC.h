//
//  HPCollectionView.h
//  HorizontalPicker
//
//  Created by Bernd Rabe on 02.08.13.
//  Copyright (c) 2013 RABE_IT Services. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPickerDefinitions.h"
#import "HorizontalPickerGlobal.h"

@protocol HPCollectionViewProvider;

@interface HPCollectionVC : UICollectionViewController
@property (nonatomic, weak) id <HPCollectionViewProvider>   collectionViewProvider;
@property (nonatomic, strong) UIFont                        *font;
@property (nonatomic, assign) CGFloat                       maxWidth;               // max width of a single UICollectionViewCell
@property (nonatomic, assign) HPStyle                       style;                  // HPStyle_iOS7 similar to UIPickerView in iOS7
@property (nonatomic, strong) UIColor                       *tintColor;             // center cell's text color when not HPStyle_iOS7

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;
- (NSInteger)indexForCenterCellFromCollectionView:(UICollectionView *)collectionView;
@end

@protocol HPCollectionViewProvider <NSObject>
@required
- (NSInteger)numberOfRowsInCollectionViewController:(HPCollectionVC *)collectionVC;
- (NSString *)collectionViewController:(HPCollectionVC *)collectionVC titleForRow:(NSInteger)row;
- (void)collectionViewController:(HPCollectionVC *)collectionVC didSelectRow:(NSInteger)row;
@end
