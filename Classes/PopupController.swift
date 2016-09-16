//
//  PopupController.swift
//  PopupController
//
//  Created by 佐藤 大輔 on 2/4/16.
//  Copyright © 2016 Daisuke Sato. All rights reserved.
//

import UIKit

public enum PopupCustomOption {
    case layout(PopupController.PopupLayout)
    case animation(PopupController.PopupAnimation)
    case backgroundStyle(PopupController.PopupBackgroundStyle)
    case scrollable(Bool)
    case dismissWhenTaps(Bool)
    case movesAlongWithKeyboard(Bool)
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
    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize
}

open class PopupController: UIViewController {
    
    public enum PopupLayout {
        case top, center, bottom
        
        func origin(_ view: UIView, size: CGSize = UIScreen.main.bounds.size) -> CGPoint {
            switch self {
            case .top: return CGPoint(x: (size.width - view.frame.width) / 2, y: 0)
            case .center: return CGPoint(x: (size.width - view.frame.width) / 2, y: (size.height - view.frame.height) / 2)
            case .bottom: return CGPoint(x: (size.width - view.frame.width) / 2, y: size.height - view.frame.height)
            }
        }
    }
    
    public enum PopupAnimation {
        case fadeIn, slideUp
    }
    
    public enum PopupBackgroundStyle {
        case blackFilter(alpha: CGFloat)
    }
    
    // MARK: - Public variables
    open var popupView: UIView!
    
    // MARK: - Private variables
    fileprivate var movesAlongWithKeyboard: Bool = true
    fileprivate var scrollable: Bool = true {
        didSet {
            updateScrollable()
        }
    }
    fileprivate var dismissWhenTaps: Bool = true {
        didSet {
            if dismissWhenTaps {
                registerTapGesture()
            } else {
                unregisterTapGesture()
            }
        }
    }
    fileprivate var backgroundStyle: PopupBackgroundStyle = .blackFilter(alpha: 0.4) {
        didSet {
            updateBackgroundStyle(backgroundStyle)
        }
    }
    fileprivate var layout: PopupLayout = .center
    fileprivate var animation: PopupAnimation = .fadeIn
    
    fileprivate let margin: CGFloat = 16
    fileprivate let baseScrollView = UIScrollView()
    fileprivate var isShowingKeyboard: Bool = false
    fileprivate var defaultContentOffset = CGPoint.zero
    fileprivate var closedHandler: ((PopupController) -> Void)?
    fileprivate var showedHandler: ((PopupController) -> Void)?
    
    
    fileprivate var maximumSize: CGSize {
        get {
            return CGSize(
                width: UIScreen.main.bounds.size.width - margin * 2,
                height: UIScreen.main.bounds.size.height - margin * 2
            )
        }
    }
    
    deinit {
        self.removeFromParentViewController()
    }
    
    // MARK: Overrides
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerNotification()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unregisterNotification()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayouts()
    }
    
}

// MARK: - Publics
public extension PopupController {
    
    // MARK: Classes
    public class func create(_ parentViewController: UIViewController) -> PopupController {
        let controller = PopupController()
        controller.defaultConfigure()
        
        parentViewController.addChildViewController(controller)
        parentViewController.view.addSubview(controller.view)
        controller.didMove(toParentViewController: parentViewController)
        
        return controller
    }
    
    public func customize(_ options: [PopupCustomOption]) -> PopupController {
        customOptions(options)
        return self
    }
    
    public func show(_ childViewController: UIViewController) -> PopupController {
        self.addChildViewController(childViewController)
        popupView = childViewController.view
        configure()
        
        childViewController.didMove(toParentViewController: self)
        
        show(layout, animation: animation) { _ in
            self.defaultContentOffset = self.baseScrollView.contentOffset
            self.showedHandler?(self)
        }
        
        return self
    }
    
    public func didShowHandler(_ handler: @escaping (PopupController) -> Void) -> PopupController {
        self.showedHandler = handler
        return self
    }
    
