//
//  ONTOCycleCell.swift
//  ONTOCycleView
//
//  Created by yan on 2025-09-02.
//

import UIKit
import Kingfisher

@MainActor
public protocol ONTOCycleCellProtocol: AnyObject {
    func updateUI(model: Any)
}

public typealias ONTOCycleCell = UICollectionViewCell & ONTOCycleCellProtocol


public class ONTOCycleImageCell: ONTOCycleCell {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
    public func updateUI(model: Any) {
        guard let imageName = model as? String else { return }
        guard imageName != "" else { return }
        if imageName.hasPrefix("http") {
            imageView.kf.setImage(with: URL(string: imageName))
        } else {
            var image = UIImage(named: imageName)
            if image == nil  {
                image = UIImage(contentsOfFile: imageName)
            }
            imageView.image = image
        }
    }
}
