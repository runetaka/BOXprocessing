//
//  ResultTableViewHeader.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/11/22.
//

import UIKit

class ResultTableViewHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var xLabel: UILabel!
    
    @IBOutlet weak var yLabel: UILabel!
    
    func setupTitle(){
        let underLineAttirbute:[NSAttributedString.Key:Any] = [
            .font: UIFont.boldSystemFont(ofSize:22.0),
            NSAttributedString.Key.underlineStyle:NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.underlineColor:UIColor.red
        ]
        let underLineAttirbuteY:[NSAttributedString.Key:Any] = [
            .font: UIFont.boldSystemFont(ofSize:22.0),
            NSAttributedString.Key.underlineStyle:NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.underlineColor:UIColor.blue
        ]
        
        let underLineAttributedStringX = NSAttributedString(string: "X座標", attributes: underLineAttirbute)
        xLabel.attributedText = underLineAttributedStringX
        
        let underLineAttributedStringY = NSAttributedString(string: "X座標", attributes: underLineAttirbuteY)
        yLabel.attributedText = underLineAttributedStringY
        
        
        
    }
    /*
     // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
         Drawing code
    }
    */

}