    public func didCloseHandler(_ handler: @escaping (PopupController) -> Void) -> PopupController {
        self.closedHandler = handler
        return self
    }
    
    public func dismiss(_ completion: (() -> Void)? = nil) {
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
        backgroundStyle = .blackFilter(alpha: 0.4)
    }
    
    func configure() {
        view.isHidden = true
        view.frame = UIScreen.main.bounds
        
        baseScrollView.frame = view.frame
        view.addSubview(baseScrollView)
        
        popupView.layer.cornerRadius = 2
        popupView.layer.masksToBounds = true
        popupView.frame.origin.y = 0
        
        baseScrollView.addSubview(popupView)
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(PopupController.popupControllerWillShowKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PopupController.popupControllerWillHideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PopupController.popupControllerDidHideKeyboard(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    func unregisterNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func customOptions(_ options: [PopupCustomOption]) {
        for option in options {
            switch option {
            case .layout(let layout):
                self.layout = layout
            case .animation(let animation):
                self.animation = animation
            case .backgroundStyle(let style):
                self.backgroundStyle = style
            case .scrollable(let scrollable):
                self.scrollable = scrollable
            case .dismissWhenTaps(let dismiss):
                self.dismissWhenTaps = dismiss
            case .movesAlongWithKeyboard(let moves):
                self.movesAlongWithKeyboard = moves
            }
        }
    }
    
    func registerTapGesture() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PopupController.didTapGesture(_:)))
        
        gestureRecognizer.delegate = self
        baseScrollView.addGestureRecognizer(gestureRecognizer)
    }
    
    func unregisterTapGesture() {
        for recognizer in baseScrollView.gestureRecognizers ?? [] {
            baseScrollView.removeGestureRecognizer(recognizer)
        }
    }
    
    func updateLayouts() {
        guard let child = self.childViewControllers.last as? PopupContentViewController else { return }
        popupView.frame.size = child.sizeForPopup(self, size: maximumSize, showingKeyboard: isShowingKeyboard)
        popupView.frame.origin.x = layout.origin(popupView).x
        baseScrollView.frame = view.frame
        baseScrollView.contentInset.top = layout.origin(popupView).y
        defaultContentOffset.y = -baseScrollView.contentInset.top
    }
    
    func updateBackgroundStyle(_ style: PopupBackgroundStyle) {
        switch style {
        case .blackFilter(let alpha):
            baseScrollView.backgroundColor = UIColor.black.withAlphaComponent(alpha)
        }
    }
    
    func updateScrollable() {
        baseScrollView.isScrollEnabled = scrollable
        baseScrollView.alwaysBounceVertical = scrollable
        
        if scrollable {
            baseScrollView.delegate = self
        }
    }
    
