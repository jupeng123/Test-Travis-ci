//
//  CardsLayout.swift
//  travisDemo
//
//  Created by jp on 2019/7/17.
//  Copyright © 2019 HK01. All rights reserved.
//

import UIKit

class CardsLayout: UICollectionViewLayout {
    
    public var itemSize: CGSize = .zero {
        didSet { invalidateLayout() }
    }
    
    public var minScale: CGFloat = 0.8 {
        didSet { invalidateLayout() }
    }
    public var spacing: CGFloat = 35 {
        didSet { invalidateLayout() }
    }
    public var visibleItemsCount: Int = 3 {
        didSet { invalidateLayout() }
    }

    override open var collectionView: UICollectionView {
        return super.collectionView ?? UICollectionView(frame: CGRect.zero)
    }
    
    /// 重新布局
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    var itemsCount: CGFloat {
        return CGFloat(collectionView.numberOfItems(inSection: 0))
    }
    
    var collectionBounds: CGRect {
        return collectionView.bounds
    }
    
    var contentOffSet: CGPoint {
        return collectionView.contentOffset
    }
    
    /// 当前页
    var currentPage: Int {
        return max(Int(contentOffSet.x) / Int(collectionBounds.width), 0)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionBounds.width * itemsCount, height: collectionBounds.height)
    }
    
    private var didInitialSetup = false
    
    override func prepare() {
        guard !didInitialSetup else {
            return
        }
        didInitialSetup = true
        
        itemSize = CGSize(width: 100, height: 200)
    }
    
    ///
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let itemsCount = collectionView.numberOfItems(inSection: 0)
        guard itemsCount > 0 else {
            return nil
        }
        
        let minVisibleIndex = max(currentPage - visibleItemsCount + 1, 0)
        let offset = CGFloat(Int(contentOffSet.x) % Int(collectionBounds.width))
        let offsetProgress = CGFloat(offset) / collectionBounds.width
        let maxVisibleIndex = max(min(itemsCount - 1, currentPage + 1), minVisibleIndex)
        
        let attributes: [UICollectionViewLayoutAttributes] = (minVisibleIndex...maxVisibleIndex).map {
            let indexPath = IndexPath(item: $0, section: 0)
            return layoutAttributes(for: indexPath, currentPage, offset, offsetProgress)
        }
        
        return attributes
    }
    
    private func layoutAttributes(for indexPath: IndexPath, _ pageIndex: Int, _ offset: CGFloat, _ offsetProgress: CGFloat) -> UICollectionViewLayoutAttributes {
        let attributes = UICollectionViewLayoutAttributes(forCellWith:indexPath)
        let visibleIndex = max(indexPath.item - pageIndex + visibleItemsCount, 0)
        
        // 设置item大小
        attributes.size = itemSize
        let topCardMidX = contentOffSet.x + collectionBounds.width - itemSize.width / 2 - spacing / 2
        attributes.center = CGPoint(x: topCardMidX - spacing * CGFloat(visibleItemsCount - visibleIndex), y: collectionBounds.midY)
        attributes.zIndex = visibleIndex
        let scale = parallaxProgress(for: visibleIndex, offsetProgress, minScale)
        attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        switch visibleIndex {
        case visibleItemsCount + 1:
            attributes.center.x += collectionBounds.width - offset - spacing
//            cell?.setShadeOpacity(progress: 1)
        default:
            attributes.center.x -= spacing * offsetProgress
        }
        
        return attributes
    }
    
    private func parallaxProgress(for visibleIndex: Int, _ offsetProgress: CGFloat, _ minimum: CGFloat = 0) -> CGFloat {
        let step = (1.0 - minimum) / CGFloat(visibleItemsCount)
        return 1.0 - CGFloat(visibleItemsCount - visibleIndex) * step - step * offsetProgress
    }
}
