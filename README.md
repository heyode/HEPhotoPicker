# HEPhotoPicker

[![Version](https://img.shields.io/cocoapods/v/HEPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/HEPhotoPicker)
[![License](https://img.shields.io/cocoapods/l/HEPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/HEPhotoPicker)
[![Platform](https://img.shields.io/cocoapods/p/HEPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/HEPhotoPicker)<br/>
![image](https://github.com/heyode/HEPhotoPicker/blob/master/Assets/image%26video.gif)
## Features
- [x] 支持选择视频和图片（可自定义）
- [x] 支持预览大图
- [x] 支持累加选择
- [x] 可切换相册
- [x] 可设置视频和图片最大选择个数
- [x] 支持图片单选
- [x] 可定制为微博相册选择器

## Requirements
- iOS 9.0
- Xcode 10
- Swift 4.2
- 需要在使用项目的info.plist文件中加上用户授权相册的描述Privacy - Photo Library Usage Description

## Installation

```ruby
pod 'HEPhotoPicker'
```
## Usage
### 导入HEPhotoPicker
```Swift
import HEPhotoPicker
```
### 弹出相册选择器，使用默认配置
```Swift
// 创建选择器
let picker = HEPhotoPickerViewController.init(delegate: self)
// 弹出
hePresentPhotoPickerController(picker: picker)
```
### 类似微博的相册选择器
```Swift
// 配置项
let option = HEPhotoPickerOptions.init()
// 只能选择一个视频
option.singleVideo = true
// 图片和视频只能选择一种
option.mediaType = .imageOrVideo
// 将上次选择的数据传入，表示支持多次累加选择，
option.defaultSelections = self.selectedModel
// 选择图片的最大个数
option.maxCountOfImage = 9
// 创建选择器
let picker = HEPhotoPickerViewController.init(delegate: self, options: option)
// 弹出
hePresentPhotoPickerController(picker: picker)
```
![image](https://github.com/heyode/HEPhotoPicker/blob/master/Assets/weibo.gif)

### 多选图片
```Swift
// 配置项
let option = HEPhotoPickerOptions.init()
// 图片和视频只能选择一种
option.mediaType = .image
// 创建选择器
let picker = HEPhotoPickerViewController.init(delegate: self, options: option)
// 弹出
hePresentPhotoPickerController(picker: picker)
```
![image](https://github.com/heyode/HEPhotoPicker/blob/master/Assets/OnlyImage.gif)
### 单选图片
```Swift
// 配置项
let option = HEPhotoPickerOptions.init()
// 只能选择一个图片
option.singleImage = true
// 图片和视频只能选择一种
option.mediaType = .image
// 创建选择器
let picker = HEPhotoPickerViewController.init(delegate: self, options: option)
// 弹出
hePresentPhotoPickerController(picker: picker)
```
![image](https://github.com/heyode/HEPhotoPicker/blob/master/Assets/singlePicture.gif)
### 自定义配置对象HEPhotoPickerOptions支持的属性
```Swift
  /// 要挑选的数据类型
  public var mediaType : HEMediaType = .imageAndVideo
  /// 列表是否按创建时间升序排列
  public var ascendingOfCreationDateSort : Bool = false
  /// 挑选图片的最大个数
  public var maxCountOfImage = 9
  /// 挑选视频的最大个数
  public var maxCountOfVideo = 2
  /// 是否支持图片单选，默认是false，如果是ture只允许选择一张图片（如果 mediaType = imageAndVideo 或者 imageOrVideo 此属性无效）
  public var singlePicture = false
  /// 是否支持视频单选 默认是false，如果是ture只允许选择一个视频（如果 mediaType = imageAndVideo 此属性无效）
  public var singleVideo = false
  ///  实现多次累加选择时，需要传入的选中的模型。为空时表示不需要多次累加
  public var defaultSelections : [HEPhotoPickerListModel]?
```
## Author

heyode, heyode68@gmail.com

## License

HEPhotoPicker is available under the MIT license. See the LICENSE file for more info.
