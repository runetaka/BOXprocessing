//
//  PipeSettingViewController.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/11/28.
//

import UIKit
import PKHUD

class PipeSettingViewController: UIViewController {

    
    let GPipe = ["G16","G22", "G28" ,"G36","G42","G54","G70","G82","G92","G104"]
    let CPipe = ["C19","C25","C31","C39","C51","C63","C76"]
    let holeList =
    ["G16":21,"G22":27, "G28":34 ,"G36":42,"G42":48,"G54":60,"G70":75,"G82":88,"G92":100,"G104":113,"C19":19,"C25":25,"C31":31,"C39":39,"C51":51,"C63":63,"C76":76]

    var userSetting : [String:Float]?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "StaticTableViewCell", bundle: nil), forCellReuseIdentifier: "staticCell")
        tableView.delegate = self
        tableView.dataSource = self
        let dismissButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action:  #selector(self.tappedDismissButton))
        
        let saveButton = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(saveUserDefaults))
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.leftBarButtonItem = dismissButton
    }
    
    @objc func saveUserDefaults(){
        if let userSetting = userSetting {
            UserDefaults.standard.setValue(userSetting, forKey: "pipe")
            HUD.flash(.success)
        }
    }
    
    @objc func tappedDismissButton(){
        self.dismiss(animated: true)
    }


}

extension PipeSettingViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
        case 0:
            return GPipe.count
        case 1:
            return CPipe.count
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "staticCell", for: indexPath) as! StaticTableViewCell
        
            switch(indexPath.section){
            case 0:
                if indexPath.row < GPipe.count{
                    let pipeName = GPipe[indexPath.row]
                    cell.nameLabel.text = pipeName
                    if let setting = UserDefaults.standard.dictionary(forKey: "pipe") as? [String:Float]{
                        if let userG = setting[pipeName]{
                            cell.numberLabel.text = "\(userG)"
                        }else{
                            if let diameter = holeList[pipeName]{
                            cell.numberLabel.text = "\(diameter)"
                            }
                        }
                    }else{
                        if let diameter = holeList[pipeName]{

                        cell.numberLabel.text = "\(diameter)"
                        }
                    }
                }
                return cell
            case 1:
                if indexPath.row < CPipe.count{
                    let pipeName = CPipe[indexPath.row]

                    cell.nameLabel.text = pipeName
                    if let setting = UserDefaults.standard.dictionary(forKey: "pipe") as? [String:Float]{
                        if let userC = setting[pipeName]{
                            cell.numberLabel.text = "\(userC)"
                        }else{
                            if let diameter = holeList[pipeName]{
                                cell.numberLabel.text = "\(diameter)"
                            }
                        }
                    }else{
                        if let diameter = holeList[pipeName]{
                            cell.numberLabel.text = "\(diameter)"
                        }
                    }
                }
                return cell
                
            default:
                return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! StaticTableViewCell
        cell.inputTextField.becomeFirstResponder()
        
    }
    
}
