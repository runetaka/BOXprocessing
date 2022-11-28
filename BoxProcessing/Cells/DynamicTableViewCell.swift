//
//  DynamicTableViewCell.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/09/11.
//

import UIKit

class DynamicTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var mmLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    var diameter:Diameter = .init(type: 0, kind: "厚鋼")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        shadowView.layer.cornerRadius = 5
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.15
        shadowView.layer.shadowRadius = 10
        shadowView.layer.shadowOffset = .zero
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
