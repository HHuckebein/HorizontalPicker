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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.selectedRowLabel.text = [NSString stringWithFormat:@"%d", self.horizontalPicker.selectedRow];

    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.horizontalPicker selectRow:10 animated:YES];
    });
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
    self.selectedRowLabel.text = [NSString stringWithFormat:@"%d", row];
}


#pragma mark - DataSourec

- (NSArray *)dataSource
{
    if (nil == _dataSource) {
        _dataSource = @[@"Zero", @"One", @"Two", @"Three", @"Four", @"Five", @"Six", @"Seven", @"Eight", @"Nine", @"Ten", @"One Billion Billion", @"Five Hundred"];
    }
    return _dataSource;
}

@end
