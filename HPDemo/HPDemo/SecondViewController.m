//
//  SecondViewController.m
//  HPDemo
//
//  Created by Bernd Rabe on 19.04.13.
//  Copyright (c) 2013 RABE_IT Services. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()
@property (strong, nonatomic) NSArray *dataSource;
@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [HorizontalPickerView class];
    
    
    self.horizontalPicker.tintColor = [UIColor colorWithRed:253/255. green:154/255. blue:9/255. alpha:1.];
    self.horizontalPicker.font = [UIFont boldSystemFontOfSize:10.f];
    self.horizontalPicker.cropStringIfNecessary = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  HPickerViewDataSource

- (NSInteger)numberOfRowsInPickerView:(HorizontalPickerView *)pickerView
{
    return self.dataSource.count;
}

#pragma mark -  HPickerViewDelegate

- (NSString *)pickerView:(HorizontalPickerView *)pickerView titleForRow:(NSInteger)row
{
    return self.dataSource[row];
}

- (void)pickerView:(HorizontalPickerView *)pickerView didSelectRow:(NSInteger)row
{
    self.selectedRowLabel.text = [NSString stringWithFormat:@"%@", @(row)];
}


#pragma mark - DataSourec

- (NSArray *)dataSource
{
    if (nil == _dataSource) {
        _dataSource = @[@"Zero", @"One", @"Two", @"Three", @"Four", @"Five", @"Six", @"Seven", @"Eight", @"Nine", @"Ten", @"One Billion Billion", @"Six Thousand Five Hundred Forty Six"];
    }
    return _dataSource;
}

@end
