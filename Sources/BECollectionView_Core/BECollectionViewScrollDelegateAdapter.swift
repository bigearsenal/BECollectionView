//
//  BECollectionViewScrollDelegateAdapter.swift
//  BECollectionView
//
//  Created by Andrew Vasiliev on 23.11.2021.
//

import UIKit

final public class BECollectionViewScrollDelegateAdapter: NSObject, UICollectionViewDelegate {
    public weak var realScrollDelegate: UIScrollViewDelegate?

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        realScrollDelegate?.scrollViewDidScroll?(scrollView)
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        realScrollDelegate?.scrollViewDidZoom?(scrollView)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        realScrollDelegate?.scrollViewWillBeginDragging?(scrollView)
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        realScrollDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        realScrollDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        realScrollDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        realScrollDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        realScrollDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        realScrollDelegate?.viewForZooming?(in: scrollView)
    }

    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        realScrollDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        realScrollDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }

    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        realScrollDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
    }

    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        realScrollDelegate?.scrollViewDidScrollToTop?(scrollView)
    }

    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        realScrollDelegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
}
