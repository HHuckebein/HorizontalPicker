//
//  FirstViewController.m
//  HPDemo
//
//  Created by Bernd Rabe on 19.04.13.
//  Copyright (c) 2013 RABE_IT Services. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()
@property (weak  , nonatomic) NSArray *source;
@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSArray *dataSource2;
@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.horizontalPicker.style = HPStyle_iOS7;
    self.source = self.dataSource;
    self.horizontalPicker.font = [UIFont boldSystemFontOfSize:10.f];
    
	// Do any additional setup after loading the view, typically from a nib.
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
}

#pragma mark -  HPickerViewDataSource

- (NSInteger)numberOfRowsInPickerView:(HorizontalPickerView *)pickerView
{
    return self.source.count;
}

#pragma mark -  HPickerViewDelegate

- (NSString *)pickerView:(HorizontalPickerView *)pickerView titleForRow:(NSInteger)row
{
    return [NSNumberFormatter localizedStringFromNumber:self.source[row] numberStyle:NSNumberFormatterDecimalStyle];
}

- (void)pickerView:(HorizontalPickerView *)pickerView didSelectRow:(NSInteger)row
{
    self.selectedRowLabel.text = [NSString stringWithFormat:@"%d", row];
}


#pragma mark - DataSourec

- (NSArray *)dataSource
{
    if (nil == _dataSource) {
        _dataSource = @[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12, @13, @14, @15, @16, @17, @18, @19, @20];
    }
    return _dataSource;
}

- (NSArray *)dataSource2
{
    if (nil == _dataSource2) {
        _dataSource2 = @[@10, @11, @12, @13, @14, @15, @16, @17, @18, @19, @20, @21, @22, @23, @24, @25, @26, @27, @28, @29, @30];
    }
    return _dataSource2;
}

@end
