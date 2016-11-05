//
//  HFCardCollectionViewLayout.swift
//  HFCardCollectionViewLayout
//
//  Created by Hendrik Frahmann on 02.11.16.
//  Copyright © 2016 Hendrik Frahmann. All rights reserved.
//

import UIKit

/// Extended delegate functions to control the card selection.
@objc public protocol HFCardCollectionViewLayoutDelegate : UICollectionViewDelegate {
    
    /// Asks if the card at the specific index can be selected.
    /// - Parameter collectionViewLayout: The current HFCardCollectionViewLayout.
    /// - Parameter canSelectCardAtIndex: Index of the card.
    @objc optional func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, canSelectCardAtIndex index: Int) -> Bool
    
    /// Asks if the card at the specific index can be unselected.
    /// - Parameter collectionViewLayout: The current HFCardCollectionViewLayout.
    /// - Parameter canUnselectCardAtIndex: Index of the card.
    @objc optional func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, canUnselectCardAtIndex index: Int) -> Bool
    
    /// Feedback when the card at the given index will be selected.
    /// - Parameter collectionViewLayout: The current HFCardCollectionViewLayout.
    /// - Parameter didSelectedCardAtIndex: Index of the card.
    @objc optional func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, willSelectCardAtIndex index: Int)
    
    /// Feedback when the card at the given index was selected.
    /// - Parameter collectionViewLayout: The current HFCardCollectionViewLayout.
    /// - Parameter didSelectedCardAtIndex: Index of the card.
    @objc optional func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, didSelectCardAtIndex index: Int)
    
    /// Feedback when the card at the given index will be unselected.
    /// - Parameter collectionViewLayout: The current HFCardCollectionViewLayout.
    /// - Parameter didUnselectedCardAtIndex: Index of the card.
    @objc optional func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, willUnselectCardAtIndex index: Int)
    
    /// Feedback when the card at the given index was unselected.
    /// - Parameter collectionViewLayout: The current HFCardCollectionViewLayout.
    /// - Parameter didUnselectedCardAtIndex: Index of the card.
    @objc optional func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, didUnselectCardAtIndex index: Int)
    
}

/// The HFCardCollectionViewLayout provides a card stack layout not quite similar like the apps Reminder and Wallet.
open class HFCardCollectionViewLayout: UICollectionViewLayout, UIGestureRecognizerDelegate {
    
    // MARK: Public Variables
    
    /// Only cards with index equal or greater than firstMovableIndex can be moved through the collectionView.
    ///
    /// Default: 0
    @IBInspectable var firstMovableIndex: Int = 0
    
    /// Specifies the height that is showing the cardhead when the collectionView is showing all cards.
    ///
    /// The minimum value is 20.
    ///
    /// Default: 80
    @IBInspectable var cardHeadHeight: CGFloat = 80 {
        didSet {
            if(cardHeadHeight < 20) {
                cardHeadHeight = 20
                return
            }
            self.collectionView?.performBatchUpdates({ self.invalidateLayout() }, completion: nil)
        }
    }
    
    /// When th collectionView is showing all cards but there are not enough cards to fill the full height,
    /// the cardHeadHeight will be expanded to equally fill the height.
    ///
    /// Default: true
    @IBInspectable var cardShouldExpandHeadHeight: Bool = true {
        didSet {
            self.collectionView?.performBatchUpdates({ self.invalidateLayout() }, completion: nil)
        }
    }
    
    /// Stretch the cards when scrolling up
    ///
    /// Default: true
    @IBInspectable var cardShouldStretchAtScrollTop: Bool = true {
        didSet {
            self.collectionView?.performBatchUpdates({ self.invalidateLayout() }, completion: nil)
        }
    }
    
    /// Specifies the maximum height of the cards.
    ///
    /// But the height can be less if the frame size of collectionView is smaller.
    ///
    /// Default: 0 (no height specified)
    @IBInspectable var cardMaximumHeight: CGFloat = 0 {
        didSet {
            if(cardMaximumHeight < 0) {
                cardMaximumHeight = 0
                return
            }
            self.collectionView?.performBatchUpdates({ self.invalidateLayout() }, completion: nil)
        }
    }
    
    /// Count of bottom stacked cards when a card is selected.
    ///
    /// Value must be between 0 and 10
    ///
    /// Default: 5
    @IBInspectable var bottomNumberOfStackedCards: Int = 5 {
        didSet {
            if(bottomNumberOfStackedCards < 0) {
                bottomNumberOfStackedCards = 0
                return
            }
            if(bottomNumberOfStackedCards > 10) {
                bottomNumberOfStackedCards = 10
                return
            }
            self.collectionView?.performBatchUpdates({ self.collectionView?.reloadData() }, completion: nil)
        }
    }
    
    /// All bottom stacked cards are scaled to produce the 3D effect.
    ///
    /// Default: true
    @IBInspectable var bottomStackedCardsShouldScale: Bool = true {
        didSet {
            self.collectionView?.performBatchUpdates({ self.invalidateLayout() }, completion: nil)
        }
    }
    
    /// Specifies the margin for the top margin of a bottom stacked card.
    ///
    /// Value can be between 0 and 20
    ///
    /// Default: 10
    @IBInspectable var bottomCardLookoutMargin: CGFloat = 10 {
        didSet {
            if(bottomCardLookoutMargin < 0) {
                bottomCardLookoutMargin = 0
                return
            }
            if(bottomCardLookoutMargin > 20) {
                bottomCardLookoutMargin = 20
                return
            }
            self.collectionView?.performBatchUpdates({ self.invalidateLayout() }, completion: nil)
        }
    }
    
