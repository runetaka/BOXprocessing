//
//  SettingViewController.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/09/25.
//

import Foundation
import UIKit

class SettingViewController:UIViewController, UITableViewDelegate{
   
    @IBOutlet weak var settingTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingTableView.delegate = self
        self.setupNavigaitonBar(color: .white)
        let label = UILabel()
        label.text = "設定"
        self.navigationController?.navigationItem.leftBarButtonItem =  UIBarButtonItem(customView: label)
        
    }

}


