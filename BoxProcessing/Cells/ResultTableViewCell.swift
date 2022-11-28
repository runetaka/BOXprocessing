//
//  ResultTableViewCell.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/11/22.
//

import Foundation
import UIKit


class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var xpositionLabel: UILabel!
    
    @IBOutlet weak var ypositionLabel: UILabel!
    
    override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
        
}

override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
}

}
