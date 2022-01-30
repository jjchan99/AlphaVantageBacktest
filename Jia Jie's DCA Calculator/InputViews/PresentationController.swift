import UIKit

//extension UIView {
//
//    var allSubviews: [UIView] {
//        subviews + subviews.flatMap { $0.allSubviews }
//    }
//
//    func firstSubview<T: UIView>(of type: T.Type) -> T? {
//        allSubviews.first { $0 is T } as? T
//    }
//
//    func findFirstResponder() -> UIView? {
//        for subview in subviews {
//            if subview.isFirstResponder {
//                return subview
//            }
//
//            if let recursiveSubView = subview.findFirstResponder() {
//                return recursiveSubView
//            }
//        }
//
//        return nil
//    }
//
//}
//
//extension UIApplication {
//
//    static var statusBarHeight: CGFloat {
//        Self.shared.statusBarFrame.height
//    }
//
//}
//
//extension UIViewController {
//
//    /// Return the preferred height of the view controller, taking scrollviews into account.
//    var preferredHeight: CGFloat {
//        /// If the view controller provides it's own preferred size, use it.
//        if preferredContentSize.height > 0 {
//            return preferredContentSize.height
//        }
//
//        return calculatePreferredHeight()
//    }
//
//    func calculatePreferredHeight() -> CGFloat {
//        // Insets are all zero intially, but once setup they will influence the results of the systemLayoutSizeFitting method.
//        let insets = view.safeAreaInsets.top + view.safeAreaInsets.bottom
//        // We substract the insets from the height to always get the actual height of only the view itself.
//        var height = max(0, view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height - insets)
//
//        // Support for UITableViewControllers.
//        if let tableView = view as? UITableView {
//            height += tableView.contentSize.height + tableView.contentInset.top + tableView.contentInset.bottom
//            return height
//        }
//
//        // Include scroll views in the height calculation.
//        height += view.subviews.filter { $0 is UIScrollView }.reduce(CGFloat(0), { result, view in
//            if view.intrinsicContentSize.height <= 0 {
//                // If a scroll view does not have an intrinsic content size set, use the content size.
//                let scrollView = view as! UIScrollView
//                return result + scrollView.contentSize.height + scrollView.contentInset.top + scrollView.contentInset.bottom
//            } else {
//                return result
//            }
//        })
//
//        return height
//    }
//
//    func requestHeightUpdate() {
//        // Set the preferredContentSize to force a preferredContentSizeDidChange call in the parent.
//        preferredContentSize.height += 1
//        preferredContentSize.height = 0
//    }
//
//
//    func presentAsSheet(_ vc: UIViewController, isDismissable: Bool) {
//        let presentationController = SheetModalPresentationController(presentedViewController: vc,
//                                                                      presenting: self,
//                                                                      isDismissable: isDismissable)
////        vc.transitioningDelegate = presentationController
//        vc.modalPresentationStyle = .custom
//        present(vc, animated: true)
//    }
//
//}

final class SheetModalPresentationController: UIPresentationController {
    
    // MARK: Private Properties
        
    private let isDismissable: Bool
    private let interactor = UIPercentDrivenInteractiveTransition()
    private let dimmingView = UIView()
    private var propertyAnimator: UIViewPropertyAnimator!
    private var isInteractive = false
    
//    private let topOffset = UIApplication.statusBarHeight + 20

    // MARK: Public Properties
    
    override var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(x: 0, y: Dimensions.height * 0.25, width: Dimensions.width, height: Dimensions.height * 0.75)
    }
        
    // MARK: Initializers
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?,
         isDismissable: Bool) {
        self.isDismissable = isDismissable
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
//        registerForKeyboardNotifications()
    }
    
    // MARK: Public Methods
    override func presentationTransitionWillBegin() {
        guard let containerBounds = containerView?.bounds, let presentedView = presentedView else { return }
                            
        // Configure the presented view.
//        containerView?.addSubview(presentedView)
//        presentedView.layoutIfNeeded()
        presentedView.frame = frameOfPresentedViewInContainerView
        presentedView.frame.origin.y = containerBounds.height
        presentedView.layer.masksToBounds = true
        presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedView.layer.cornerRadius = 20
        
        // Add a dimming view below the presented view controller.
        dimmingView.backgroundColor = .black
        dimmingView.frame = containerBounds
        dimmingView.alpha = 0
        containerView?.insertSubview(dimmingView, at: 0)
        
        // Add pan gesture recognizers for interactive dismissal.
        presentedView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
        
        
        // Add tap recognizer for sheet and keyboard dismissal.
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [unowned self] _ in
            self.dimmingView.alpha = 0.5
        })
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [unowned self] _ in
            self.dimmingView.alpha = 0
        })
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        // Not setting this to nil causes a retain cycle for some reason.
        propertyAnimator = nil
    }
    
