//
//  HPCollectionView.h
//  HorizontalPicker
//
//  Created by Bernd Rabe on 02.08.13.
//  Copyright (c) 2013 RABE_IT Services. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HPCollectionViewProvider;

@interface HPCollectionVC : UICollectionViewController
@property (nonatomic, weak) id <HPCollectionViewProvider> collectionViewProvider;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) CGFloat maxWidth;

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;
@end

@protocol HPCollectionViewProvider <NSObject>
@required
- (NSInteger)numberOfRowsInCollectionViewController:(HPCollectionVC *)collectionVC;
- (NSString *)collectionViewController:(HPCollectionVC *)collectionVC titleForRow:(NSInteger)row;
- (void)collectionViewController:(HPCollectionVC *)collectionVC didSelectRow:(NSInteger)row;
@end
