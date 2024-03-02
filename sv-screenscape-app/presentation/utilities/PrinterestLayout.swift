//
//  PrinterestLayout.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 01/03/2024.
//

import UIKit

/**
 PinterestLayout.
 */
public class PinterestLayout: UICollectionViewLayout {
    /**
     Delegate.
     */
    public var delegate: PinterestLayoutDelegate!
    /**
     Number of columns.
     */
    public var numberOfColumns: Int = 1
    /**
     Horizontal spacing between columns
     */
    public var columnSpacing: CGFloat = 12
    /**
     Vertical spacing between cells within column
     */
    public var cellPadding: CGFloat = 12

    public var headerReferenceSize: CGSize = .zero
    public var footerReferenceSize: CGSize = .zero
    /**
     Vertical spacing between SectionHeader and Cell/Cell and SectionFooter, SectionFooter and SectionHeader
     */
    public var sectionPadding: CGFloat = 12
    private var cache = [PinterestLayout2Attributes]()
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        let bounds = collectionView.bounds
        let insets = collectionView.contentInset
        return bounds.width - insets.left - insets.right
    }

    override public var collectionViewContentSize: CGSize {
        return CGSize(
            width: contentWidth,
            height: contentHeight
        )
    }

    override public class var layoutAttributesClass: AnyClass {
        return PinterestLayout2Attributes.self
    }

    override public var collectionView: UICollectionView {
        return super.collectionView!
    }

    private var numberOfSections: Int {
        return collectionView.numberOfSections
    }

    private func numberOfItems(inSection section: Int) -> Int {
        return collectionView.numberOfItems(inSection: section)
    }

    var cellHeightCacheArray: [CGFloat?] = []
    var calculationIndex: Int = 0

    /**
     Invalidates layout.
     */
    override public func invalidateLayout() {
        cache.removeAll()
        contentHeight = 0

        super.invalidateLayout()
    }

    override public func prepare() {
        if cache.isEmpty {
            update()
        }

        super.prepare()
    }

    override open func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        for updateItem in updateItems {
            switch updateItem.updateAction {
            case .insert:
                cache.removeAll()
                contentHeight = 0
            case .delete:
                cache.removeAll()
                contentHeight = 0
                update()
            case .reload:
                cache.removeAll()
                contentHeight = 0
            case .move:
                cache.removeAll()
                contentHeight = 0
            case .none:
                break
            @unknown default:
                cache.removeAll()
                contentHeight = 0
            }
        }
        update()
        super.prepare(forCollectionViewUpdates: updateItems)
    }

    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.size != collectionView.bounds.size
    }

    func update() {
        delegate.pintrestCollectionViewLayoutUpdating?(updating: true)

        cache.removeAll()
        contentHeight = 0

        let collumnWidth = (contentWidth - (CGFloat(numberOfColumns - 1) * columnSpacing)) / CGFloat(numberOfColumns)
        let cellWidth = collumnWidth
        var xOffsets = [CGFloat]()

        for collumn in 0 ..< numberOfColumns {
            xOffsets.append(CGFloat((collumnWidth + columnSpacing) * CGFloat(collumn)))
        }

        for section in 0 ..< numberOfSections {
            let numberOfItems = self.numberOfItems(inSection: section)

            let headerSize: CGSize = {
                if let ret = delegate.collectionView?(
                    collectionView: collectionView,
                    sizeForSectionHeaderAt: section,
                    with: contentWidth
                ) {
                    return ret
                }
                if self.headerReferenceSize != .zero {
                    return CGSize(width: contentWidth, height: self.headerReferenceSize.height)
                }
                return CGSize.zero
            }()

            if headerSize != .zero {
                if section != 0 {
                    contentHeight += sectionPadding
                }

                let headerX = (contentWidth - headerSize.width) / 2
                let headerFrame = CGRect(
                    origin: CGPoint(
                        x: headerX,
                        y: contentHeight
                    ),
                    size: headerSize
                )
                let headerAttributes = PinterestLayout2Attributes(
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    with: IndexPath(item: 0, section: section)
                )
                headerAttributes.frame = headerFrame
                cache.append(headerAttributes)
                contentHeight = headerFrame.maxY
                contentHeight += sectionPadding
            }

            var yOffsets = [CGFloat](
                repeating: contentHeight,
                count: numberOfColumns
            )

            // Skip 2nd time cell height calculation
            calculationIndex += 1
            if calculationIndex >= 3 {
                cellHeightCacheArray.removeAll()
            }

            for item in 0 ..< numberOfItems {
                let indexPath = IndexPath(item: item, section: section)

                let column = yOffsets.firstIndex(of: yOffsets.min() ?? 0) ?? 0

                if !cellHeightCacheArray.indices.contains(item) {
                    let cellHeight = delegate.collectionView(
                        collectionView: collectionView,
                        heightForItemAt: indexPath,
                        with: cellWidth
                    )

                    cellHeightCacheArray.append(cellHeight)
                }

                let frame = CGRect(
                    x: xOffsets[column],
                    y: yOffsets[column],
                    width: cellWidth,
                    height: cellHeightCacheArray[item] ?? 0
                )

                let insetFrame = frame.insetBy(dx: 0, dy: 0)
                let attributes = PinterestLayout2Attributes(
                    forCellWith: indexPath
                )
                attributes.frame = insetFrame
                attributes.cellHeight = cellHeightCacheArray[item] ?? 0
                cache.append(attributes)

                contentHeight = max(contentHeight, frame.maxY)
                yOffsets[column] = yOffsets[column] + (cellHeightCacheArray[item] ?? 0) + cellPadding
            }

            let footerSize: CGSize = {
                if let ret = delegate.collectionView?(
                    collectionView: collectionView,
                    sizeForSectionFooterAt: section,
                    with: contentWidth
                ) {
                    return ret
                }
                if self.footerReferenceSize != .zero {
                    return CGSize(width: contentWidth, height: self.footerReferenceSize.height)
                }
                return CGSize.zero
            }()
            if footerSize != .zero {
                contentHeight += sectionPadding
                let footerX = (contentWidth - footerSize.width) / 2
                let footerFrame = CGRect(
                    origin: CGPoint(
                        x: footerX,
                        y: contentHeight
                    ),
                    size: footerSize
                )
                let footerAttributes = PinterestLayout2Attributes(
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                    with: IndexPath(item: 0, section: section)
                )
                footerAttributes.frame = footerFrame
                cache.append(footerAttributes)
                contentHeight = footerFrame.maxY
            }
        }

        delegate.pintrestCollectionViewLayoutUpdating?(updating: false)
    }

    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if cache.isEmpty {
            update()
        }

        var layoutAttributes = [UICollectionViewLayoutAttributes]()

        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }

        return layoutAttributes
    }
}

