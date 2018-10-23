# HEPhotoPicker
![image](https://github.com/heyode/HEPhotoPicker/blob/master/Assets/photopicker.gif)<br/>
[![CI Status](https://img.shields.io/travis/heyode/HEPhotoPicker.svg?style=flat)](https://travis-ci.org/heyode/HEPhotoPicker)
[![Version](https://img.shields.io/cocoapods/v/HEPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/HEPhotoPicker)
[![License](https://img.shields.io/cocoapods/l/HEPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/HEPhotoPicker)
[![Platform](https://img.shields.io/cocoapods/p/HEPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/HEPhotoPicker)

## Features
- 基于Swift4.2实现的iOS相册选择器
- 支持点击预览大图
- 支持多次累加选择
- 可设置选择图片的最大个数
## Requirements
- iOS 9.0
- Xcode 10
- Swift 4.2
## Installation

```ruby
pod 'HEPhotoPicker'
```
## Usage
### 导入HEPhotoPicker
```Swift
import HEPhotoPicker
```
### 弹出相册选择器
```Swift
let picker = HEPhotoPickerViewController(delegate: self)
hePresentPhotoPickerController(picker: picker)
```
### 设置选择图片的最大个数和多次累加选择
```Swift

let picker = HEPhotoPickerViewController(delegate: self)
  /// 自定义present方法
     ///
     /// - Parameters:
     ///   - picker: 图片选择器
     ///   - maxCount: 选择图片的最大个数（默认是9）
     ///   - defaultSelections: 已选择的模型（多次累加选择时用）
hePresentPhotoPickerController(picker: picker, maxCount: count,defaultSelections: selectedModel)
```
## Author

heyode, 1025335931@qq.com

## License

HEPhotoPicker is available under the MIT license. See the LICENSE file for more info.
