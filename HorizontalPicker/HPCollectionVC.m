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

- (void)configureEdgeInsetsForCollectionView:(UICollectionView *)collectionView
{
    NSInteger lastIndex = [collectionView numberOfItemsInSection:0] - 1;
    if (lastIndex != -1) {
        CGFloat centerX = collectionView.center.x;
        UICollectionViewCell *lastCell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:lastIndex inSection:0]];
        UICollectionViewCell *firstCell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        
        CGFloat rightInset = centerX - CGRectGetWidth(lastCell.bounds)/2;
        CGFloat leftInset  = centerX - CGRectGetWidth(firstCell.bounds)/2;
        
        collectionView.contentInset = UIEdgeInsetsMake(0, leftInset, 0, rightInset);
    }
}

- (void)loadView
{
    [super loadView];
}

#pragma mark - CollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return [_collectionViewProvider numberOfRowsInCollectionViewController:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HPCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTVReuseID_HPCollectionViewStyle forIndexPath:indexPath];
    cell.text = [self cropStringFromString:[_collectionViewProvider collectionViewController:self titleForRow:indexPath.row] width:CGRectGetWidth(cell.bounds) font:self.font];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark - CollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [_collectionViewProvider collectionViewController:self titleForRow:indexPath.row];
    CGSize size = CGSizeMake(MIN(_maxWidth, [text sizeWithFont:self.font].width + 16 + 1 + 5), CGRectGetHeight(collectionView.bounds));
    
    NSLog(@"%@ %@", text, NSStringFromCGSize(size));
    return size;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat unguidedOffsetY = targetContentOffset->y;
    CGFloat guidedOffsetY = 0.;
    
    if (unguidedOffsetY > 0) {
        int remainder = lroundf(unguidedOffsetY) % lroundf(CGRectGetHeight(self.collectionView.bounds));
        guidedOffsetY = unguidedOffsetY - remainder + (remainder < (CGRectGetHeight(self.collectionView.bounds) / 2) ? CGRectGetHeight(self.collectionView.bounds) : 0);
    }
    
    targetContentOffset->y = guidedOffsetY;
}

#pragma mark - Crop Label Text

- (NSString *)cropStringFromString:(NSString *)text width:(CGFloat)maxWidth font:(UIFont *)font
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


@end
