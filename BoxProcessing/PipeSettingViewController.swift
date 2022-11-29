//
//  PipeSettingViewController.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/11/28.
//

import UIKit
import PKHUD

class PipeSettingViewController: UIViewController {

    
    let Pipes = ["G16","G22", "G28" ,"G36","G42","G54","G70","G82","G92","G104","C19","C25","C31","C39","C51","C63","C76"]
    let CPipe = ["C19","C25","C31","C39","C51","C63","C76"]
    let defaultHoleList =
    ["G16":21,"G22":27, "G28":34 ,"G36":42,"G42":48,"G54":60,"G70":75,"G82":88,"G92":100,"G104":113,"C19":19,"C25":25,"C31":31,"C39":39,"C51":51,"C63":63,"C76":76]

    var userSetting : [String:Float] = [:]
    var isLoaded = false
    var selectedIndex : IndexPath?
    
    var offset: CGPoint? //keyboard


    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "StaticTableViewCell", bundle: nil), forCellReuseIdentifier: "staticCell")
        tableView.register(
            UINib(nibName: "RailLengthHeaderView", bundle: nil),
            forHeaderFooterViewReuseIdentifier: "railHeader")

        tableView.delegate = self
        tableView.dataSource = self
        let dismissButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action:  #selector(self.tappedDismissButton))
        
        let saveButton = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(saveUserDefaults))
        let resetButton = UIBarButtonItem(title: "リセット", style: .done, target: self, action: #selector(tappedResetButton))
        resetButton.tintColor = .red
        self.navigationItem.rightBarButtonItems = [resetButton,saveButton]
        self.navigationItem.leftBarButtonItem = dismissButton
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if let setting = UserDefaults.standard.dictionary(forKey: "pipe") as? [String:Float]{
            self.userSetting = setting
            self.isLoaded = true
        }else{
            self.isLoaded = true
        }
        
    }
    @objc func saveUserDefaults(){
        
        UserDefaults.standard.setValue(userSetting, forKey: "pipe")
        
        HUD.flash(.labeledSuccess(title: "保存しました", subtitle: nil),delay: 0.5)
    }
    
    
    
    @objc func tappedDismissButton(){
        if let setting = UserDefaults.standard.dictionary(forKey: "pipe") as? [String:Float] {
            if setting != self.userSetting && isLoaded{
                let alert = UIAlertController(title: "変更が保存されていません", message: "保存しますか？", preferredStyle: .alert)
                let ok = UIAlertAction(title: "保存する", style: .default) { action in
                    self.saveUserDefaults()
                    self.dismiss(animated: true)
                }
                let cancel = UIAlertAction(title: "保存しない", style: .destructive) { action in
                    self.dismiss(animated: true)
                }
                alert.addAction(ok)
                alert.addAction(cancel)
                self.present(alert, animated: true)
            }else if !(isLoaded){
                
            }else{
                //保存されている場合
                self.dismiss(animated: true)

            }
        }else if !(self.userSetting.isEmpty){
            //ユーザーデフォルトにないが、変更があり、セーブされていない場合
            let alert = UIAlertController(title: "変更が保存されていません", message: "保存しますか？", preferredStyle: .alert)
            let ok = UIAlertAction(title: "保存する", style: .default) { action in
                self.saveUserDefaults()
                self.dismiss(animated: true)
            }
            let cancel = UIAlertAction(title: "保存しない", style: .destructive) { action in
                self.dismiss(animated: true)
            }
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true)
        }else{
            self.dismiss(animated: true)
        }
    }
    
    
    @objc func tappedResetButton(){
        
        let alert = UIAlertController(title: "値を初期化します", message: "よろしいですか?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "初期化", style: .destructive) { action in
            UserDefaults.standard.removeObject(forKey: "pipe")
            self.tableView.reloadSections(.init(integer: 0), with: .fade)
            self.userSetting = [:]
        }
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true)
        
    }
    
    @objc func done(){
        if let selectedInedx = selectedIndex{
            tableView.deselectRow(at: selectedInedx, animated: true)
            if let cell = tableView.cellForRow(at: selectedInedx) as? StaticTableViewCell{
                cell.inputTextField.isHidden = true
                cell.numberLabel.isHidden = false
                if let editedValue = cell.inputTextField.text,!(editedValue.isEmpty),let name = cell.nameLabel.text{
                    cell.numberLabel.text = editedValue
                    userSetting[name] = Float(editedValue)
                }
                
            }
        }
        self.view.endEditing(true)
    }
    @objc func cancel(){
        if let selectedInedx = selectedIndex{
            if let cell = tableView.cellForRow(at: selectedInedx) as? StaticTableViewCell{
                cell.inputTextField.isHidden = true
                cell.numberLabel.isHidden = false
                cell.inputTextField.text = cell.numberLabel.text
            }
        }
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
      
           offset = tableView.contentOffset
           if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
               tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
               tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
               UIView.animate(withDuration: 0.2, animations: {
                   self.view.layoutIfNeeded()
               })
           }
       }

       @objc func keyboardWillHide(_ notification: NSNotification) {
         
           UIView.animate(withDuration: 0.2, animations: {
               if let unwrappedOffset = self.offset {
                   self.tableView.contentOffset = unwrappedOffset
               }
               self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
               self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
           })
           
       }
}

extension PipeSettingViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
        case 0:
            return Pipes.count
        case 1:
            return CPipe.count
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "staticCell", for: indexPath) as! StaticTableViewCell
                if indexPath.row < Pipes.count{
                    let pipeName = Pipes[indexPath.row]
                    cell.nameLabel.text = pipeName
                    if let setting = UserDefaults.standard.dictionary(forKey: "pipe") as? [String:Float]{
                        if let userG = setting[pipeName]{
                            cell.numberLabel.text = "\(userG)"
                            cell.inputTextField.text = "\(userG)"
                        }else{
                            if let diameter = defaultHoleList[pipeName]{
                                cell.numberLabel.text = "\(diameter)"
                                cell.inputTextField.text = "\(diameter)"
                            }
                        }
                    }else{
                        if let diameter = defaultHoleList[pipeName]{

                            cell.numberLabel.text = "\(diameter)"
                            cell.inputTextField.text = "\(diameter)"
                        }
                    }
                }
                return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath

        let cell = tableView.cellForRow(at: indexPath) as! StaticTableViewCell
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let cancelItem = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(cancel))
        let doneItem = UIBarButtonItem(title: "決定", style: .done, target: self,action: #selector(done))
        cell.inputTextField.inputAccessoryView = toolbar
        let label = UILabel()
        label.text = self.Pipes[indexPath.row]
        let titleItem = UIBarButtonItem(customView: label)
        cell.inputTextField.isHidden = false
        cell.numberLabel.isHidden = true
        toolbar.setItems([cancelItem,spacelItem,titleItem,spacelItem,doneItem], animated: true)
        cell.inputTextField.becomeFirstResponder()
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "railHeader") as! RailLengthHeaderView
        return headerFooterView

    }
    
}