    /// An additional topspace to show the top of the collectionViews backgroundView.
    ///
    /// Default: 0
    @IBInspectable var spaceAtTopForBackgroundView: CGFloat = 0 {
        didSet {
            if(spaceAtTopForBackgroundView < 0) {
                spaceAtTopForBackgroundView = 0
                return
            }
            self.collectionView?.performBatchUpdates({ self.invalidateLayout() }, completion: nil)
        }
    }
    
    /// Snaps the scrollView if the contentOffset is on the 'spaceAtTopForBackgroundView'
    ///
    /// Default: true
    @IBInspectable var spaceAtTopShouldSnap: Bool = true
    
    /// Additional space at the bottom to expand the contentsize of the collectionView.
    ///
    /// Default: 0
    @IBInspectable var spaceAtBottom: CGFloat = 0 {
        didSet {
            self.collectionView?.performBatchUpdates({ self.invalidateLayout() }, completion: nil)
        }
    }
    
    /// Area the top where to autoscroll while moving a card.
    ///
    /// Default 120
    @IBInspectable var scrollAreaTop: CGFloat = 120 {
        didSet {
            if(scrollAreaTop < 0) {
                scrollAreaTop = 0
                return
            }
        }
    }
    
    /// Area ot the bottom where to autoscroll while moving a card.
    ///
    /// Default 120
    @IBInspectable var scrollAreaBottom: CGFloat = 120 {
        didSet {
            if(scrollAreaBottom < 0) {
                scrollAreaBottom = 0
                return
            }
        }
    }
    
    /// The scrollView should snap the cardhead to the top.
    ///
    /// Default: false
    @IBInspectable var scrollShouldSnapCardHead: Bool = false
    
    /// Contains the selected index.
    /// ReadOnly.
    private(set) var selectedIndex: Int = -1
    
    // MARK: Public Actions
    
    /// Action for the InterfaceBuilder to flip back the selected card.
    @IBAction func flipBackSelectedCardAction() {
        self.flipSelectedCardBack()
    }
    
    /// Action for the InterfaceBuilder to unselect the selected card.
    @IBAction func unselectSelectedCardAction() {
        self.unselectCard()
    }
    
    // MARK: Public Functions
    
    /// Select a card at the given index.
    ///
    /// - Parameter index: The index of the card.
    /// - Parameter completion: An optional completion block. Will be executed the animation is finished.
    public func selectCardAt(index: Int, completion: (() -> Void)? = nil) {
        let collectionViewLayoutDelegate = self.collectionView?.delegate as? HFCardCollectionViewLayoutDelegate
        let oldSelectedIndex = self.selectedIndex
        
        if ((self.selectedIndex >= 0 && self.selectedIndex == index) || (self.selectedIndex >= 0 && index < 0)) && self.selectedCardIsFlipped == true {
            // do nothing, because the card is flipped
        } else if self.selectedIndex >= 0 && index >= 0 {
            if(self.collectionViewForceUnselect == false) {
                if(collectionViewLayoutDelegate?.cardCollectionViewLayout?(self, canUnselectCardAtIndex: self.selectedIndex) == false) {
                    return
                }
            }
            self.collectionViewForceUnselect = false
            if(self.selectedCardIsFlipped == true) {
                self.flipSelectedCardBack(completion: {
                    self.collectionView?.isScrollEnabled = true
                    self.deinitializeSelectedCard()
                    collectionViewLayoutDelegate?.cardCollectionViewLayout?(self, willUnselectCardAtIndex: self.selectedIndex)
                    self.selectedIndex = -1
                    self.collectionView?.performBatchUpdates({ self.collectionView?.reloadData() }, completion: { (finished) in
                        collectionViewLayoutDelegate?.cardCollectionViewLayout?(self, didUnselectCardAtIndex: oldSelectedIndex)
                        completion?()
                    })
                })
            } else {
                self.collectionView?.isScrollEnabled = true
                self.deinitializeSelectedCard()
                collectionViewLayoutDelegate?.cardCollectionViewLayout?(self, willUnselectCardAtIndex: self.selectedIndex)
                self.selectedIndex = -1
                self.collectionView?.performBatchUpdates({ self.collectionView?.reloadData() }, completion: { (finished) in
                    collectionViewLayoutDelegate?.cardCollectionViewLayout?(self, didUnselectCardAtIndex: oldSelectedIndex)
                    completion?()
                })
            }
        } else {
            if(index < 0 && self.selectedIndex >= 0) {
                self.deinitializeSelectedCard()
                collectionViewLayoutDelegate?.cardCollectionViewLayout?(self, willUnselectCardAtIndex: self.selectedIndex)
            }
            if index >= 0 {
                self.selectedIndex = index
                if(collectionViewLayoutDelegate?.cardCollectionViewLayout?(self, canSelectCardAtIndex: index) == false) {
                    self.selectedIndex = -1
                    return
                }
                collectionViewLayoutDelegate?.cardCollectionViewLayout?(self, willSelectCardAtIndex: index)
                _ = self.initializeSelectedCard()
                self.collectionView?.isScrollEnabled = false
                
                self.collectionView?.performBatchUpdates({ self.collectionView?.reloadData() }, completion: { (finished) in
                    collectionViewLayoutDelegate?.cardCollectionViewLayout?(self, didSelectCardAtIndex: self.selectedIndex)
                    completion?()
                })
            } else if(self.selectedIndex >= 0) {
                self.selectedIndex = index
                self.collectionView?.isScrollEnabled = true
                self.collectionView?.performBatchUpdates({ self.collectionView?.reloadData() }, completion: { (finished) in
                    collectionViewLayoutDelegate?.cardCollectionViewLayout?(self, didUnselectCardAtIndex: oldSelectedIndex)
                    completion?()
                })
            }
            self.selectedIndex = index
        }
    }
    
