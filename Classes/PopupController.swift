//
//  PopupController.swift
//  PopupController
//
//  Created by 佐藤 大輔 on 2/4/16.
//  Copyright © 2016 Daisuke Sato. All rights reserved.
//

import UIKit

typealias PopupAnimateCompletion =  () -> ()

// MARK: - Protocols
/** PopupContentViewController:
    Every ViewController which is added on the PopupController must need to be conformed this protocol.
 */
public protocol PopupContentViewController {
    
    /** sizeForPopup(popupController: size: showingKeyboard:):
        return view's size
     */
    func sizeForPopup(popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize
}

/** PopupControllerDelegate:
    This delegate perfoms when PopupController is showed and closed.
 */
@objc protocol PopupControllerDelegate {
    optional func popupControllerDidClose() -> Void
    optional func popupControllerDidShow() -> Void
}

public class PopupController: UIViewController {
    
    public enum PopupLayout {
        case Top, Center, Bottom
        
        func origin(view: UIView, size: CGSize = UIScreen.mainScreen().bounds.size) -> CGPoint {
            switch self {
            case .Top: return CGPointMake((size.width - view.frame.width) / 2, 0)
            case .Center: return CGPointMake((size.width - view.frame.width) / 2, (size.height - view.frame.height) / 2)
            case .Bottom: return CGPointMake((size.width - view.frame.width) / 2, size.height - view.frame.height)
            }
        }
    }
    
    public enum PopupAnimation {
        case FadeIn, SlideUp
    }
    
    public enum PopupBackgroundStyle {
        case BlackFilter(alpha: CGFloat)
        case Blur(style: UIBlurEffectStyle)
    }
    
    // MARK: - Public variables
    public var popupView: UIView!
    public var scrollable: Bool = true
    public var tappable: Bool = true
    public var layout: PopupLayout = .Center
    public var animation: PopupAnimation = .SlideUp
    public var movesAlongWithKeyboard: Bool = true
    public var backgroundStyle: PopupBackgroundStyle = .BlackFilter(alpha: 0.4)
    
    weak var delegate: PopupControllerDelegate?
    
    // MARK: - Private variables
    private let margin: CGFloat = 16
    private var baseScrollView = UIScrollView()
    private var isShowingKeyboard: Bool = false
    private var defaultContentOffset = CGPoint.zero
    
    private var maximumSize: CGSize {
        get {
            return CGSizeMake(
                UIScreen.mainScreen().bounds.size.width - margin * 2,
                UIScreen.mainScreen().bounds.size.height - margin * 2
            )
        }
    }
    
    deinit {
        self.removeFromParentViewController()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Overrides
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationObserve()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayouts()
    }
    
}

// MARK: - Public
public extension PopupController {
    
    // MARK: Classes
    public class func create(parentViewController: UIViewController) -> PopupController {
        let controller = PopupController()
        
        parentViewController.addChildViewController(controller)
        parentViewController.view.addSubview(controller.view)
        controller.didMoveToParentViewController(parentViewController)
        
        return controller
    }
    
    // MARK: Instances
    public func presentPopupController(viewController: UIViewController, completion: ((Void) -> Void)?) -> PopupController {
        self.addChildViewController(viewController)
        popupView = viewController.view
        configure()
        
        viewController.didMoveToParentViewController(self)
        
        self.show(layout, animation: animation) { () -> () in
            self.defaultContentOffset = self.baseScrollView.contentOffset
            self.delegate?.popupControllerDidShow?()
            completion?()
        }
        return self
    }
    
    public func dismissPopupController(completion: (() -> Void)? = nil) {
        if isShowingKeyboard {
            popupView.endEditing(true)
        }
        
        self.closePopup({ () -> Void in
            completion?()
        })
    }
    
    public func closePopup(completion: (() -> Void)?) {
        hide(animation) { () -> () in
            self.didClosePopup()
            completion?()
        }
    }
    
}

// MARK: Privates
private extension PopupController {
    
