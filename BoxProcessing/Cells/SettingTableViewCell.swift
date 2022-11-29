//
//  SettingTableViewCell.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/11/29.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

    @IBOutlet weak var settingImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
