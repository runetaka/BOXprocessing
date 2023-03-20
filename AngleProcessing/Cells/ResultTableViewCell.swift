//
//  ResultTableViewCell.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/11/22.
//

import Foundation
import UIKit


protocol ResultTableViewCellDelegate{
    func changeDisplayLabel(index:Int)
}

class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var xpositionLabel: UILabel!
    
    @IBOutlet weak var ypositionLabel: UILabel!
    
    @IBOutlet weak var xmmLabel: UILabel!
    @IBOutlet weak var ymmLabel: UILabel!
    @IBOutlet weak var xShadowView: UIView!
    @IBOutlet weak var yShadowView: UIView!
    
    @IBOutlet weak var xEyeImage: UIImageView!
    
    @IBOutlet weak var yEyeImage: UIImageView!
    
    var delegate : ResultTableViewCellDelegate?
    
    override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
        xShadowView.layer.cornerRadius = 5
        xShadowView.layer.shadowColor = UIColor.black.cgColor
        xShadowView.layer.shadowOpacity = 0.15
        xShadowView.layer.shadowRadius = 10
        xShadowView.layer.shadowOffset = .zero
        yShadowView.layer.cornerRadius = 5
        yShadowView.layer.shadowColor = UIColor.black.cgColor
        yShadowView.layer.shadowOpacity = 0.15
        yShadowView.layer.shadowRadius = 10
        yShadowView.layer.shadowOffset = .zero
        let xGesture = UITapGestureRecognizer(target: self, action: #selector(changeDisplayLabelX))
        xShadowView.addGestureRecognizer(xGesture)
        
        let yGesture = UITapGestureRecognizer(target: self, action: #selector(changeDisplayLabelY))
        yShadowView.addGestureRecognizer(yGesture)
        
        
}
    
    @objc func changeDisplayLabelX(){
        animateButton(view: xShadowView)
        self.delegate?.changeDisplayLabel(index: xShadowView.tag)
    }
    
    @objc func changeDisplayLabelY(){
        animateButton(view: yShadowView)
        self.delegate?.changeDisplayLabel(index: yShadowView.tag)
    }
    
    func animateButton(view:UIView){
        UIView.animate(withDuration: 0.3, delay: 0, animations: { view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)}) { res in
            view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        
    }


override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
}

}
