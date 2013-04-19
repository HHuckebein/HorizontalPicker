//
//  FirstViewController.m
//  HPDemo
//
//  Created by Bernd Rabe on 19.04.13.
//  Copyright (c) 2013 RABE_IT Services. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()
@property (strong, nonatomic) NSArray *dataSource;
@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  HPickerViewDataSource

- (NSInteger)numberOfRowsInPickerView:(HPickerView *)pickerView
{
    return self.dataSource.count;
}

#pragma mark -  HPickerViewDelegate

- (NSString *)pickerView:(HPickerView *)pickerView titleForRow:(NSInteger)row
{
    return [NSNumberFormatter localizedStringFromNumber:self.dataSource[row] numberStyle:NSNumberFormatterDecimalStyle];
}

- (void)pickerView:(HPickerView *)pickerView didSelectRow:(NSInteger)row
{
    NSLog(@"Row %d", row);
}


#pragma mark - DataSourec

- (NSArray *)dataSource
{
    if (nil == _dataSource) {
        _dataSource = @[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    }
    return _dataSource;
}

@end