    /// Unselect the selected card
    ///
    /// - Parameter completion: An optional completion block. Will be executed the animation is finished.
    public func unselectCard(completion: (() -> Void)? = nil) {
        if(self.selectedIndex == -1) {
            completion?()
        } else if(self.selectedCardIsFlipped == true) {
            self.flipSelectedCardBack(completion: {
                self.collectionViewForceUnselect = true
                self.selectCardAt(index: self.selectedIndex, completion: completion)
            })
        } else {
            self.collectionViewForceUnselect = true
            self.selectCardAt(index: self.selectedIndex, completion: completion)
        }
    }
    
    /// Flips the selected card to the given view.
    /// The frame for the view will be the same as the cell
    ///
    /// - Parameter toView: The view for the backview of te card.
    /// - Parameter completion: An optional completion block. Will be executed the animation is finished.
    public func flipSelectedCard(toView: UIView, completion: (() -> Void)? = nil) {
        if(self.selectedCardIsFlipped == true) {
            return
        }
        if let cardCell = self.selectedCardCell, self.selectedIndex >= 0 {
            toView.removeFromSuperview()
            self.selectedCardFlipView = toView
            toView.frame = CGRect(x: 0, y: 0, width: cardCell.frame.width, height: cardCell.frame.height)
            toView.isHidden = true
            cardCell.addSubview(toView)
            
            self.selectedCardIsFlipped = true
            UIApplication.shared.keyWindow?.endEditing(true)
            let originalShouldRasterize = cardCell.layer.shouldRasterize
            cardCell.layer.shouldRasterize = false
            
            UIView.transition(with: cardCell, duration: 0.5, options:[.transitionFlipFromRight], animations: { () -> Void in
                cardCell.contentView.isHidden = true
                toView.isHidden = false
            }, completion: { (Bool) -> Void in
                cardCell.layer.shouldRasterize = originalShouldRasterize
                completion?()
            })
        }
    }
    
    /// Flips the flipped card back to the frontview.
    ///
    /// - Parameter completion: An optional completion block. Will be executed the animation is finished.
    public func flipSelectedCardBack(completion: (() -> Void)? = nil) {
        if(self.selectedCardIsFlipped == false) {
            return
        }
        if let cardCell = self.selectedCardCell {
            if let flipView = self.selectedCardFlipView {
                let originalShouldRasterize = cardCell.layer.shouldRasterize
                UIApplication.shared.keyWindow?.endEditing(true)
                cardCell.layer.shouldRasterize = false
                
                UIView.transition(with: cardCell, duration: 0.5, options:[.transitionFlipFromLeft], animations: { () -> Void in
                    flipView.isHidden = true
                    cardCell.contentView.isHidden = false
                }, completion: { (Bool) -> Void in
                    flipView.removeFromSuperview()
                    cardCell.layer.shouldRasterize = originalShouldRasterize
                    self.selectedCardFlipView = nil
                    self.selectedCardIsFlipped = false
                    completion?()
                })
            }
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////                                  Private                                       //////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // MARK: Private Variables
    
    private var collectionViewIsInitialized = false
    private var collectionViewItemCount: Int = 0
    private var collectionViewTapGestureRecognizer: UITapGestureRecognizer?
    private var collectionViewIgnoreBottomContentOffsetChanges: Bool = false
    private var collectionViewLastBottomContentOffset: CGFloat = 0
    private var collectionViewForceUnselect: Bool = false
    
    private var cardCollectionBoundsSize: CGSize = .zero
    private var cardCollectionViewLayoutAttributes:[HFCardCollectionViewLayoutAttributes]!
    private var cardCollectionBottomCardsSet: [Int] = []
    private var cardCollectionBottomCardsSelectedIndex: CGFloat = 0
    private var cardCollectionCellSize: CGSize = .zero
    
    private var selectedCardCell: UICollectionViewCell?
    private var selectedCardPanGestureRecognizer: UIPanGestureRecognizer?
    private var selectedCardPanGestureTouchLocationY: CGFloat = 0
    private var selectedCardFlipView: UIView?
    private var selectedCardIsFlipped: Bool = false
    
    private var movingCardSelectedIndex: Int = -1
    private var movingCardGestureRecognizer: UILongPressGestureRecognizer?
    private var movingCardActive: Bool = false
    private var movingCardGestureStartLocation: CGPoint = .zero
    private var movingCardGestureCurrentLocation: CGPoint = .zero
    private var movingCardCenterStart: CGPoint = .zero
    private var movingCardSnapshotCell: UIView?
    private var movingCardLastTouchedLocation: CGPoint = .zero
    private var movingCardLastTouchedIndexPath: IndexPath?
    private var movingCardStartIndexPath: IndexPath?
    
    private var autoscrollDisplayLink: CADisplayLink?
    private var autoscrollDirection: HFCardCollectionScrollDirection = .unknown
    
    // MARK: Private calculated Variable
    
    private var contentInset: UIEdgeInsets {
        get {
            return self.collectionView!.contentInset
        }
    }
    
    private var contentOffsetTop: CGFloat {
        get {
            return self.collectionView!.contentOffset.y + self.contentInset.top
        }
    }
    
    private var bottomCardCount: CGFloat {
        return CGFloat(min(self.collectionViewItemCount, min(self.bottomNumberOfStackedCards, self.cardCollectionBottomCardsSet.count)))
    }
    
    private var bottomContentInset: CGFloat {
        if(self.collectionViewIgnoreBottomContentOffsetChanges == true) {
            return self.collectionViewLastBottomContentOffset
        }
        self.collectionViewLastBottomContentOffset = self.contentInset.bottom
        return self.contentInset.bottom
    }
    
    // MARK: Initialize HFCardCollectionViewLayout
    
    internal func installMoveCardsGestureRecognizer() {
        self.movingCardGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.movingCardGestureHandler))
        self.movingCardGestureRecognizer?.minimumPressDuration = 0.49
        self.movingCardGestureRecognizer?.delegate = self
        self.collectionView?.addGestureRecognizer(self.movingCardGestureRecognizer!)
    }
    
