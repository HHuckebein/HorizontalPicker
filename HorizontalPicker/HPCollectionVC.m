//
//  HPCollectionView.m
//  HorizontalPicker
//
//  Created by Bernd Rabe on 02.08.13.
//  Copyright (c) 2013 RABE_IT Services. All rights reserved.
//

#import "HPCollectionVC.h"
#import "HPickerDefinitions.h"
#import "HPCollectionViewCell.h"

@interface HPCollectionVC()
@end

@implementation HPCollectionVC

#pragma mark - CollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return [_collectionViewProvider numberOfRowsInCollectionViewController:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HPCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTVReuseID_HPCollectionViewStyle forIndexPath:indexPath];
    NSString *string = [_collectionViewProvider collectionViewController:self titleForRow:indexPath.row];
    cell.text = [self cropStringFromString:string maxWidth:CGRectGetWidth(cell.bounds)-16 font:self.font];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self scrollToIndex:indexPath.row animated:YES];
}

#pragma mark - CollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [_collectionViewProvider collectionViewController:self titleForRow:indexPath.row];
    CGSize size = CGSizeMake(MIN(_maxWidth, [text sizeWithFont:_font].width + 16 + 10), CGRectGetHeight(collectionView.bounds));

    return size;
}

#pragma mark - UIScrollViewDelegate

//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    CGFloat unguidedOffsetX = targetContentOffset->x;
//    CGFloat guidedOffsetX = unguidedOffsetX;
//    
//    if (ABS(unguidedOffsetX) > 0) {
//        int remainder = lroundf(unguidedOffsetX) % lroundf(_cellHeight);
//        if (remainder) {
//            guidedOffsetY -= remainder;
//            guidedOffsetY += (remainder < (_cellHeight / 2) ? _cellHeight : 0);
//        }
//    }
//    
//    targetContentOffset->y = guidedOffsetY;
//
//    
//    CGFloat unguidedOffsetY = targetContentOffset->y;
//    CGFloat guidedOffsetY = 0.;
//    
//    if (unguidedOffsetY > 0) {
//        int remainder = lroundf(unguidedOffsetY) % lroundf(CGRectGetHeight(self.collectionView.bounds));
//        guidedOffsetY = unguidedOffsetY - remainder + (remainder < (CGRectGetHeight(self.collectionView.bounds) / 2) ? CGRectGetHeight(self.collectionView.bounds) : 0);
//    }
//    
//    targetContentOffset->y = guidedOffsetY;
//}

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
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    
    CGFloat halfWidth = lroundf(CGRectGetWidth(self.collectionView.bounds) / 2);
    
    CGPoint offset = CGPointMake(cell.center.x - halfWidth, 0);
    [self.collectionView setContentOffset:offset animated:animated];
}

@end
