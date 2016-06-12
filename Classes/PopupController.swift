//
//  PopupController.swift
//  PopupController
//
//  Created by 佐藤 大輔 on 2/4/16.
//  Copyright © 2016 Daisuke Sato. All rights reserved.
//

import UIKit

public enum PopupCustomOption {
    case Layout(PopupController.PopupLayout)
    case Animation(PopupController.PopupAnimation)
    case BackgroundStyle(PopupController.PopupBackgroundStyle)
    case Scrollable(Bool)
    case DismissWhenTaps(Bool)
    case MovesAlongWithKeyboard(Bool)
}

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
    }
    
    // MARK: - Public variables
    public var popupView: UIView!
    
    // MARK: - Private variables
    private var movesAlongWithKeyboard: Bool = true
    private var scrollable: Bool = true {
        didSet {
            updateScrollable()
        }
    }
    private var dismissWhenTaps: Bool = true {
        didSet {
            if dismissWhenTaps {
                registerTapGesture()
            }
        }
    }
    private var backgroundStyle: PopupBackgroundStyle = .BlackFilter(alpha: 0.4) {
        didSet {
            updateBackgroundStyle(backgroundStyle)
        }
    }
    private var layout: PopupLayout = .Center
    private var animation: PopupAnimation = .FadeIn
    
    private let margin: CGFloat = 16
    private let baseScrollView = UIScrollView()
    private var isShowingKeyboard: Bool = false
    private var defaultContentOffset = CGPoint.zero
    private var closedHandler: ((PopupController) -> Void)?
    private var showedHandler: ((PopupController) -> Void)?
    
    
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
    }
    
    // MARK: Overrides
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        registerNotification()
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        unregisterNotification()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayouts()
    }
    
}

// MARK: - Publics
public extension PopupController {
    
    // MARK: Classes
    public class func create(parentViewController: UIViewController) -> PopupController {
        let controller = PopupController()
        controller.defaultConfigure()
        
        parentViewController.addChildViewController(controller)
        parentViewController.view.addSubview(controller.view)
        controller.didMoveToParentViewController(parentViewController)
        
        return controller
    }
    
    public func customize(options: [PopupCustomOption]) -> PopupController {
        customOptions(options)
        return self
    }
    
    public func show(childViewController: UIViewController) -> PopupController {
        self.addChildViewController(childViewController)
        popupView = childViewController.view
        configure()
        
        childViewController.didMoveToParentViewController(self)
        
        show(layout, animation: animation) { _ in
            self.defaultContentOffset = self.baseScrollView.contentOffset
            self.showedHandler?(self)
        }
        
        return self
    }
    
    public func didShowHandler(handler: (PopupController) -> Void) -> PopupController {
        self.showedHandler = handler
        return self
    }
    
    public func didCloseHandler(handler: (PopupController) -> Void) -> PopupController {
        self.closedHandler = handler
        return self
    }
    
    public func dismiss(completion: (() -> Void)? = nil) {
        if isShowingKeyboard {
            popupView.endEditing(true)
        }
        self.closePopup(completion)
    }
}

// MARK: Privates
private extension PopupController {
    
    func defaultConfigure() {
        scrollable = true
        dismissWhenTaps = true
        backgroundStyle = .BlackFilter(alpha: 0.4)
    }
    
    func configure() {
        view.hidden = true
        view.frame = UIScreen.mainScreen().bounds
        
        baseScrollView.frame = view.frame
        view.addSubview(baseScrollView)
        
        popupView.layer.cornerRadius = 2
        popupView.layer.masksToBounds = true
        popupView.frame.origin.y = 0
        
        baseScrollView.addSubview(popupView)
    }
    
    func registerNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PopupController.popupControllerWillShowKeyboard(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PopupController.popupControllerWillHideKeyboard(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PopupController.popupControllerDidHideKeyboard(_:)), name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func unregisterNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func customOptions(options: [PopupCustomOption]) {
        for option in options {
            switch option {
            case .Layout(let layout):
                self.layout = layout
            case .Animation(let animation):
                self.animation = animation
            case .BackgroundStyle(let style):
                self.backgroundStyle = style
            case .Scrollable(let scrollable):
                self.scrollable = scrollable
            case .DismissWhenTaps(let dismiss):
                self.dismissWhenTaps = dismiss
            case .MovesAlongWithKeyboard(let moves):
                self.movesAlongWithKeyboard = moves
            }
        }
    }
    
    func registerTapGesture() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PopupController.didTapGesture(_:)))
        gestureRecognizer.delegate = self
        baseScrollView.addGestureRecognizer(gestureRecognizer)
    }
    
    func updateLayouts() {
        guard let child = self.childViewControllers.last as? PopupContentViewController else { return }
        popupView.frame.size = child.sizeForPopup(self, size: maximumSize, showingKeyboard: isShowingKeyboard)
        popupView.frame.origin.x = layout.origin(popupView).x
        baseScrollView.frame = view.frame
        baseScrollView.contentInset.top = layout.origin(popupView).y
        defaultContentOffset.y = -baseScrollView.contentInset.top
    }
    
    func updateBackgroundStyle(style: PopupBackgroundStyle) {
        switch style {
        case .BlackFilter(let alpha):
            baseScrollView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(alpha)
        }
    }
    
    func updateScrollable() {
        if scrollable {
            baseScrollView.scrollEnabled = scrollable
            baseScrollView.alwaysBounceHorizontal = false
            baseScrollView.alwaysBounceVertical = true
            baseScrollView.delegate = self
        }
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
        self.closePopup { _ in }
    }
    
    func closePopup(completion: (() -> Void)?) {
        hide(animation) { _ in
            completion?()
            self.didClosePopup()
        }
    }
    
    func didClosePopup() {
        popupView.endEditing(true)
        popupView.removeFromSuperview()
        
        childViewControllers.forEach { $0.removeFromParentViewController() }
        
        view.hidden = true
        self.closedHandler?(self)
        
        self.removeFromParentViewController()
    }
    
    func show(layout: PopupLayout, animation: PopupAnimation, completion: PopupAnimateCompletion) {
        guard let childViewController = childViewControllers.last as? PopupContentViewController else {
            return
        }
        
        popupView.frame.size = childViewController.sizeForPopup(self, size: maximumSize, showingKeyboard: isShowingKeyboard)
        popupView.frame.origin.x = layout.origin(popupView!).x
        
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
        baseScrollView.backgroundColor = UIColor.clearColor()
        baseScrollView.contentInset.top = layout.origin(popupView).y
        baseScrollView.contentOffset.y = -UIScreen.mainScreen().bounds.height
        
        UIView.animateWithDuration(
            0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveLinear, animations: { () -> Void in
                
                self.updateBackgroundStyle(self.backgroundStyle)
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
            self.closePopup { _ in }
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