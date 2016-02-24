# PopupController
[![CI Status](http://img.shields.io/travis/daisuke310vvv/PopupController.svg?style=flat)](https://travis-ci.org/daisuke310vvv/PopupController)
[![Version](https://img.shields.io/cocoapods/v/PopupController.svg?style=flat)](http://cocoapods.org/pods/PopupController)
[![License](https://img.shields.io/cocoapods/l/PopupController.svg?style=flat)](http://cocoapods.org/pods/PopupController)
[![Platform](https://img.shields.io/cocoapods/p/PopupController.svg?style=flat)](http://cocoapods.org/pods/PopupController)  
  
*PopupController* is a controller for showing temporary popup view.  
  
<p align="center">
<img src="https://github.com/daisuke310vvv/PopupController/blob/master/screenshots/ss01.jpg" width="250px" />
<img src="https://github.com/daisuke310vvv/PopupController/blob/master/screenshots/ss02.jpg" width="250px" />
<img src="https://github.com/daisuke310vvv/PopupController/blob/master/screenshots/ss03.jpg" width="250px" />
</p>
  
## Demo
Try *PopupController* on [Appetize.io](https://appetize.io/app/k498jv54rud8erd7dgnv83kgmr?device=iphone5s&scale=75&orientation=portrait&osVersion=9.2)  
  
<img src="https://github.com/daisuke310vvv/PopupController/blob/master/screenshots/ss.gif" width="250px" />

## Installation
### CocoaPods

```
pod 'PopupController'
```

### Carthage
Future

## Usage

Before use,  
Every ViewController which is added on the PopupController must conform to *PopupContentViewController* protocol.  

```swift
class AnyPopupViewController: UIViewController, PopupContentViewController {

	// Do something...

	priavte var popupSize: CGSize // define the size for showing popup view size.

	// PopupContentViewController Protocol
    func sizeForPopup(popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
	    return popupSize
	}
}
```
  
Then, show popup  

```swift
let anyPopupViewController = AnyPopupViewController()
let popupController = PopupController.create(self)
popupController.presentPoopupController(anyPopupViewController,  completion: nil)
```  
  
With some custom.  
  
```swift
let popupController = PopupController.create(self)
popupController.animation = .FadeIn
popupController.layout = .Top
popupController.backgroundStyle = .Blur(style: .Light)
popupController.presentPoopupController(childViewController,  completion: nil)
```  
  
## Customization  
  
```swift
public var layout: PopupLayout						// default is .Center,  [.Top/.Center/.Bottom]
public var animation: PopupAnimation				// default is .SlideUp,  [.Slideup/.FadeIn]
public var backgroundStyle: PopupBackgroundStyle	// default is .BlackFilter(alpha: 0.4) [BlackFilter(alpha: CGFloat)/Blur]
public var scrollable: Bool							// default is true
public var tappable: Bool							// default is true
public var movesAlongWithKeyboard: Bool				// default is true
```

## License
PopupController is available under the MIT lincense. See the LINCENSE file for more info.
