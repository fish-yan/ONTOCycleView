
import UIKit
import Kingfisher

/// PageControl 的对齐方式
public enum ONTOCycleViewPageControlAlignment {
    case center
    case right(offset: CGFloat)
}

/// PageControl 的 Style
/// 这个后面的 animated 需要加一些参数，让我们可以自由的配置
/// 或者再增加一些其他的自定义的 case
public enum ONTOCycleViewPageControlStyle {
    case `default`
    case animated
}

public protocol ONTOCycleViewDelegate: NSObjectProtocol {
    func cycleView(_ scrollView: ONTOCycleView, didSelectItemAt index: Int)
    func cycleView(_ scrollView: ONTOCycleView, didScrollTo index: Int)
}

public extension ONTOCycleViewDelegate {
    func cycleView(_ scrollView: ONTOCycleView, didSelectItemAt index: Int) { }
    func cycleView(_ scrollView: ONTOCycleView, didScrollTo index: Int) { }
}

open class ONTOCycleView: UIView {
    
    public var imagePathArray: [String] = [String]() {
        didSet {
            dataSource = imagePathArray
        }
    }
    
    public var dataSource: [Any] = [Any]() {
        didSet {
            collectionView.isScrollEnabled = !isSingleImage
            (isAutoScroll && !isSingleImage) ? setupTimer() : invalidateTimer()
            setupPageControl()
            collectionView.reloadData()
        }
    }
    
    public var timeInterval: TimeInterval = 2 {
        didSet {
            setupTimer()
        }
    }
    
    public var isAutoScroll: Bool = true {
        didSet {
            setupTimer()
        }
    }
    
    public var scrollDirection: UICollectionView.ScrollDirection = .horizontal {
        didSet {
            flowLayout.scrollDirection = scrollDirection
        }
    }
    
    public weak var delegate: ONTOCycleViewDelegate?
    
    public var infiniteLoop: Bool = true
    public var imageContentMode: UIView.ContentMode = .scaleAspectFit
    public var placeholderContentMode: UIView.ContentMode = .scaleAspectFill
    
    public var placeholderImage: UIImage? {
        didSet {
            backgroundImageView.image = placeholderImage
        }
    }
    public var showPageControl: Bool = true {
        didSet {
            pageControl?.isHidden = !showPageControl
        }
    }
    public var hidesForSinglePage: Bool = true
    
    public var pageControlStyle: ONTOCycleViewPageControlStyle = .default {
        didSet {
            setupPageControl()
        }
    }
    public var pageControlDotSize: CGSize = CGSize(width: 10, height: 10) {
        didSet {
            setupPageControl()
        }
    }
    public var pageControlAlignment: ONTOCycleViewPageControlAlignment = .center
    
    public var currentDotColor: UIColor = .white {
        didSet {
            if let p = pageControl as? UIPageControl {
                p.currentPageIndicatorTintColor = currentDotColor
            } else if let p = pageControl as? ONTOPageControl {
                p.currentDotColor = currentDotColor
            }
        }
    }
    public var dotColor: UIColor = .lightGray {
        didSet {
            if let p = pageControl as? UIPageControl {
                p.pageIndicatorTintColor = dotColor
            } else if let p = pageControl as? ONTOPageControl {
                p.dotColor = dotColor
            }
        }
    }
    public var dotImageSelected: UIImage? {
        didSet {
            if pageControlStyle != .animated {
                pageControlStyle = .animated
            }
            if let image = dotImageSelected {
                setCustomPageControlDotImage(image: image, isCurrent: true)
            }
        }
    }
    public var dotImageNormal: UIImage? {
        didSet {
            if pageControlStyle != .animated {
                pageControlStyle = .animated
            }
            if let image = dotImageNormal {
                setCustomPageControlDotImage(image: image, isCurrent: false)
            }
        }
    }
    
