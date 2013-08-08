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
//  HPCollectionView.m
//  HorizontalPicker
//

#import "HPCollectionVC.h"
#import "HPickerDefinitions.h"
#import "HPCollectionViewCell.h"

@interface HPCollectionVC() <HPCollectionViewCellDelegate>
@property (nonatomic, weak) id <HPCollectionVCProvider> provider;
@property (nonatomic, strong) NSIndexPath  *selectedCellIndexPath;
@end

@implementation HPCollectionVC

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout collectionVCProvider:(id<HPCollectionVCProvider>)provider
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _provider = provider;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTintColor:) name:TintColorChangedNotification object:provider];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - CollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return [_provider numberOfRowsInCollectionViewController:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HPCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTVReuseID_HPCollectionViewStyle forIndexPath:indexPath];
    cell.delegate = self;
    
    NSString *string = [_provider collectionViewController:self titleForRow:indexPath.row];
    cell.text        = [self cropStringFromString:string maxWidth:CGRectGetWidth(cell.bounds)-16 font:self.font];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self scrollToIndex:indexPath.row animated:YES];
    [self performSelector:@selector(reportDidSelectRowAtIndexPath:) withObject:indexPath afterDelay:0.1];
    
    [self changeSelectionInCollectionView:collectionView indexPath:indexPath];
}

#pragma mark - CollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [_provider collectionViewController:self titleForRow:indexPath.row];
    CGSize size = CGSizeMake(MIN(_maxWidth, [text sizeWithFont:_font].width + 16 + 10), CGRectGetHeight(collectionView.bounds));

    return size;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = [self indexForCenterCellFromCollectionView:(UICollectionView *)scrollView];
    [self scrollToIndex:index animated:YES];

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self performSelector:@selector(reportDidSelectRowAtIndexPath:) withObject:indexPath afterDelay:0.1];
    
    [self changeSelectionInCollectionView:(UICollectionView *)scrollView indexPath:indexPath];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == FALSE) {
        NSInteger index = [self indexForCenterCellFromCollectionView:(UICollectionView *)scrollView];
        [self scrollToIndex:index animated:YES];

        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [self performSelector:@selector(reportDidSelectRowAtIndexPath:) withObject:indexPath afterDelay:0.1];
        
        [self changeSelectionInCollectionView:(UICollectionView *)scrollView indexPath:indexPath];
    }
}

- (NSInteger)indexForCenterCellFromCollectionView:(UICollectionView *)collectionView
{
    NSInteger index = 0;
    
    // check if baseAdjustments where made in HorizontalPickerView
    if (collectionView.contentOffset.x) {
        CGPoint point = collectionView.frame.origin;
        point.x += collectionView.frame.size.width / 2;
        point.y += collectionView.frame.size.height / 2;
        point = [collectionView convertPoint:point fromView:collectionView.superview];
        
        index = [collectionView indexPathForItemAtPoint:point].row;
    }
    
    return index;
}

#pragma mark - Crop Label Text

- (NSString *)cropStringFromString:(NSString *)text maxWidth:(CGFloat)maxWidth font:(UIFont *)font
{
    NSMutableString *newText = [NSMutableString string];
    [newText setString:text];
    NSRange range = NSMakeRange(newText.length, 1);
    
    BOOL needsCut = NO;
    
    CGSize size = [newText sizeWithFont:font];
    
    while (size.width > maxWidth) {
        range.location -= 1;
        [newText deleteCharactersInRange:range];
        needsCut = YES;
        size = [newText sizeWithFont:font];
    };
    
    if (needsCut == YES) {
        range.location -= 3;
        range.length    = 3;
        [newText replaceCharactersInRange:range withString:@"..."];
    }
    return [newText copy];
}

#pragma mark - Scrolling

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    
    CGFloat halfWidth = lroundf(CGRectGetWidth(self.collectionView.bounds) / 2);
    
    CGPoint offset = CGPointMake(CGRectGetMidX(attributes.frame) - halfWidth, 0);
    [self.collectionView setContentOffset:offset animated:animated];
}

#pragma mark - Reporting

- (void)reportDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_provider collectionViewController:self didSelectRow:indexPath.row];
}

#pragma mark - Selected Cell Index

- (NSInteger)selectedRow
{
    return self.selectedCellIndexPath.row;
}

#pragma mark - Change Cell Selection

- (void)changeSelectionInCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath
{
    if (_style == HPStyleNormal) {
        [collectionView deselectItemAtIndexPath:self.selectedCellIndexPath animated:YES];
        
        self.selectedCellIndexPath = indexPath;
        [self performSelector:@selector(selectItemAtIndexPath:) withObject:self.selectedCellIndexPath afterDelay:0.25];
    }
    else {
        self.selectedCellIndexPath = indexPath;
    }
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView selectItemAtIndexPath:self.selectedCellIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
}

#pragma mark - Tint Color Changes

- (void)changeTintColor:(NSNotification *)notification
{
    self.tintColor = [notification userInfo][TINT_COLOR];
    if (_style == HPStyleNormal) {
        [self.collectionView selectItemAtIndexPath:self.selectedCellIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }
}

#pragma mark - HPCollectionViewCellDelegate

- (UIColor *)tintColorForCell:(HPCollectionViewCell *)cell
{
    return self.tintColor;
}

- (UIFont *)fontForCell:(HPCollectionViewCell *)cell
{
    return self.font;
}

- (HPStyle)styleForCell:(HPCollectionViewCell *)cell
{
    return _style;
}

- (id)notificationObjectForCell:(HPCollectionViewCell *)cell
{
    return _provider;
}

@end
