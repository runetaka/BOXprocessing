//
//  JobListTableViewCell.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/12/21.
//

import UIKit

class JobListTableViewCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var companyName: UILabel!
    
    @IBOutlet weak var area: UILabel!
    
    @IBOutlet weak var salary: UILabel!
    
    @IBOutlet weak var companyImageView: UIImageView!
        
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        companyImageView.layer.borderWidth = 0.5
        companyImageView.layer.borderColor = UIColor.darkGray.cgColor
        shadowView.layer.cornerRadius = 10
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