    func configure() {
        view.hidden = true
        view.frame = UIScreen.mainScreen().bounds
        
        if scrollable {
            baseScrollView.scrollEnabled = true
            baseScrollView.alwaysBounceHorizontal = false
            baseScrollView.alwaysBounceVertical = true
            baseScrollView.delegate = self
        }
        baseScrollView.frame = view.frame
        
        switch self.backgroundStyle {
        case .BlackFilter(let alpha):
            baseScrollView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(alpha)
        case .Blur(let style):
            let effectView = UIVisualEffectView(effect: UIBlurEffect(style: style))
            effectView.frame = view.frame
            view.addSubview(effectView)
        }
        
        view.addSubview(baseScrollView)
        
        popupView.layer.cornerRadius = 2
        popupView.layer.masksToBounds = true
        popupView.frame.origin.y = 0
        
        baseScrollView.addSubview(popupView)
    }
    
    func setupNotificationObserve() {
        NSNotificationCenter.defaultCenter()
            .addObserver(self,
                selector: "popupControllerWillShowKeyboard:",
                name: UIKeyboardWillShowNotification,
                object: nil
        )
        NSNotificationCenter.defaultCenter()
            .addObserver(self,
                selector: "popupControllerWillHideKeyboard:",
                name: UIKeyboardWillHideNotification,
                object: nil
        )
        NSNotificationCenter.defaultCenter()
            .addObserver(self,
                selector: "popupControllerDidHideKeyboard:",
                name: UIKeyboardDidHideNotification,
                object: nil
        )
    }
    
    func registerTapGesture() {
        guard tappable else { return }
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("didTapGesture:"))
        gestureRecognizer.delegate = self
        baseScrollView.addGestureRecognizer(gestureRecognizer)
    }
    
    func updateLayouts() {
        guard let child = self.childViewControllers.last as? PopupContentViewController else {
            return
        }
        popupView.frame.size = child.sizeForPopup(self, size: maximumSize, showingKeyboard: isShowingKeyboard)
        popupView.frame.origin.x = layout.origin(popupView).x
        baseScrollView.frame = view.frame
        baseScrollView.contentInset.top = layout.origin(popupView).y
        defaultContentOffset.y = -baseScrollView.contentInset.top
    }
    
    @objc func popupControllerWillShowKeyboard(notification: NSNotification) {
        isShowingKeyboard = true
        let obj = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        if needsToMoveFrom(obj.CGRectValue().origin) {
            move(obj.CGRectValue().origin)
        }
    }
    
    @objc func popupControllerWillHideKeyboard(notification: NSNotification) {
        back()
    }
    
    @objc func popupControllerDidHideKeyboard(notification: NSNotification) {
        self.isShowingKeyboard = false
    }
    
    // Tap Gesture
    @objc func didTapGesture(sender: UITapGestureRecognizer) {
        self.closePopup { () -> Void in
        }
    }
    
    func didClosePopup() {
        popupView.endEditing(true)
        popupView.removeFromSuperview()
        
        childViewControllers.forEach { $0.removeFromParentViewController() }
        
        view.hidden = true
        delegate?.popupControllerDidClose?()
        
        self.removeFromParentViewController()
    }
    
    func show(layout: PopupLayout, animation: PopupAnimation, completion: PopupAnimateCompletion) {
        guard let childViewController = childViewControllers.last as? PopupContentViewController else {
            return
        }
        
        popupView.frame.size = childViewController.sizeForPopup(self, size: maximumSize, showingKeyboard: isShowingKeyboard)
        popupView.frame.origin.x = layout.origin(popupView!).x
        
        self.registerTapGesture()
        switch animation {
        case .FadeIn:
            fadeIn(layout, completion: { () -> Void in
                completion()
            })
        case .SlideUp:
            slideUp(layout, completion: { () -> Void in
                completion()
            })
        }
    }
    
    func hide(animation: PopupAnimation, completion: PopupAnimateCompletion) {
        guard let child = childViewControllers.last as? PopupContentViewController else {
            return
        }
        
        popupView.frame.size = child.sizeForPopup(self, size: maximumSize, showingKeyboard: isShowingKeyboard)
        popupView.frame.origin.x = layout.origin(popupView).x
        
        switch animation {
        case .FadeIn:
            self.fadeOut({ () -> Void in
                self.clean()
                completion()
            })
        case .SlideUp:
            self.slideOut({ () -> Void in
                self.clean()
                completion()
            })
        }
        
    }
    