    @objc func popupControllerWillShowKeyboard(_ notification: Notification) {
        isShowingKeyboard = true
        let obj = (notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        if needsToMoveFrom(obj.cgRectValue.origin) {
            move(obj.cgRectValue.origin)
        }
    }
    
    @objc func popupControllerWillHideKeyboard(_ notification: Notification) {
        back()
    }
    
    @objc func popupControllerDidHideKeyboard(_ notification: Notification) {
        self.isShowingKeyboard = false
    }
    
    // Tap Gesture
    @objc func didTapGesture(_ sender: UITapGestureRecognizer) {
        self.closePopup { _ in }
    }
    
    func closePopup(_ completion: (() -> Void)?) {
        hide(animation) { _ in
            completion?()
            self.didClosePopup()
        }
    }
    
    func didClosePopup() {
        popupView.endEditing(true)
        popupView.removeFromSuperview()
        
        childViewControllers.forEach { $0.removeFromParentViewController() }
        
        view.isHidden = true
        self.closedHandler?(self)
        
        self.removeFromParentViewController()
    }
    
    func show(_ layout: PopupLayout, animation: PopupAnimation, completion: @escaping PopupAnimateCompletion) {
        guard let childViewController = childViewControllers.last as? PopupContentViewController else {
            return
        }
        
        popupView.frame.size = childViewController.sizeForPopup(self, size: maximumSize, showingKeyboard: isShowingKeyboard)
        popupView.frame.origin.x = layout.origin(popupView!).x
        
        switch animation {
        case .fadeIn:
            fadeIn(layout, completion: { () -> Void in
                completion()
            })
        case .slideUp:
            slideUp(layout, completion: { () -> Void in
                completion()
            })
        }
    }
    
    func hide(_ animation: PopupAnimation, completion: @escaping PopupAnimateCompletion) {
        guard let child = childViewControllers.last as? PopupContentViewController else {
            return
        }
        
        popupView.frame.size = child.sizeForPopup(self, size: maximumSize, showingKeyboard: isShowingKeyboard)
        popupView.frame.origin.x = layout.origin(popupView).x
        
        switch animation {
        case .fadeIn:
            self.fadeOut({ () -> Void in
                self.clean()
                completion()
            })
        case .slideUp:
            self.slideOut({ () -> Void in
                self.clean()
                completion()
            })
        }
        
    }
    
    func needsToMoveFrom(_ origin: CGPoint) -> Bool {
        guard movesAlongWithKeyboard else {
            return false
        }
        return (popupView.frame.maxY + layout.origin(popupView).y) > origin.y
    }
    
    func move(_ origin: CGPoint) {
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
    
    func fadeIn(_ layout: PopupLayout, completion: @escaping () -> Void) {
        baseScrollView.contentInset.top = layout.origin(popupView).y
        
        view.isHidden = false
        popupView.alpha = 0.0
        popupView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        baseScrollView.alpha = 0.0
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.popupView.alpha = 1.0
            self.baseScrollView.alpha = 1.0
            self.popupView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }) { (finished) -> Void in
                completion()
        }
    }
    
    func slideUp(_ layout: PopupLayout, completion: @escaping () -> Void) {
        view.isHidden = false
        baseScrollView.backgroundColor = UIColor.clear
        baseScrollView.contentInset.top = layout.origin(popupView).y
        baseScrollView.contentOffset.y = -UIScreen.main.bounds.height
        
        UIView.animate(
            withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveLinear, animations: { () -> Void in
                
                self.updateBackgroundStyle(self.backgroundStyle)
                self.baseScrollView.contentOffset.y = -layout.origin(self.popupView).y
                self.defaultContentOffset = self.baseScrollView.contentOffset
            }, completion: { (isFinished) -> Void in
                completion()
        })
    }
    
    func fadeOut(_ completion: @escaping () -> Void) {
        
        UIView.animate(
            withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
                self.popupView.alpha = 0.0
                self.baseScrollView.alpha = 0.0
                self.popupView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }) { (finished) -> Void in
                completion()
        }
    }
    
    func slideOut(_ completion: @escaping () -> Void) {
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveLinear, animations: { () -> Void in
            self.popupView.frame.origin.y = UIScreen.main.bounds.height
            self.baseScrollView.alpha = 0.0
            }, completion: { (isFinished) -> Void in
                completion()
        })
    }
}

// MARK: UIScrollViewDelegate methods
extension PopupController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let delta: CGFloat = defaultContentOffset.y - scrollView.contentOffset.y
        if delta > 20 && isShowingKeyboard {
            popupView.endEditing(true)
            return
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let delta: CGFloat = defaultContentOffset.y - scrollView.contentOffset.y
        if delta > 50 {
            baseScrollView.contentInset.top = -scrollView.contentOffset.y
            animation = .slideUp
            self.closePopup { _ in }
        }
    }
    
}

extension PopupController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return gestureRecognizer.view == touch.view
    }
}

//extension UIViewController {
//    func popupController() -> PopupController? {
//        var parent = parent
//        while !(parent is PopupController || parent == nil) {
//            parent = parent!.parent
//        }
//        return parent as? PopupController
//    }
//}
