//
//  MenuButtonView.swift
//  MenuButton
//
//  Created by Andrii Starostenko on 30.05.2018.
//  Copyright © 2018 Zfort Group. All rights reserved.
//

import UIKit

/// An object that manages the content for a rectangular area on the screen.
public final class MenuButtonView: UIView {
    /// A main button, that interacts with user
    private var menuButton: MenuButton?
    /// Needs for show menu above all contents
    private var parentView: UIView?
    /// A view that represent menu
    private var menuOwnerView: MenuOwnerView?

    /// Calls when user touched background view.
    public var onDeselect: (() -> Void)?
    /// Calls when menu prepared to show. Equivalent of delegate method
    public var onItems: (() -> [MenuItem])?
    /// The color that will be used in all line
    public var strokeColor: UIColor = UIColor.black {
        didSet {
            configureButton()
        }
    }
    /// The color that will be used in border of this button
    public var borderStrokeColor: UIColor = UIColor.black {
        didSet {
            configureButton()
        }
    }
    /// The width of the button’s border.
    public var borderLineWidth: CGFloat = 1.0 {
        didSet {
            configureButton()
        }
    }
    /// The width of the lines
    public var lineWidth: CGFloat = 2.5 {
        didSet {
            configureButton()
        }
    }
    /// The distance between lines and border.
    public var offset: CGFloat = 3.3 {
        didSet {
            configureButton()
        }
    }
    /// The distance between lines.
    public var distanceBetweenLines: CGFloat = 8.0 {
        didSet {
            configureButton()
        }
    }
    /// Specifies the basic duration of the animation, in seconds.
    public var animationDuration: CFTimeInterval = 0.3 {
        didSet {
            configureButton()
        }
    }
    /// Specifies the basic text menu color
    public var textMenuColor: UIColor = UIColor.black
    /// Specifies the basic text menu font
    public var textMenuFont: UIFont = UIFont.systemFont(ofSize: 17.0)
    /// Specifies the basic text menu font size
    public var textmenuSize: CGFloat = 17.0
    /// Specifies the basic cell menu height
    public var menuCellHeight: CGFloat = 58.0

    /// Initializes and returns a newly allocated view object with the specified frame rectangle.
    ///
    /// - Parameter frame: The frame rectangle for the view, measured in points.
    ///                    The origin of the frame is relative to the superview in which you plan to add it.
    ///                    This method uses the frame rectangle to set the `center` and `bounds` properties accordingly.
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    /// Returns an object initialized from data in a given unarchiver.
    /// You typically return self from ]init(coder:)].
    /// If you have an advanced need that requires substituting a different object after decoding, you can do so in `awakeAfter(using:)`.
    ///
    /// - Parameter aDecoder: An unarchiver object.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
}

// MARK: - Private part of this view
public extension MenuButtonView {
    /// Allows to show menu view above parent view
    ///
    /// - Parameter view: A view where will be show menu. Uses view bounds.
    public func bindView(_ view: UIView) {
        parentView = view
    }
}

// MARK: - Private part of this view
// MARK: - Action part
private extension MenuButtonView {
    /// Shows customized menu above button
    private func showMenu() {
        let buttonSuperview = getSuperview(from: menuButton)
        let frame = convertFrameRelativeAncestor(buttonSuperview, convertible: menuButton, to: parentView)
        let parentViewBounds = safeParentViewBounds(parentView)
        let view: MenuOwnerView = MenuOwnerView.fromNib()

        view.onSelected = { [weak self] in self?.toggleMenu(isDeselected: false) }
        view.onDeselect = { [weak self] in self?.toggleMenu() }
        view.settings = MenuOwnerViewModelSettings(font: textMenuFont, color: textMenuColor, size: textmenuSize)

        view.layer.add(configureAnimationTransition(), forKey: kCATransitionReveal)

        parentView?.addSubview(view)
        parentView?.bringSubview(toFront: self)

        view.frame = parentViewBounds
        view.parentFrame = frame
        view.bottomIndent = parentViewBounds.height - frame.origin.y
        view.cellHeight = menuCellHeight
        view.dataSource = self.onItems?() ?? []

        menuOwnerView = view
    }

    /// Hides menu
    private func hideMenu() {
        onMainThread {
            self.animateSnapshotMenu()

            self.menuOwnerView?.removeFromSuperview()
            self.menuOwnerView = nil
        }
    }

    private func animateSnapshotMenu() {
        let snapshot = self.menuOwnerView!.snapshotView(afterScreenUpdates: false)!
        snapshot.frame = self.menuOwnerView!.frame
        self.menuOwnerView?.superview?.insertSubview(snapshot, aboveSubview: self.menuOwnerView!)

        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            snapshot.alpha = 0.0
        }, completion: { some in
            snapshot.removeFromSuperview()
        })
    }

    private func toggleMenu(isDeselected: Bool = true) {
        onMainThread {
            self.menuButton?.toggleButton()

            if isDeselected {
                self.onDeselect?()
            }
        }
    }
}

// MARK: - Configure part
private extension MenuButtonView {
    /// A main function, that configures this view
    private func configureView() {
        configureBackground()
        configureButton()
    }

    /// This function customizes background
    private func configureBackground() {
        backgroundColor = UIColor.clear
    }

    /// This function customizes a main button
    private func configureButton() {
        let button = MenuButton(frame: self.bounds)

        button.strokeColor = strokeColor
        button.borderStrokeColor = borderStrokeColor
        button.borderLineWidth = borderLineWidth
        button.lineWidth = lineWidth
        button.offset = offset
        button.distanceBetweenLines = distanceBetweenLines
        button.animationDuration = animationDuration
        button.onOpenedState = { [weak self] in self?.showMenu() }
        button.onClosedState = { [weak self] in self?.hideMenu() }

        menuButton?.removeFromSuperview()
        addSubview(button)
        menuButton = button
    }

    private func configureAnimationTransition() -> CATransition {
        let animation = CATransition.init()
        animation.duration = 0.3
        animation.type = kCATransitionReveal
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        return animation
    }
}
