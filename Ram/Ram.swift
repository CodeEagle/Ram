//
//  Ram.swift
//  RamsWork
//
//  Created by LawLincoln on 2016/9/22.
//  Copyright © 2016年 LawLincoln. All rights reserved.
//
import Foundation
/// Ram
//MARK:- Ram
final public class Ram: NSObject {
    
    static var shared: Ram! = Ram()
    class func happyEnd() { shared = nil }
    
    public class var pageControl: UIPageControl {
        get { return Ram.shared.pageControl }
        set(val) { Ram.shared.pageControl = val }
    }
    
    public class func handle(work items: [Work], skip button: UIButton = Ram.defaultSkipButton, skipButtonAtEnd: Bool = true, complete: @escaping () -> Void = { _ in }) {
        Ram.shared.handle(work: items, skip: button, skipButtonAtEnd: skipButtonAtEnd, complete: complete)
    }
    
    internal var skipButton: UIButton!
    internal var works: [Work] = []
    private var end: (() -> Void)!
    internal lazy var wrap = UIView(frame: UIScreen.main.bounds)
    internal var pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 20, width: UIScreen.main.bounds.width, height: 5)) {
        didSet {
            oldValue.removeFromSuperview()
            wrap.addSubview(pageControl)
        }
    }
    private lazy var scrollView = UIScrollView(frame: UIScreen.main.bounds)
    internal lazy var layerOdd = CALayer()
    internal lazy var layerEven = CALayer()
    internal func imageFromCache(at index: Int) -> CGImage? { return works[index].image?.cgImage }
    private override init() {
        super.init()
        layerOdd.speed = 999
        layerEven.speed = 999
        layerOdd.frame = scrollView.bounds
        layerEven.frame = scrollView.bounds.offsetBy(dx: scrollView.bounds.width, dy: 0)
        scrollView.layer.addSublayer(layerOdd)
        scrollView.layer.addSublayer(layerEven)
        scrollView.backgroundColor = UIColor.white
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        pageControl.currentPageIndicatorTintColor = UIColor.darkGray
        pageControl.pageIndicatorTintColor = UIColor.lightGray
    }
    
    func handle(work items: [Work], skip button: UIButton = Ram.defaultSkipButton, skipButtonAtEnd: Bool = true, complete: @escaping () -> Void = { _ in }) {
        works = items
        layerOdd.contents = works[safe: 0]?.image?.cgImage
        layerEven.contents = works[safe: 1]?.image?.cgImage
        skipButton = button
        pageControl.numberOfPages = items.count
        pageControl.currentPage = 0
        end = complete
        scrollView.contentSize = CGSize(width: scrollView.bounds.width * CGFloat(works.count), height: scrollView.bounds.height)
        let win = UIApplication.topMostViewController.view
        wrap.addSubview(scrollView)
        wrap.addSubview(pageControl)
        skipButtonAtEnd ? scrollView.addSubview(skipButton) : wrap.addSubview(skipButton)
        win?.addSubview(wrap)
        skipButton.addTarget(self, action: #selector(Ram.done), for: .touchUpInside)
    }
    
    @objc private func done() {
        wrap.fadeOut()
        end()
        Ram.happyEnd()
    }
    
    public class var defaultSkipButton: UIButton {
        let width: CGFloat = 220
        let height: CGFloat = 40
        let x = (UIScreen.main.bounds.width - width) / 2
        let y = UIScreen.main.bounds.height - height - 30
        let frame = CGRect(x: x, y: y,  width: width, height: height)
        let b = UIButton(frame: frame)
        let bgimage = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAAXNSR0IArs4c6QAAAA1JREFUCB1jSDmR8h8ABbQCkJlxyIgAAAAASUVORK5CYII="
        let dataDecoded = NSData(base64Encoded: bgimage, options: .ignoreUnknownCharacters)
        if let d = dataDecoded as? Data {
            let bg = UIImage(data: d)
            b.setBackgroundImage(bg, for: .normal)
        }
        b.layer.masksToBounds = true
        b.layer.cornerRadius = 20
        b.layer.borderWidth = 0.5
        b.layer.borderColor = UIColor.lightGray.cgColor
        b.setTitle("Done", for: .normal)
        return b
    }
    
    public struct Work {
        let mode: UIViewContentMode
        var image: UIImage? { return UIImage(contentsOfFile: imagePath) }
        private let imagePath: String
        public init(item i: String, contentMode m: UIViewContentMode = .scaleAspectFit) {
            imagePath = i
            mode = m
        }
    }
}
// MARK: - UIScrollViewDelegate
extension Ram: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        if x < 0 { return }
        let count = works.count
        let width = scrollView.bounds.width
        if x > CGFloat(count - 1) * width { return }
        pageControl.currentPage = Int(ceil(x / width))
        let oddMinX = layerOdd.frame.minX
        let oddMaxX = layerOdd.frame.maxX
        let evenMinX = layerEven.frame.minX
        let evenMaxX = layerEven.frame.maxX
        let loadIndex = pageControl.currentPage
        if oddMinX < x && x < oddMaxX {//next
            if evenMinX != oddMaxX {
                var f = layerEven.frame
                f.origin.x = oddMaxX
                layerEven.frame = f
                guard let item =  works[safe: loadIndex] else { return }
                layerEven.contents = imageFromCache(at: loadIndex)
                layerEven.contentsGravity = item.mode.forLayer
            }
        } else if evenMinX < x && x < evenMaxX {//next
            if oddMinX != evenMaxX {
                var f = layerOdd.frame
                f.origin.x = evenMaxX
                layerOdd.frame = f
                guard let item =  works[safe: loadIndex] else { return }
                layerOdd.contents = imageFromCache(at: loadIndex)
                layerOdd.contentsGravity = item.mode.forLayer
            }
        } else if evenMaxX <= oddMinX && x < evenMinX {
            var f = layerOdd.frame
            f.origin.x = evenMinX - width
            layerOdd.frame = f
            guard let item =  works[safe: loadIndex - 1] else { return }
            layerOdd.contents = imageFromCache(at: loadIndex - 1)
            layerOdd.contentsGravity = item.mode.forLayer
        } else if oddMaxX <= evenMinX && x < oddMinX {
            
            var f = layerEven.frame
            f.origin.x = oddMinX - width
            layerEven.frame = f
            guard let item =  works[safe: loadIndex - 1] else { return }
            layerEven.contents = imageFromCache(at: loadIndex - 1)
            layerEven.contentsGravity = item.mode.forLayer
        }
    }
}
private extension UIViewContentMode {
    var forLayer: String {
        switch self {
        case .center: return "center"
        case .top: return "top"
        case .left: return "left"
        case .bottom: return "bottom"
        case .right: return "right"
        case .topLeft: return "topLeft"
        case .topRight: return "topRight"
        case .bottomLeft: return "bottomLeft"
        case .bottomRight: return "bottomRight"
        case .scaleToFill, .redraw: return "reize"
        case .scaleAspectFit: return "resizeAspect"
        case .scaleAspectFill: return "resizeAspectFill"
        }
    }
}
private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
private extension UIView {
    func fadeOut() {
        let animations = {
            self.layer.opacity = 0
            self.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.2)
        }
        UIView.animate(withDuration: 0.2,
                       animations: animations,
                       completion: {[weak self] (_) in self?.removeFromSuperview() })
    }
}
private extension UIApplication {
    static var topMostViewController: UIViewController {
        var root = UIApplication.shared.windows.first?.rootViewController
        while(root == nil) { root = UIApplication.shared.windows.first?.rootViewController }
        var topController: UIViewController? = root
        while (topController?.presentedViewController != nil) { topController = topController?.presentedViewController }
        return topController!
    }
}