    private func initializeCardCollectionViewLayout() {
        self.collectionViewIsInitialized = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        self.collectionViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.collectionViewTapGestureHandler))
        self.collectionViewTapGestureRecognizer?.delegate = self
        self.collectionView?.addGestureRecognizer(self.collectionViewTapGestureRecognizer!)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        self.collectionViewIgnoreBottomContentOffsetChanges = true
    }
    
    func keyboardDidHide(_ notification: Notification) {
        self.collectionViewIgnoreBottomContentOffsetChanges = false
    }
    
    // MARK: UICollectionViewLayout Overrides
    
    override open var collectionViewContentSize: CGSize {
        get {
            let contentHeight = (self.cardHeadHeight * CGFloat(self.collectionViewItemCount)) + self.spaceAtTopForBackgroundView + self.spaceAtBottom
            let contentWidth = self.collectionView!.frame.width - (contentInset.left + contentInset.right)
            return CGSize.init(width: contentWidth, height: contentHeight)
        }
    }
    
    override open func prepare() {
        super.prepare()
        
        self.collectionViewItemCount = self.collectionView!.numberOfItems(inSection: 0)
        self.cardCollectionCellSize = self.generateCellSize()
        
        if(self.collectionViewIsInitialized == false) {
            self.initializeCardCollectionViewLayout()
        }
        
        self.cardCollectionViewLayoutAttributes = self.generateCardCollectionViewLayoutAttributes()
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.cardCollectionViewLayoutAttributes[indexPath.item]
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes =  self.cardCollectionViewLayoutAttributes.filter { (layout) -> Bool in
            return (layout.frame.intersects(rect))
        }
        return attributes
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let proposedContentOffsetY = proposedContentOffset.y + self.collectionView!.contentInset.top
        if(self.spaceAtTopShouldSnap == true && self.spaceAtTopForBackgroundView > 0) {
            if(proposedContentOffsetY > 0 && proposedContentOffsetY < self.spaceAtTopForBackgroundView) {
                let scrollToTopY = self.spaceAtTopForBackgroundView * 0.5
                if(proposedContentOffsetY < scrollToTopY) {
                    return CGPoint(x: 0, y: 0 - self.contentInset.top)
                } else {
                    return CGPoint(x: 0, y: self.spaceAtTopForBackgroundView - self.contentInset.top)
                }
            }
        }
        if(self.scrollShouldSnapCardHead == true && proposedContentOffsetY > self.spaceAtTopForBackgroundView && self.collectionView!.contentSize.height > self.collectionView!.frame.height + self.cardHeadHeight) {
            let startIndex = Int((proposedContentOffsetY - self.spaceAtTopForBackgroundView) / self.cardHeadHeight) + 1
            let positionToGoUp = self.cardHeadHeight * 0.5
            let cardHeadPosition = (proposedContentOffsetY - self.spaceAtTopForBackgroundView).truncatingRemainder(dividingBy: self.cardHeadHeight)
            if(cardHeadPosition > positionToGoUp) {
                let targetY = (CGFloat(startIndex) * self.cardHeadHeight) + (self.spaceAtTopForBackgroundView - self.contentInset.top)
                return CGPoint(x: 0, y: targetY)
            } else {
                let targetY = (CGFloat(startIndex) * self.cardHeadHeight) - self.cardHeadHeight + (self.spaceAtTopForBackgroundView - self.contentInset.top)
                return CGPoint(x: 0, y: targetY)
            }
        }
        return proposedContentOffset
    }
    
    // MARK: Private Functions for UICollectionViewLayout
    
    internal func collectionViewTapGestureHandler() {
        if let tapLocation = self.collectionViewTapGestureRecognizer?.location(in: self.collectionView) {
            if let indexPath = self.collectionView?.indexPathForItem(at: tapLocation) {
                self.collectionView?.delegate?.collectionView?(self.collectionView!, didSelectItemAt: indexPath)
            }
        }
    }
    
    private func generateCellSize() -> CGSize {
        let width = self.collectionView!.frame.width - (self.contentInset.left + self.contentInset.right)
        let maxHeight = self.collectionView!.frame.height - (self.bottomCardLookoutMargin * CGFloat(self.bottomNumberOfStackedCards)) - (self.contentInset.top + self.bottomContentInset) - 2
        let height = (self.cardMaximumHeight == 0 || self.cardMaximumHeight > maxHeight) ? maxHeight : self.cardMaximumHeight
        let size = CGSize.init(width: width, height: height)
        return size
    }
    
    private func generateCardCollectionViewLayoutAttributes() -> [HFCardCollectionViewLayoutAttributes] {
        var cardCollectionViewLayoutAttributes: [HFCardCollectionViewLayoutAttributes] = []
        var shouldReloadAllItems = false
        if(self.cardCollectionViewLayoutAttributes != nil && self.collectionViewItemCount == self.cardCollectionViewLayoutAttributes.count) {
            cardCollectionViewLayoutAttributes = self.cardCollectionViewLayoutAttributes
        } else {
            shouldReloadAllItems = true
        }
        
        var startIndex = Int((self.collectionView!.contentOffset.y + self.contentInset.top - self.spaceAtTopForBackgroundView) / self.cardHeadHeight) - 10
        var endBeforeIndex = Int((self.collectionView!.contentOffset.y + self.collectionView!.frame.size.height) / self.cardHeadHeight) + 5
        
        if(startIndex < 0) {
            startIndex = 0
        }
        if(endBeforeIndex > self.collectionViewItemCount) {
            endBeforeIndex = self.collectionViewItemCount
        }
        if(shouldReloadAllItems == true) {
            startIndex = 0
            endBeforeIndex = self.collectionViewItemCount
        }
        
        self.cardCollectionBottomCardsSet = self.generateBottomIndexes()
        
        var bottomIndex: CGFloat = 0
        for itemIndex in startIndex..<endBeforeIndex {
            let indexPath = IndexPath(item: itemIndex, section: 0)
            let cardLayoutAttribute = HFCardCollectionViewLayoutAttributes.init(forCellWith: indexPath)
            cardLayoutAttribute.zIndex = itemIndex
            
            if self.selectedIndex < 0 {
                self.generateNonSelectedCardsAttribute(cardLayoutAttribute)
            } else if self.selectedIndex == itemIndex {
                self.generateSelectedCardAttribute(cardLayoutAttribute)
            } else {
                self.generateBottomCardsAttribute(cardLayoutAttribute, bottomIndex: &bottomIndex)
            }
            
            if(itemIndex < cardCollectionViewLayoutAttributes.count) {
                cardCollectionViewLayoutAttributes[itemIndex] = cardLayoutAttribute
            } else {
                cardCollectionViewLayoutAttributes.append(cardLayoutAttribute)
            }
        }
        return cardCollectionViewLayoutAttributes
    }
    
    private func generateBottomIndexes() -> [Int] {
        if self.selectedIndex < 0 {
            return []
        }
        
        let half = Int(self.bottomNumberOfStackedCards / 2)
        var minIndex = self.selectedIndex - half
        var maxIndex = self.selectedIndex + half
        
        if minIndex < 0 {
            minIndex = 0
            maxIndex = self.selectedIndex + half + abs(self.selectedIndex - half)
        } else if maxIndex >= self.collectionViewItemCount {
            minIndex = (self.collectionViewItemCount - 2 * half) - 1
            maxIndex = self.collectionViewItemCount - 1
        }
        
        self.cardCollectionBottomCardsSelectedIndex = 0
        
        return Array(minIndex...maxIndex).filter({ (value) -> Bool in
            if value >= 0 && value != self.selectedIndex {
                if(value < self.selectedIndex) {
                    self.cardCollectionBottomCardsSelectedIndex += 1
                }
                return true
            }
            return false
        })
    }
    
    private func generateNonSelectedCardsAttribute(_ attribute: HFCardCollectionViewLayoutAttributes) {
        let cardHeadHeight = self.calculateCardHeadHeight()
        
        let startIndex = Int((self.contentOffsetTop - self.spaceAtTopForBackgroundView) / cardHeadHeight)
        let currentIndex = attribute.indexPath.item
        if(currentIndex == self.movingCardSelectedIndex) {
            attribute.alpha = 0.0
        } else {
            attribute.alpha = 1.0
        }
        
        let currentFrame = CGRect(x: 0, y: self.spaceAtTopForBackgroundView + cardHeadHeight * CGFloat(currentIndex), width: self.cardCollectionCellSize.width, height: self.cardCollectionCellSize.height)
        
        if(self.contentOffsetTop >= 0 && self.contentOffsetTop <= self.spaceAtTopForBackgroundView) {
            attribute.frame = currentFrame
        } else if(self.contentOffsetTop > self.spaceAtTopForBackgroundView) {
            attribute.isHidden = (currentIndex < startIndex)
            if(self.movingCardSelectedIndex >= 0 && currentIndex + 1 == self.movingCardSelectedIndex) {
                attribute.isHidden = false
            }
            if (currentIndex != 0 && currentIndex <= startIndex) || (currentIndex == 0 && (self.contentOffsetTop - self.spaceAtTopForBackgroundView) > 0) {
                var newFrame = currentFrame
                newFrame.origin.y = self.contentOffsetTop
                attribute.frame = newFrame
            } else {
                attribute.frame = currentFrame
            }
            if(attribute.isHidden == true && currentIndex < startIndex - 5) {
                attribute.frame = currentFrame
                attribute.frame.origin.y = self.collectionView!.frame.height * -1.5
            }
        } else {
            if(self.cardShouldStretchAtScrollTop == true) {
                let stretchMultiplier: CGFloat = (1 + (CGFloat(currentIndex + 1) * -0.2))
                var newFrame = currentFrame
                newFrame.origin.y = newFrame.origin.y + CGFloat(self.contentOffsetTop * stretchMultiplier)
                attribute.frame = newFrame
            } else {
                attribute.frame = currentFrame
            }
        }
        attribute.isExpand = false
    }
    
    private func generateSelectedCardAttribute(_ attribute: HFCardCollectionViewLayoutAttributes) {
        attribute.isExpand = true
        if(self.collectionViewItemCount == 1) {
            attribute.frame = CGRect.init(x: 0, y: self.contentOffsetTop + self.spaceAtTopForBackgroundView + 0.01 , width: self.cardCollectionCellSize.width, height: self.cardCollectionCellSize.height)
        } else {
            attribute.frame = CGRect.init(x: 0, y: self.contentOffsetTop + 0.01 , width: self.cardCollectionCellSize.width, height: self.cardCollectionCellSize.height)
        }
    }
    
    private func generateBottomCardsAttribute(_ attribute: HFCardCollectionViewLayoutAttributes, bottomIndex:inout CGFloat) {
        let index = attribute.indexPath.item
        let currentFrame = CGRect(x: self.collectionView!.frame.origin.x, y: self.cardHeadHeight * CGFloat(index), width: self.cardCollectionCellSize.width, height: self.cardCollectionCellSize.height)
        let maxY = self.collectionView!.contentOffset.y + self.collectionView!.frame.height
        let contentFrame = CGRect(x: 0, y: self.collectionView!.contentOffset.y, width: self.collectionView!.frame.width, height: maxY)
        if self.cardCollectionBottomCardsSet.contains(index) {
            let margin: CGFloat = self.bottomCardLookoutMargin
            let baseHeight = (self.collectionView!.frame.height + self.collectionView!.contentOffset.y) - self.bottomContentInset - (margin * self.bottomCardCount)
            let scale: CGFloat = self.calculateCardScale(forIndex: bottomIndex)
            let yPos = (bottomIndex * margin) + baseHeight
            attribute.frame = CGRect.init(x: 0, y: yPos, width: self.cardCollectionCellSize.width, height: self.cardCollectionCellSize.height)
            attribute.transform = CGAffineTransform(scaleX: scale, y: scale)
            bottomIndex += 1
        } else if contentFrame.intersects(currentFrame)  {
            attribute.isHidden = true
            attribute.frame = CGRect.init(x: 0, y: maxY, width: self.cardCollectionCellSize.width, height: self.cardCollectionCellSize.height)
        }else {
            attribute.isHidden = true
            attribute.frame = CGRect(x: 0, y: self.cardHeadHeight * CGFloat(index), width: cardCollectionCellSize.width, height: cardCollectionCellSize.height)
        }
        attribute.isExpand = false
    }
    
    private func calculateCardScale(forIndex index: CGFloat, scaleBehindCard: Bool = false) -> CGFloat {
        if(self.bottomStackedCardsShouldScale == true) {
            let addedDownScale: CGFloat = (scaleBehindCard == true && index < self.bottomCardCount) ? 0.01 : 0.0
            return 1.0 - (((index + 1 - self.bottomCardCount) * -1) * 0.01) - addedDownScale
        }
        return 1.0
    }
    
    private func calculateCardHeadHeight() -> CGFloat {
        var cardHeadHeight = self.cardHeadHeight
        if(self.cardShouldExpandHeadHeight == true) {
            cardHeadHeight = max(self.cardHeadHeight, (self.collectionView!.frame.height - (self.contentInset.top + self.bottomContentInset + self.spaceAtTopForBackgroundView)) / CGFloat(self.collectionViewItemCount))
        }
        return cardHeadHeight
    }
    
    // MARK: Selected Card
    
    private func initializeSelectedCard() -> Bool {
        if let cell = self.collectionView?.cellForItem(at: IndexPath(item: self.selectedIndex, section: 0)) {
            self.selectedCardCell = cell
            self.selectedCardPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.selectedCardPanGestureHandler))
            self.selectedCardPanGestureRecognizer?.delegate = self
            self.selectedCardCell?.addGestureRecognizer(self.selectedCardPanGestureRecognizer!)
            return true
        }
        return false
    }
    
    private func deinitializeSelectedCard() {
        if self.selectedCardCell != nil && self.selectedCardPanGestureRecognizer != nil {
            self.selectedCardCell?.removeGestureRecognizer(self.selectedCardPanGestureRecognizer!)
            self.selectedCardPanGestureRecognizer = nil
            self.selectedCardCell = nil
        }
    }
    
    internal func selectedCardPanGestureHandler() {
        if self.collectionViewItemCount == 1 || self.selectedCardIsFlipped == true {
            return
        }
        if let selectedCardPanGestureRecognizer = self.selectedCardPanGestureRecognizer, self.selectedCardCell != nil {
            let gestureTouchLocation = selectedCardPanGestureRecognizer.location(in: self.collectionView)
            let shiftY: CGFloat = (gestureTouchLocation.y - self.selectedCardPanGestureTouchLocationY  > 0) ? gestureTouchLocation.y - self.selectedCardPanGestureTouchLocationY : 0
            
            switch selectedCardPanGestureRecognizer.state {
            case .began:
                UIApplication.shared.keyWindow?.endEditing(true)
                self.selectedCardPanGestureTouchLocationY = gestureTouchLocation.y
            case .changed:
                let scaleTarget = self.calculateCardScale(forIndex: self.cardCollectionBottomCardsSelectedIndex, scaleBehindCard: true)
                let scaleDiff: CGFloat = 1.0 - scaleTarget
                let scale: CGFloat = 1.0 - min(((shiftY * scaleDiff) / 100) , scaleDiff)
                let transformY = CGAffineTransform.init(translationX: 0, y: shiftY)
                let transformScale = CGAffineTransform.init(scaleX: scale, y: scale)
                self.selectedCardCell?.transform = transformY.concatenating(transformScale)
            default:
                let isNeedReload = (shiftY > self.selectedCardCell!.frame.height / 7) ? true : false
                let resetY = (isNeedReload) ? self.collectionView!.frame.height : 0
                let scale: CGFloat = (isNeedReload) ? self.calculateCardScale(forIndex: self.cardCollectionBottomCardsSelectedIndex, scaleBehindCard: true) : 1.0
                
                let transformScale = CGAffineTransform.init(scaleX: scale, y: scale)
                let transformY = CGAffineTransform.init(translationX: 0, y: resetY)
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.selectedCardCell?.transform = transformY.concatenating(transformScale)
                }, completion: { (finished) in
                    if isNeedReload && finished {
                        self.selectCardAt(index: self.selectedIndex)
                    }
                })
            }
        }
    }
    
    // MARK: Moving Card
    
    internal func movingCardGestureHandler() {
        let moveUpOffset: CGFloat = 20
        
        if let movingCardGestureRecognizer = self.movingCardGestureRecognizer {
            switch movingCardGestureRecognizer.state {
            case .began:
                self.movingCardGestureStartLocation = movingCardGestureRecognizer.location(in: self.collectionView)
                if let indexPath = self.collectionView?.indexPathForItem(at: self.movingCardGestureStartLocation) {
                    self.movingCardActive = true
                    if(indexPath.item < self.firstMovableIndex) {
                        self.movingCardActive = false
                        return
                    }
                    if let cell = self.collectionView?.cellForItem(at: indexPath) {
                        self.movingCardStartIndexPath = indexPath
                        self.movingCardCenterStart = cell.center
                        self.movingCardSnapshotCell = cell.snapshotView(afterScreenUpdates: false)
                        self.movingCardSnapshotCell?.frame = cell.frame
                        self.movingCardSnapshotCell?.alpha = 1.0
                        self.movingCardSnapshotCell?.layer.zPosition = cell.layer.zPosition
                        self.collectionView?.insertSubview(self.movingCardSnapshotCell!, aboveSubview: cell)
                        cell.alpha = 0.0
                        self.movingCardSelectedIndex = indexPath.item
                        UIView.animate(withDuration: 0.2, animations: {
                            self.movingCardSnapshotCell?.frame.origin.y -= moveUpOffset
                        })
                    }
                } else {
                    self.movingCardActive = false
                }
            case .changed:
                if self.movingCardActive == true {
                    self.movingCardGestureCurrentLocation = movingCardGestureRecognizer.location(in: self.collectionView)
                    var currentCenter = self.movingCardCenterStart
                    currentCenter.y += (self.movingCardGestureCurrentLocation.y - self.movingCardGestureStartLocation.y - moveUpOffset)
                    self.movingCardSnapshotCell?.center = currentCenter
                    if(self.movingCardGestureCurrentLocation.y > ((self.collectionView!.contentOffset.y + self.collectionView!.frame.height) - self.spaceAtBottom - self.bottomContentInset - self.scrollAreaBottom)) {
                        self.setupScrollTimer(direction: .down)
                    } else if((self.movingCardGestureCurrentLocation.y - self.collectionView!.contentOffset.y) - self.contentInset.top < self.scrollAreaTop) {
                        self.setupScrollTimer(direction: .up)
                    } else {
                        self.invalidateScrollTimer()
                    }
                    
                    var tempIndexPath = self.collectionView?.indexPathForItem(at: self.movingCardGestureCurrentLocation)
                    if(tempIndexPath == nil) {
                        tempIndexPath = self.collectionView?.indexPathForItem(at: self.movingCardLastTouchedLocation)
                    }
                    
                    if let currentTouchedIndexPath = tempIndexPath {
                        self.movingCardLastTouchedLocation = self.movingCardGestureCurrentLocation
                        if(currentTouchedIndexPath.item < self.firstMovableIndex) {
                            return
                        }
                        if(self.movingCardLastTouchedIndexPath == nil && currentTouchedIndexPath != self.movingCardStartIndexPath!) {
                            self.movingCardLastTouchedIndexPath = self.movingCardStartIndexPath
                        }
                        if(self.self.movingCardLastTouchedIndexPath != nil && self.movingCardLastTouchedIndexPath! != currentTouchedIndexPath) {
                            let movingCell = self.collectionView?.cellForItem(at: currentTouchedIndexPath)
                            let movingCellAttr = self.collectionView?.layoutAttributesForItem(at: currentTouchedIndexPath)
                            if(movingCell != nil) {
                                let cardHeadHeight = self.calculateCardHeadHeight()
                                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                                    movingCell?.frame.origin.y -= cardHeadHeight
                                }, completion: { (finished) in
                                    movingCellAttr?.frame.origin.y -= cardHeadHeight
                                })
                            }
                            
                            self.movingCardSelectedIndex = currentTouchedIndexPath.item
                            self.collectionView?.dataSource?.collectionView?(self.collectionView!, moveItemAt: currentTouchedIndexPath, to: self.movingCardLastTouchedIndexPath!)
                            UIView.performWithoutAnimation {
                                self.collectionView?.moveItem(at: currentTouchedIndexPath, to: self.movingCardLastTouchedIndexPath!)
                            }
                            
                            self.movingCardLastTouchedIndexPath = currentTouchedIndexPath
                            if let belowCell = self.collectionView?.cellForItem(at: currentTouchedIndexPath) {
                                self.movingCardSnapshotCell?.removeFromSuperview()
                                self.collectionView?.insertSubview(self.movingCardSnapshotCell!, belowSubview: belowCell)
                                self.movingCardSnapshotCell?.layer.zPosition = belowCell.layer.zPosition
                            } else {
                                self.collectionView?.sendSubview(toBack: self.movingCardSnapshotCell!)
                            }
                        }
                    }
                }
            case .ended:
                self.invalidateScrollTimer()
                if self.movingCardActive == true {
                    var indexPath = self.movingCardStartIndexPath!
                    if(self.movingCardLastTouchedIndexPath != nil) {
                        indexPath = self.movingCardLastTouchedIndexPath!
                    }
                    if let cell = self.collectionView?.cellForItem(at: indexPath) {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.movingCardSnapshotCell?.frame = cell.frame
                        }, completion: { (finished) in
                            self.movingCardActive = false
                            self.movingCardLastTouchedIndexPath = nil
                            self.movingCardSelectedIndex = -1
                            self.collectionView?.reloadData()
                            self.movingCardSnapshotCell?.removeFromSuperview()
                            self.movingCardSnapshotCell = nil
                            if(self.movingCardStartIndexPath == indexPath) {
                                UIView.animate(withDuration: 0, animations: {
                                    self.invalidateLayout()
                                })
                            }
                        })
                    } else {
                        fallthrough
                    }
                }
            case .cancelled:
                self.movingCardActive = false
                self.movingCardLastTouchedIndexPath = nil
                self.movingCardSelectedIndex = -1
                self.collectionView?.reloadData()
                self.movingCardSnapshotCell?.removeFromSuperview()
                self.movingCardSnapshotCell = nil
                self.invalidateLayout()
            default:
                break
            }
        }
    }
    
    // MARK: AutoScroll
    
    enum HFCardCollectionScrollDirection : Int {
        case unknown = 0
        case up
        case down
    }
    
    private func setupScrollTimer(direction: HFCardCollectionScrollDirection) {
        if(self.autoscrollDisplayLink != nil && self.autoscrollDisplayLink!.isPaused == false) {
            if(direction == self.autoscrollDirection) {
                return
            }
        }
        self.invalidateScrollTimer()
        self.autoscrollDisplayLink = CADisplayLink(target: self, selector: #selector(self.autoscrollHandler(displayLink:)))
        self.autoscrollDirection = direction
        self.autoscrollDisplayLink?.add(to: .main, forMode: .commonModes)
    }
    
    private func invalidateScrollTimer() {
        if(self.autoscrollDisplayLink != nil && self.autoscrollDisplayLink!.isPaused == false) {
            self.autoscrollDisplayLink?.invalidate()
        }
        self.autoscrollDisplayLink = nil
    }
    
    internal func autoscrollHandler(displayLink: CADisplayLink) {
        let direction = self.autoscrollDirection
        if(direction == .unknown) {
            return
        }
        
        let scrollMultiplier = self.generateScrollSpeedMultiplier()
        let frameSize = self.collectionView!.frame.size
        let contentSize = self.collectionView!.contentSize
        let contentOffset = self.collectionView!.contentOffset
        let contentInset = self.collectionView!.contentInset
        var distance: CGFloat = CGFloat(rint(scrollMultiplier * displayLink.duration))
        var translation = CGPoint.zero
        
        switch(direction) {
        case .up:
            distance = -distance
            let minY: CGFloat = 0.0 - contentInset.top
            if (contentOffset.y + distance) <= minY {
                distance = -contentOffset.y - contentInset.top
            }
            translation = CGPoint(x: 0.0, y: distance)
        case .down:
            let maxY: CGFloat = max(contentSize.height, frameSize.height) - frameSize.height + self.bottomContentInset
            if (contentOffset.y + distance) >= maxY {
                distance = maxY - contentOffset.y
            }
            translation = CGPoint(x: 0.0, y: distance)
        default:
            break
        }
        
        self.collectionView!.contentOffset = self.cgPointAdd(contentOffset, translation)
        self.movingCardGestureHandler()
    }
    
    private func generateScrollSpeedMultiplier() -> Double {
        var multiplier: Double = 250.0
        if let movingCardGestureRecognizer = self.movingCardGestureRecognizer {
            let touchLocation = movingCardGestureRecognizer.location(in: self.collectionView)
            let maxSpeed: CGFloat = 600
            if(self.autoscrollDirection == .up) {
                let touchPosY = min(max(0, self.scrollAreaTop - (touchLocation.y - self.contentOffsetTop)), self.scrollAreaTop)
                multiplier = Double(maxSpeed * (touchPosY / self.scrollAreaTop))
            } else if(self.autoscrollDirection == .down) {
                let offsetTop = ((self.collectionView!.contentOffset.y + self.collectionView!.frame.height) - self.spaceAtBottom - self.bottomContentInset - self.scrollAreaBottom)
                let touchPosY = min(max(0, (touchLocation.y - offsetTop)), self.scrollAreaBottom)
                multiplier = Double(maxSpeed * (touchPosY / self.scrollAreaBottom))
            }
        }
        return multiplier
    }
    
    private func cgPointAdd(_ point1: CGPoint, _ point2: CGPoint) -> CGPoint {
        return CGPoint(x: point1.x + point2.x, y: point1.y + point2.y)
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if(gestureRecognizer == self.movingCardGestureRecognizer || gestureRecognizer == self.collectionViewTapGestureRecognizer) {
            if(self.selectedIndex >= 0) {
                return false
            }
        }
        return true
    }
    
}

