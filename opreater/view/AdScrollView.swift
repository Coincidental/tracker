//
//  AdScrollView.swift
//  Tracker
//
//  Created by StephenLouis on 2018/12/12.
//  Copyright © 2018 StephenLouis. All rights reserved.
//

//              [url1,url2,url3,url4]   （url 数组）
//          [url4  url1  url2  url3  url4  url1]    (cell 对应的url)
//                *起始位----------------->滚动到最后一个cell时-- |
//                      <------------------------------------ |
//                      (回到起始位置)
//          (向左滚动时原理同向右滚动)

import UIKit
import Kingfisher

fileprivate let cellId = "bannerCell"

public typealias AdScrollViewCustomCellHandle = (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ picture: String) -> UICollectionViewCell

//、 滚动方向
public enum AdScrollViewRollingDirection: Int {
    case top
    case left
    case bottom
    case right
}

/// PageControl的位置
public enum AdPageControlStyle: Int {
    case center
    case left
    case right
}

class AdScrollView: UIView {
    // 图片数据源
    open var pictures: [String] = [] {
        didSet {
            if self.pictures.count > 0 {
                self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: self.scrollPosition, animated: false)
                self.bringSubviewToFront(self.pageControl)
                self.pageControl.numberOfPages = self.pictures.count
                self.pageControl.currentPage = 0
                self.startTimer()
            }
        }
    }
    
    /// 默认图
    open var placeholderImage: UIImage?
    
    /// 点击图片回调 从0开始
    open var didTapAtIndexHandler: (( _: Int) -> Void)?
    
    // 滚动方向
    open var direction: AdScrollViewRollingDirection = .left {
        willSet {
            switch newValue {
            case .left, .top:
                self.pageControl.currentPage = 0
                self.index = 0
            case .right, .bottom:
                self.pageControl.currentPage = self.pictures.count - 1
                self.index = self.pictures.count - 1
            }
        }
    }
    
    /// 设置图片的ContentMode
    open var imageContentMode: UIView.ContentMode?
    
    /// 自定义 cell 的回调
    open var customCellHandle: AdScrollViewCustomCellHandle?
    
    /// 如果需要自定义 AnyClass cell 需要调用下面方法
    ///
    /// - Parameters:
    ///   - cellClass: [UICollectionViewCell.self]
    ///   - identifiers: [identifier]
    ///   - customCellHandle: cellForItemAt 回调
    open func register(_ cellClass: [Swift.AnyClass?], identifiers: [String], customCellHandle: @escaping AdScrollViewCustomCellHandle) {
        self.customCellHandle = customCellHandle
        for (index, identifier) in identifiers.enumerated() {
            self.collectionView.register(cellClass[index], forCellWithReuseIdentifier: identifier)
        }
    }
    
    /// pageControl的对齐方式
    open var pageControlStyle: AdPageControlStyle = .center {
        willSet {
            guard self.pictures.count > 0 else {
                return
            }
            let pointSize: CGSize = self.pageControl.size(forNumberOfPages: self.pictures.count)
            let page_x: CGFloat = (self.pageControl.bounds.size.width - pointSize.width) / 2
            switch newValue {
            case .left:
                self.pageControl.frame = CGRect(x: -page_x + 10, y: self.frame.size.height - 20, width: self.pageControl.bounds.size.width, height: self.pageControl.bounds.size.height)
            case .right:
                self.pageControl.frame = CGRect(x: page_x - 10, y: self.frame.size.height - 20, width: self.pageControl.bounds.size.width, height: self.pageControl.bounds.size.height)
            case .center:
                self.pageControl.frame = CGRect(x: 0, y: self.frame.size.height - 20, width: self.pageControl.bounds.size.width, height: self.pageControl.bounds.size.height)
            }
        }
    }
    
    var datas: [String]? {
        var firstIndex = 0
        var secondIndex = 0
        var thirdIndex = 0
        switch pictures.count {
        case 0:
            return []
        case 1:
            break
        default:
            firstIndex = (self.index - 1) < 0 ? pictures.count - 1 : self.index - 1
            secondIndex = self.index
            thirdIndex = (self.index + 1) > pictures.count - 1 ? 0  : self.index + 1
        }
        
        return [pictures[firstIndex], pictures[secondIndex], pictures[thirdIndex]]
    }
    
    internal var index: Int = 0
    
    internal var timer: Timer?
    
    /// default is 2.0f, 如果小于0.5不能自动播放
    open var autoScrollDelay: TimeInterval = 3
    
    internal lazy var contentOffset: CGFloat = {
        switch self.direction {
        case .left, .right:
            return self.collectionView.contentOffset.x
        case .top, .bottom:
            return self.collectionView.contentOffset.y
        }
    }()
    
    internal lazy var scrollPosition: UICollectionView.ScrollPosition = {
        switch self.direction {
        case .left:
            return UICollectionView.ScrollPosition.left
        case .right:
            return UICollectionView.ScrollPosition.right
        case .top:
            return UICollectionView.ScrollPosition.top
        case .bottom:
            return UICollectionView.ScrollPosition.bottom
        }
    }()
    
    /// PageControl
    open lazy var pageControl: AdPageControl = {
        let pageContrl: AdPageControl = AdPageControl(frame: CGRect(x: 0, y: self.frame.height - 20, width: self.frame.size.width, height: 20))
        pageContrl.backgroundColor = UIColor.clear
        pageContrl.numberOfPages = self.pictures.count
        pageContrl.pageIndicatorTintColor = UIColor.gray // 未选中的颜色
        pageContrl.currentPageIndicatorTintColor = UIColor.orange // 选中的颜色
        pageContrl.currentPage = 0
        self.addSubview(pageContrl)
        return pageContrl
    }()
    
    internal lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = self.frame.size
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        switch self.direction {
        case .left, .right:
            layout.scrollDirection = .horizontal
        case .top, .bottom:
            layout.scrollDirection = .vertical
        }
        
        let collectionView: UICollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height), collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(AdScrollViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.dataSource = self
        collectionView.delegate = self
        self.addSubview(collectionView)
        return collectionView
    }()
    
    /// 添加定时器
    internal func startTimer() {
        self.stopTimer()
        if self.autoScrollDelay >= 0.5 {
            self.timer = Timer.scheduledTimer(timeInterval: self.autoScrollDelay, target: self, selector: #selector(timerHandle), userInfo: nil, repeats: true)
            RunLoop.main.add(self.timer!, forMode: RunLoop.Mode.common)
        }
    }
    
    /// 关闭定时器
    internal func stopTimer() {
        if let _ = timer?.isValid {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc internal func timerHandle() {
        var item: Int = 0
        switch self.direction {
        case .left, .bottom:
            item = 2
        case .top, .right:
            item = 0
        }
        
        self.collectionView.scrollToItem(at: IndexPath(item: item, section: 0), at: self.scrollPosition, animated: true)
    }
    
    public convenience init(frame: CGRect, pictrues: [String]?) {
        self.init(frame: frame)
        if pictrues != nil {
            self.pictures = pictrues!
        }
        self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: self.scrollPosition, animated: false)
        self.bringSubviewToFront(self.pageControl)
        self.startTimer()
    }
    
    deinit {
        self.stopTimer()
    }
}

extension AdScrollView: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.stopTimer()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.startTimer()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset: CGFloat = 0
        
        switch self.direction {
        case .left, .right:
            offset = scrollView.contentOffset.x
        case .top, .bottom:
            offset = scrollView.contentOffset.y
        }
        
        if offset >= self.contentOffset * 2 {
            if self.index == self.pictures.count - 1 {
                self.index = 0
            } else {
                self.index += 1
            }
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: self.scrollPosition, animated: false)
        }
        
        if offset <= 0 {
            if self.index == 0 {
                self.index = self.pictures.count - 1
            } else {
                self.index -= 1
            }
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: self.scrollPosition, animated: false
            )
        }
        
        UIView.animate(withDuration: 0.3) {
            self.pageControl.currentPage = self.index
        }
    }
}