    private var timer: Timer?
    private var pageControl: UIControl?
    private lazy var backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView()
        backgroundImageView.contentMode = placeholderContentMode
        insertSubview(backgroundImageView, belowSubview: collectionView)
        return backgroundImageView
    }()
    private var isSingleImage: Bool {
        return dataSource.count <= 1
    }
    private var totalItemsCount: Int {
        return infiniteLoop ? dataSource.count * 100 : dataSource.count
    }
    
    private func setupPageControl() {
        if let pageControl = pageControl {
            pageControl.removeFromSuperview()
        }
        if dataSource.count == 0 || (dataSource.count == 1 && hidesForSinglePage) {
            return
        }
        switch pageControlStyle {
        case .animated:
            pageControl = ONTOPageControl()
            if let p = pageControl as? ONTOPageControl {
                p.numberOfPages = dataSource.count
                p.currentDotColor = currentDotColor
                p.dotColor = dotColor
                p.isUserInteractionEnabled = false
                p.currentPage = currentPageControlIndex
                addSubview(p)
            }
        case .default:
            pageControl = UIPageControl()
            if let p = pageControl as? UIPageControl {
                p.numberOfPages = dataSource.count
                p.isUserInteractionEnabled = false
                p.currentPage = currentPageControlIndex
                p.currentPageIndicatorTintColor = currentDotColor
                p.pageIndicatorTintColor = dotColor
                addSubview(p)
            }
        }
        if let image = dotImageSelected {
            dotImageSelected = image
        }
        
        if let image = dotImageNormal {
            dotImageNormal = image
        }
    }
    
    private func setCustomPageControlDotImage(image: UIImage, isCurrent: Bool) {
        if let p = pageControl as? ONTOPageControl {
            if isCurrent {
                p.currentDotImage = image
            } else {
                p.dotImage = image
            }
        }
    }
    
    private var currentIndex: Int {
        guard collectionView.bounds.size != .zero else {
            return 0
        }
        var index = 0
        if flowLayout.scrollDirection == .horizontal {
            index = Int((collectionView.contentOffset.x + flowLayout.itemSize.width * 0.5) / flowLayout.itemSize.width)
        } else {
            index = Int((collectionView.contentOffset.y + flowLayout.itemSize.height * 0.5) / flowLayout.itemSize.height)
        }
        return max(0, index)
    }
    
    private var currentPageControlIndex: Int {
        return currentIndex % dataSource.count
    }
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollsToTop = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ONTOCycleImageCell.self, forCellWithReuseIdentifier: String(describing: ONTOCycleImageCell.self))
        return collectionView
    }()
    
    private var cellClass: AnyClass = ONTOCycleImageCell.self
    
    // MARK: Override
    public convenience init(frame: CGRect, imageNames: [String] = [], infiniteLoop: Bool = true) {
        self.init(frame: frame)
        
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .lightGray
        addSubview(collectionView)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        backgroundColor = .lightGray
        addSubview(collectionView)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        flowLayout.itemSize = frame.size
        collectionView.frame = bounds
        if collectionView.contentOffset.x == 0 && totalItemsCount > 0 {
            collectionView.scrollToItem(at: IndexPath(item: infiniteLoop ? totalItemsCount / 2 : 0, section: 0), at: .left, animated: false)
        }
        var size: CGSize = .zero
        if let p = pageControl as? ONTOPageControl {
            size = p.sizeForNumber(of: dataSource.count)
        } else {
            size = CGSize(width: CGFloat(dataSource.count) * pageControlDotSize.width + CGFloat((dataSource.count-1) * 8) + 30, height: pageControlDotSize.height)
        }
        var x = (bounds.width - size.width ) / 2
        if case let ONTOCycleViewPageControlAlignment.right(offset) = pageControlAlignment {
            x = collectionView.bounds.width - size.width - 10 + offset
        }
        let y = collectionView.bounds.height - size.height - 10
        if let p = pageControl as? ONTOPageControl {
            p.sizeToFit()
        }
        pageControl?.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        pageControl?.isHidden = !showPageControl
        backgroundImageView.frame = bounds
    }
    
    // 禁用滑动手势
    public func disableScrollGesture() {
        collectionView.canCancelContentTouches = false
        collectionView.gestureRecognizers?.forEach({ (gesture) in
            if gesture.isKind(of: UIPanGestureRecognizer.self) {
                collectionView.removeGestureRecognizer(gesture)
            }
        })
    }
    
    public func register(_ cellClass: AnyClass) {
        self.cellClass = cellClass
        collectionView.register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
    }
    
    //MARK: timer
    private func setupTimer() {
        invalidateTimer()
        guard isAutoScroll else { return }
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            MainActor.assumeIsolated {
                self.autoScroll()
            }
        })
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    @objc private func autoScroll() {
        guard totalItemsCount > 0 else { return }
        scroll(to: currentIndex + 1)
    }
    
    private func scroll(to targetIndex: Int) {
        if targetIndex >= totalItemsCount {
            if infiniteLoop {
                collectionView.scrollToItem(at: IndexPath(item: totalItemsCount / 2, section: 0), at: [.left, .top], animated: false)
            }
        } else {
            collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: [.left, .top], animated: true)
        }
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: clearCache
    public static func clearCache() {
        ImageCache.default.clearDiskCache()
    }
    
    deinit {
        print("ONTOCycleView deinit")
    }
}

extension ONTOCycleView: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalItemsCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: cellClass), for: indexPath)
        let model = dataSource[indexPath.item % dataSource.count]
        if let cell = cell as? ONTOCycleCell {
            cell.updateUI(model: model)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.cycleView(self, didSelectItemAt: currentPageControlIndex)
    }
}

extension ONTOCycleView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch pageControl {
        case let pageControl as UIPageControl:
            pageControl.currentPage = currentPageControlIndex
        case let pageControl as ONTOPageControl:
            pageControl.currentPage = currentPageControlIndex
        default: break
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        invalidateTimer()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        setupTimer()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.cycleView(self, didScrollTo: currentPageControlIndex)
    }
}
