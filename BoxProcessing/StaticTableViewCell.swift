//
//  StaticTableViewCell.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/09/10.
//

import UIKit

class StaticTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var mmLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        numberLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.inputTextField.text = nil
        self.numberLabel.text = nil
    }
    
}