/**
 CollectionViewLayoutAttributes.
 */
public class PinterestLayout2Attributes: UICollectionViewLayoutAttributes {
    /**
     Image height to be set to contstraint in collection view cell.
     */
    public var cellHeight: CGFloat = 0

    override public func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! PinterestLayout2Attributes
        copy.cellHeight = cellHeight
        return copy
    }

    override public func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? PinterestLayout2Attributes {
            if attributes.cellHeight == cellHeight {
                return super.isEqual(object)
            }
        }
        return false
    }
}

/**
 PinterestLayoutDelegate.
 */
@objc public protocol PinterestLayoutDelegate {
    /**
     Size for section header. Optional.

     @param collectionView - collectionView
     @param section - section for section header view

     Returns size for section header view.
     */
    @objc optional func collectionView(collectionView: UICollectionView,
                                       sizeForSectionHeaderAt section: Int,
                                       with width: CGFloat) -> CGSize
    /**
     Size for section footer. Optional.

     @param collectionView - collectionView
     @param section - section for section footer view

     Returns size for section footer view.
     */
    @objc optional func collectionView(collectionView: UICollectionView,
                                       sizeForSectionFooterAt section: Int,
                                       with width: CGFloat) -> CGSize
    /**
     Height for image view in cell.

     @param collectionView - collectionView
     @param indexPath - index path for cell

     Returns height of image view.
     */
    func collectionView(collectionView: UICollectionView,
                        heightForItemAt indexPath: IndexPath,
                        with width: CGFloat) -> CGFloat

    /// To inform deletage if pintrest layout is updating layout, avoid doing anyting to update ui or might break the collection view
    @objc optional func pintrestCollectionViewLayoutUpdating(updating: Bool)
}