/*** Layout Attributes ***/

open class HFCardCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
    /// Specifies if the CardCell is expanded.
    public var isExpand = false
    
    override open func copy(with zone: NSZone? = nil) -> Any {
        let attribute = super.copy(with: zone) as! HFCardCollectionViewLayoutAttributes
        attribute.isExpand = isExpand
        return attribute
    }
    
}

/*** Extensions ***/

extension UICollectionView {
    
    override open func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if let collectionViewLayout = self.collectionViewLayout as? HFCardCollectionViewLayout {
            let gestureClassName = String(describing: type(of: gestureRecognizer))
            let gestureString = String(describing: gestureRecognizer)
            // Prevent default behaviour of 'installsStandardGestureForInteractiveMovement = true' and install a custom reorder gesture recognizer.
            if(gestureClassName == "UILongPressGestureRecognizer" && gestureString.range(of: "action=_handleReorderingGesture") != nil) {
                collectionViewLayout.installMoveCardsGestureRecognizer()
                return
            }
        }
        super.addGestureRecognizer(gestureRecognizer)
    }
    
    override open func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        if self.collectionViewLayout is HFCardCollectionViewLayout {
            if(self.isScrollEnabled == true) {
                super.setContentOffset(contentOffset, animated: animated)
            }
        } else {
            super.setContentOffset(contentOffset, animated: animated)
        }
    }
    
}

extension UICollectionViewCell {
    
    // Important for updating the Z index
    // and setting the flag 'isUserInteractionEnabled'
    override open func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let cardLayoutAttributes = layoutAttributes as? HFCardCollectionViewLayoutAttributes {
            self.layer.zPosition = CGFloat(cardLayoutAttributes.zIndex)
            self.contentView.isUserInteractionEnabled = cardLayoutAttributes.isExpand
        } else {
            self.contentView.isUserInteractionEnabled = true
        }
    }
    
}
