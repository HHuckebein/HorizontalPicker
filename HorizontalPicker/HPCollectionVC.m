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
    cell.text      = [self cropStringFromString:string maxWidth:CGRectGetWidth(cell.bounds)-16 font:self.font];
    cell.style     = _style;
    
    if (CGRectContainsPoint(cell.frame, collectionView.center)) {
        cell.tintColor = self.tintColor;
    }
    
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollToIndex:[self indexForCenterCellFromCollectionView:(UICollectionView *)scrollView] animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == FALSE) {
        [self scrollToIndex:[self indexForCenterCellFromCollectionView:(UICollectionView *)scrollView] animated:YES];
    }
}

- (NSInteger)indexForCenterCellFromCollectionView:(UICollectionView *)collectionView
{
    CGPoint point = collectionView.frame.origin;
    point.x += collectionView.frame.size.width / 2;
    point.y += collectionView.frame.size.height / 2;
    point = [collectionView convertPoint:point fromView:collectionView.superview];
    
    NSInteger index = [collectionView indexPathForItemAtPoint:point].row;
    
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
    HPCollectionViewCell *cell = (HPCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    cell.tintColor = self.tintColor;

    CGFloat halfWidth = lroundf(CGRectGetWidth(self.collectionView.bounds) / 2);
    
    CGPoint offset = CGPointMake(cell.center.x - halfWidth, 0);
    [self.collectionView setContentOffset:offset animated:animated];
    
    [self performSelector:@selector(reportDidSelectRowAtIndexPath:) withObject:indexPath afterDelay:0.1];
}

#pragma mark - Reporting

- (void)reportDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_collectionViewProvider collectionViewController:self didSelectRow:indexPath.row];
}

@end
