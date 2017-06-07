## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Swift 3.1, iOS 9.0

## Installation

MediaWatermark is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MediaWatermark"
```

## Usage

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

## Author

Sergey Afanasiev, sergey.afanasiev@rubygarage.org

## License

MediaWatermark is available under the MIT license. See the LICENSE file for more info.
