//
//  ViewController.swift
//  Example
//
//  Created by yan on 2025-09-02.
//

import UIKit
import ONTOCycleView

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let imageArray = ["https://ss2.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a4b3d7085dee3d6d2293d48b252b5910/0e2442a7d933c89524cd5cd4d51373f0830200ea.jpg",
        "https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a41eb338dd33c895a62bcb3bb72e47c2/5fdf8db1cb134954a2192ccb524e9258d1094a1e.jpg",
        "http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg"
        ]
        let localImageArray = ["h1.jpg", "h2.jpg", "h3.jpg", "h4.jpg"]
        let titleArray = ["1234", "4444", "66666"]
        
        // DEMO1
        let view1 = ONTOCycleView(frame: CGRect(x: 0, y: 80, width: view.bounds.width, height: 180))
        view1.delegate = self
        view1.infiniteLoop = true
        view1.pageControlStyle = .default
        view1.imagePathArray = localImageArray
        view.addSubview(view1)
        
        // DEMO2
        let view2 = ONTOCycleView(frame: CGRect(x: 0, y: 280, width: view.bounds.width, height: 180))
        view2.placeholderImage = UIImage(named: "placeholder")
        view2.dataSource = titleArray
        view2.register(TextCell.self)
        view2.currentDotColor = .blue
        view.addSubview(view2)
        
        // DEMO3
        let view3 = ONTOCycleView(frame: CGRect(x: 0, y: 480, width: view.bounds.width, height: 180))
//        view3.delegate = self
        view3.placeholderImage = UIImage(named: "placeholder")
        view3.dotImageSelected = UIImage(named: "pagecontrol_sel")
        view3.dotImageNormal = UIImage(named: "pagecontrol_normal")
        view3.pageControlAlignment = .right(offset: -10)
        view3.imagePathArray = imageArray
        view3.scrollDirection = .vertical
        view.addSubview(view3)
        
    }

}

extension ViewController: ONTOCycleViewDelegate {
    
}

class TextCell: ONTOCycleCell {
    func updateUI(model: Any) {
        guard let title = model as? String else { return }
        titleLab.text = title
    }
    
    private lazy var titleLab: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.red
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLab)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        titleLab.frame = bounds
    }
}
