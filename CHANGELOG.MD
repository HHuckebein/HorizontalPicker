#Change Log
All notable changes to this project will be documented in this file.
`HorizontalPicker` adheres to [Semantic Versioning](http://semver.org/).

--- 
## [2.1.](https://github.com/HHuckebein/HorizontalPicker/releases/tag/2.0.2) (07/28/2018) )
* update for swift 4.1

## [2.0.2](https://github.com/HHuckebein/HorizontalPicker/releases/tag/2.0.2) (05/04/2016) )
* podfile type corrected (kudos to [tripolev](https://github.com/tripolev))
* overcome a problem when index can't be derived (kudos to [tripolev](https://github.com/tripolev))'

## [2.0.1](https://github.com/HHuckebein/HorizontalPicker/releases/tag/2.0.1) (02/28/2016) )
* changed deployment target to 9.0
* added optiona protocol method to switch off masking

## [2.0.0](https://github.com/HHuckebein/HorizontalPicker/releases/tag/2.0.0) (12/17/2015) )
Released on Wednesday, December 17, 2015.

#### What has changed
* completely rewritten in Swift
* new optional delegate methods
  - 2 line mode - if text wont fit into the given 50% of the total space available using "useTwoLineModeForHorizontalPickerView"
  - set text font and color
  - uses tintColor set on the parent view to control selected text color