extension AdScrollView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.customCellHandle != nil {
            return self.customCellHandle!(collectionView, indexPath, self.datas![indexPath.item])
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! AdScrollViewCell
            if self.imageContentMode != nil {
                cell.imageView.contentMode = self.imageContentMode!
            }
            
            if self.datas != nil {
                if self.datas![indexPath.item].hasPrefix("http") {
                    let resource = ImageResource(downloadURL: URL(string: self.datas![indexPath.item])!, cacheKey: "\(self.datas![indexPath.item])")
                    cell.imageView.kf.setImage(with: resource, placeholder: self.placeholderImage, options: nil, progressBlock: nil, completionHandler: nil)
                } else {
                    cell.imageView.image = UIImage(named: self.datas![indexPath.item])
                }
            }
            
            return cell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.didTapAtIndexHandler?(self.index)
    }
}

// MARK: - 自定义cell
class AdScrollViewCell: UICollectionViewCell {
    var placeholder: String?
    var customerImage: UIImageView!
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        setupContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupContent() {
        self.imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor.white
        self.imageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(imageView)
        imageView.snp.makeConstraints{ (make) in
            make.center.equalToSuperview()
            make.width.equalTo(AdaptW(303))
            make.height.equalToSuperview()
        }
        
    }
}

/// 自定义PageControl
public class AdPageControl: UIPageControl {
    /// 设置高亮显示图片
    public var currentPageIndicatorImage: UIImage? {
        didSet {
            self.currentPageIndicatorTintColor = UIColor.clear
        }
    }
    
    /// 设置默认显示图片
    public var pageIndicatorImage: UIImage? {
        didSet {
            self.pageIndicatorTintColor = UIColor.clear
        }
    }
    
    public override var currentPage: Int {
        willSet {
            self.updateDots()
        }
    }
    
    internal func updateDots() {
        if self.currentPageIndicatorImage != nil || self.pageIndicatorImage != nil {
            for (index, dot) in self.subviews.enumerated() {
                if dot.subviews.count == 0 {
                    let imageView: UIImageView = UIImageView()
                    imageView.frame = dot.bounds
                    dot.addSubview(imageView)
                }
                
                if let imageView = dot.subviews[0] as? UIImageView {
                    imageView.image = self.currentPage == index ? self.currentPageIndicatorImage ?? UIImage() : self.pageIndicatorImage ?? UIImage()
                }
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