//    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
//        super.preferredContentSizeDidChange(forChildContentContainer: container)
//
//        if propertyAnimator != nil && !propertyAnimator.isRunning {
//            presentedView?.frame = frameOfPresentedViewInContainerView
//            presentedView?.layoutIfNeeded()
//        }
//    }

    // MARK: Private Methods
        
    @objc
    private func handleDismiss() {
        presentedView?.endEditing(true)
        if isDismissable {
            presentedViewController.dismiss(animated: true)
        }
    }

    @objc
    private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard isDismissable, let containerView = containerView else { return }
        
        
        let percent = gesture.translation(in: containerView).y / containerView.bounds.height
    print("percent: \(percent)")
//        switch gesture.state {
//        case .began:
            if percent > 0.015 {
            if !presentedViewController.isBeingDismissed {
                isInteractive = true
                presentedViewController.dismiss(animated: true)
            }
            }
//        case .changed:
//            interactor.update(percent)
//        case .cancelled:
//            interactor.cancel()
//            isInteractive = false
//        case .ended:
//            let velocity = gesture.velocity(in: containerView).y
//            interactor.completionSpeed = 0.9
//            if percent > 0.3 || velocity > 1600 {
//                interactor.finish()
//            } else {
//                interactor.cancel()
//            }
//            isInteractive = false
//        default:
//            break
    }
    

    
    /// Handle the keyboard.
    
//    private func registerForKeyboardNotifications() {
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardToggled(notification:)),
//                                               name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardToggled(notification:)),
//                                               name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//
//    @objc
//    private func keyboardToggled(notification: NSNotification) {
//        guard let containerHeight = containerView?.bounds.height,
//            let presentedView = presentedView,
//            let textInput = presentedView.findFirstResponder(),
//            let textInputFrame = textInput.superview?.convert(textInput.frame, to: presentedView.superview)
//        else {
//            return assertionFailure()
//        }
//
//        // Adjust the presented view to move the active text input out of the keyboards's way (if needed).
//        if notification.name == UIResponder.keyboardWillShowNotification {
//            guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
//            else { return assertionFailure() }
//
//            let keyboardOverlap = textInputFrame.maxY - keyboardFrame.minY + 20
//            if keyboardOverlap > 0 {
//                presentedView.frame.origin.y = max(presentedView.frame.minY - keyboardOverlap, topOffset)
//            }
//        } else if notification.name == UIResponder.keyboardWillHideNotification {
//            presentedView.frame.origin.y = containerHeight - presentedView.frame.size.height
//        }
//    }

}

// MARK: UIViewControllerAnimatedTransitioning
//extension SheetModalPresentationController: UIViewControllerAnimatedTransitioning {
//
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        0.5
//    }
//
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        interruptibleAnimator(using: transitionContext).startAnimation()
//    }
//
//    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
//        propertyAnimator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext),
//                                                  timingParameters: UISpringTimingParameters(dampingRatio: 1.0,
//                                                                                            initialVelocity: CGVector(dx: 1, dy: 1)))
//        propertyAnimator.addAnimations { [unowned self] in
//            if self.presentedViewController.isBeingPresented {
//                transitionContext.view(forKey: .to)?.frame = self.frameOfPresentedViewInContainerView
//            } else {
//                transitionContext.view(forKey: .from)?.frame.origin.y = transitionContext.containerView.frame.maxY
//            }
//        }
//        propertyAnimator.addCompletion { _ in
//            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//        }
//        return propertyAnimator
//    }
//
//}
//
//// MARK: UIViewControllerTransitioningDelegate
//extension SheetModalPresentationController: UIViewControllerTransitioningDelegate {
//
//    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?,
//                                source: UIViewController) -> UIPresentationController? {
//        self
//    }
//
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController,
//                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        self
//    }
//
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        self
//    }
//
//    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        isInteractive ? interactor : nil
//    }
//
//}
