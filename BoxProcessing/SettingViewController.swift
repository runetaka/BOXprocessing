//
//  SettingViewController.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/09/25.
//

import Foundation
import UIKit

class SettingViewController:UIViewController{
   
    @IBOutlet weak var settingTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingTableView.delegate = self
        self.setupNavigaitonBar(color: .white)
        settingTableView.delegate = self
        settingTableView.dataSource = self
        setNavTitle()
    }

    func setNavTitle(){
        let titleLabel = UILabel()
        titleLabel.text = "設定"
        titleLabel.adjustsFontSizeToFitWidth = true
        
        let titleBarButton = UIBarButtonItem(customView: titleLabel)
        self.navigationItem.title = "設定"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [.font : UIFont.boldSystemFont(ofSize: 26.0)]

        self.navigationItem.largeTitleDisplayMode = .automatic
    }
}

extension SettingViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! SettingTableViewCell
        switch(indexPath.row){

        case 0:
            cell.nameLabel.text = "図面設定"
            cell.settingImageView.image = UIImage(systemName: "questionmark.circle")
        case 1:
            cell.nameLabel.text = "使い方"
            cell.settingImageView.image = UIImage(systemName: "questionmark.circle")
        default:
            cell.nameLabel.text = "設定"
        }
        return cell
    }
}


