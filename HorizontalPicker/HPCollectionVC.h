//  The MIT License (MIT)
//  Copyright (c) 2013 <RABE_IT Services>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//
//
//
//  HPCollectionView.h
//  HorizontalPicker
//

#import <UIKit/UIKit.h>
#import "HPickerDefinitions.h"
#import "HorizontalPickerGlobal.h"

@protocol HPCollectionVCProvider;

@interface HPCollectionVC : UICollectionViewController
@property (nonatomic, strong) UIFont   *font;
@property (nonatomic, assign) CGFloat  maxWidth;               // max width of a single UICollectionViewCell
@property (nonatomic, assign) HPStyle  style;                  // HPStyle_iOS7 similar to UIPickerView in iOS7
@property (nonatomic, strong) UIColor  *tintColor;             // center cell's text color when not HPStyle_iOS7
@property (assign, nonatomic) BOOL     cropStringIfNecessary;

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout collectionVCProvider:(id <HPCollectionVCProvider>)provider;

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;
- (NSInteger)indexForCenterCellFromCollectionView:(UICollectionView *)collectionView;
- (void)changeSelectionInCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;
- (NSInteger)selectedRow;
@end

@protocol HPCollectionVCProvider <NSObject>
@required
- (NSInteger)numberOfRowsInCollectionViewController:(HPCollectionVC *)collectionVC;
- (NSString *)collectionViewController:(HPCollectionVC *)collectionVC titleForRow:(NSInteger)row;
- (void)collectionViewController:(HPCollectionVC *)collectionVC didSelectRow:(NSInteger)row;
@end
