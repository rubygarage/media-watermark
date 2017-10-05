## About

MediaWatemark is an open source GPU/CPU-based iOS watermark library for overlays adding to images or video content. It has simple interface and straightforward functionality.

## Overview
__Simple & Universal__

MediaWatemark is easy to install and integrate into any iOS project. It processes the wide variety of tasks and goes perfectly for overlaying views and texts over the videos or other images.  

__Light Code__

MediaWatemark consists of light code and makes it easy to overlay one image over another, or do the same with the video content.

__Easy Installation__

Before using the library in your work, you may run the example project, I'm sharing below. When you are ready to use it, just follow the short and easy Installation tip below.


## Installation

MediaWatermark is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MediaWatermark"
```
## Requirements

iOS: 9.0+  
Swift: 4.0  
CocoaPods: for iOS  
Processing Concept: GPU & CPU

## Example
To run the example project, clone the repo, and run pod install from the Example directory first.

## Usage
__Adding several images over the other image__

To add two images with different coordinates over the third image, you may use code like the following. The images are placed according to the coordinates you set in the code.

```swift
if let item = MediaItem(url: url) {
    let logoImage = UIImage(named: "rglogo")
            
    let firstElement = MediaElement(image: logoImage!)
    firstElement.frame = CGRect(x: 0, y: 0, width: logoImage!.size.width, height: logoImage!.size.height)
            
    let secondElement = MediaElement(image: logoImage!)
    secondElement.frame = CGRect(x: 150, y: 150, width: logoImage!.size.width, height: logoImage!.size.height)
                        
    item.add(elements: [firstElement, secondElement])
            
    let mediaProcessor = MediaProcessor()
    mediaProcessor.processElements(item: item) { [weak self] (result, error) in
    	// handle result            
    }
}
```

__Adding an image and text over the image__

The next script template will work in case if you need to render an image and text over the other image:

```swift
let item = MediaItem(image: image)
        
let logoImage = UIImage(named: "logo")
        
let firstElement = MediaElement(image: logoImage!)
firstElement.frame = CGRect(x: 0, y: 0, width: logoImage!.size.width, height: logoImage!.size.height)
                
let testStr = "Test Attributed String"
let attributes = [ NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 35) ]
let attrStr = NSAttributedString(string: testStr, attributes: attributes)
        
let secondElement = MediaElement(text: attrStr)
secondElement.frame = CGRect(x: 300, y: 300, width: logoImage!.size.width, height: logoImage!.size.height)
        
item.add(elements: [firstElement, secondElement])
        
let mediaProcessor = MediaProcessor()
mediaProcessor.processElements(item: item) { [weak self] (result, error) in
    self?.resultImageView.image = result.image
}
```

__Adding an image and text over the video__

To add an image and text over the video you may refer the following code extract:

```swift
if let item = MediaItem(url: url) {
	let logoImage = UIImage(named: "logo")
            
	let firstElement = MediaElement(image: logoImage!)
	firstElement.frame = CGRect(x: 0, y: 0, width: logoImage!.size.width, height: logoImage!.size.height)
            
	let testStr = "Attributed Text"
	let attributes = [ NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 35) ]
	let attrStr = NSAttributedString(string: testStr, attributes: attributes)
            
	let secondElement = MediaElement(text: attrStr)
	secondElement.frame = CGRect(x: 300, y: 300, width: logoImage!.size.width, height: logoImage!.size.height)
            
    item.add(elements: [firstElement, secondElement])
            
    let mediaProcessor = MediaProcessor()
    mediaProcessor.processElements(item: item) { [weak self] (result, error) in
        self?.videoPlayer.url = result.processedUrl
        self?.videoPlayer.playFromBeginning()
    }
}
```

## Author

Sergey Afanasiev

## Getting Help

sergey.afanasiev@rubygarage.org

## License

MediaWatermark is available under the MIT license. See the LICENSE file for more info.
