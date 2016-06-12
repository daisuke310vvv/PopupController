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

	private var popupSize: CGSize // define the size for showing popup view size.

	// PopupContentViewController Protocol
    func sizeForPopup(popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
	    return popupSize
	}
}
```
  
Then, show popup  

```swift
PopupController
    .create(self)
    .show(AnyPopupViewController())
```  
  
With some custom.  
  
```swift
PopupController
    .create(self)
    .customize(
        [
            .Animation(.FadeIn), 
            .Layout(.Top), 
            .BackgroundStyle(.BlackFilter(alpha: 0.7))
        ]
    )
    .show(AnyPopupViewController())
```  

With Handler  

```swift
PopupController
    .create(self)
    .customize(
        [
            .Scrollable(false), 
            .DismissWhenTaps(true)
        ]
    )
    .didShowHandler { popup in
        // Do something
    }
    .didCloseHandler { _ in
        // Do something
    }
    .show(AnyPopupViewController())
```  

If you use PopupController instance, do like this below  

```swift
let popup = PopupController
    .create(self)
    .customize(
        [
            .Animation(.SlideUp)
        ]
    )
    .didShowHandler { popup in
        // Do something
    }
    .didCloseHandler { _ in
       // Do something
    }

popup.show() // show popup
popup.dismiss() // dismiss popup
```  
  
## Customization  
  
```swift
public enum PopupCustomOption {
    case Layout(PopupController.PopupLayout)
    case Animation(PopupController.PopupAnimation)
    case BackgroundStyle(PopupController.PopupBackgroundStyle)
    case Scrollable(Bool)
    case DismissWhenTaps(Bool)
    case MovesAlongWithKeyboard(Bool)
}
```

## License
PopupController is available under the MIT lincense. See the LINCENSE file for more info.
