# HorizontalPicker

[![Build Status](https://travis-ci.org/HHuckebein/HorizontalPicker.svg?branch=master)](https://travis-ci.org/HHuckebein/HorizontalPicker)
[![Version](https://img.shields.io/cocoapods/v/HorizontalPicker.svg?style=flat)](http://cocoapods.org/pods/HorizontalPicker)
[![License](https://img.shields.io/cocoapods/l/HorizontalPicker.svg?style=flat)](http://cocoapods.org/pods/HorizontalPicker)
[![Platform](https://img.shields.io/cocoapods/p/HorizontalPicker.svg?style=flat)](http://cocoapods.org/pods/HorizontalPicker)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Usage

1. Just drop a normal UIView into your Storyboard and change the class to HorizontalPickerView. Make sure the module is set to HorizontalPicker.

2. import HorizontalPicker module

3. Add IBOutlets to the newly created view and set the dataSource and delegate attributes.

4. Make your class compatible with HorizontalPickerViewDataSource and HorizontalPickerViewDelegate protocol.

5. Implement the required methods and you are good to go.

## Installation

### Installation with CocoaPods

HorizontalPicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

pod 'HorizontalPicker', '~> 2.0'
```

### Installation with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate HorizontalPicker into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "HHuckebein/HorizontalPicker" ~> 2.0
```

Run `carthage` to build the framework and drag the built `HorizontalPicker.framework` into your Xcode project.


## Author

RABE_IT Services, development@berndrabe.de

## License

HorizontalPicker is available under the MIT license. See the LICENSE file for more info.