    func needsToMoveFrom(origin: CGPoint) -> Bool {
        guard movesAlongWithKeyboard else {
            return false
        }
        return (CGRectGetMaxY(popupView.frame) + layout.origin(popupView).y) > origin.y
    }
    
    func move(origin: CGPoint) {
        guard let child = childViewControllers.last as? PopupContentViewController else {
            return
        }
        popupView.frame.size = child.sizeForPopup(self, size: maximumSize, showingKeyboard: isShowingKeyboard)
        baseScrollView.contentInset.top = origin.y - popupView.frame.height
        baseScrollView.contentOffset.y = -baseScrollView.contentInset.top
        defaultContentOffset = baseScrollView.contentOffset
    }
    
    func back() {
        guard let child = childViewControllers.last as? PopupContentViewController else {
            return
        }
        popupView.frame.size = child.sizeForPopup(self, size: maximumSize, showingKeyboard: isShowingKeyboard)
        baseScrollView.contentInset.top = layout.origin(popupView).y
        defaultContentOffset.y = -baseScrollView.contentInset.top
    }
    
    func clean() {
        popupView.endEditing(true)
        popupView.removeFromSuperview()
        baseScrollView.removeFromSuperview()
    }
    
}

// MARK: Animations
private extension PopupController {
    
    func fadeIn(layout: PopupLayout, completion: () -> Void) {
        baseScrollView.contentInset.top = layout.origin(popupView).y
        
        view.hidden = false
        popupView.alpha = 0.0
        popupView.transform = CGAffineTransformMakeScale(0.9, 0.9)
        baseScrollView.alpha = 0.0
        
        UIView.animateWithDuration(0.3, delay: 0.1, options: .CurveEaseInOut, animations: { () -> Void in
            self.popupView.alpha = 1.0
            self.baseScrollView.alpha = 1.0
            self.popupView.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }) { (finished) -> Void in
                completion()
        }
    }
    
    func slideUp(layout: PopupLayout, completion: () -> Void) {
        view.hidden = false
        baseScrollView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.0)
        baseScrollView.contentInset.top = layout.origin(popupView).y
        baseScrollView.contentOffset.y = -UIScreen.mainScreen().bounds.height
        
        UIView.animateWithDuration(
            0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveLinear, animations: { () -> Void in
                self.baseScrollView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
                self.baseScrollView.contentOffset.y = -layout.origin(self.popupView).y
                self.defaultContentOffset = self.baseScrollView.contentOffset
            }, completion: { (isFinished) -> Void in
                completion()
        })
    }
    
    func fadeOut(completion: () -> Void) {
        
        UIView.animateWithDuration(
            0.3, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                self.popupView.alpha = 0.0
                self.baseScrollView.alpha = 0.0
                self.popupView.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }) { (finished) -> Void in
                completion()
        }
    }
    
    func slideOut(completion: () -> Void) {
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveLinear, animations: { () -> Void in
            self.popupView.frame.origin.y = UIScreen.mainScreen().bounds.height
            self.baseScrollView.alpha = 0.0
            }, completion: { (isFinished) -> Void in
                completion()
        })
    }
}

// MARK: UIScrollViewDelegate methods
extension PopupController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        let delta: CGFloat = defaultContentOffset.y - scrollView.contentOffset.y
        if delta > 20 && isShowingKeyboard {
            popupView.endEditing(true)
            return
        }
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let delta: CGFloat = defaultContentOffset.y - scrollView.contentOffset.y
        if delta > 50 {
            baseScrollView.contentInset.top = -scrollView.contentOffset.y
            animation = .SlideUp
            self.closePopup({ () -> Void in
            })
        }
    }
    
}

extension PopupController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return gestureRecognizer.view == touch.view
    }
}

extension UIViewController {
    func popupController() -> PopupController? {
        var parent = parentViewController
        while !(parent is PopupController || parent == nil) {
            parent = parent!.parentViewController
        }
        return parent as? PopupController
    }
}