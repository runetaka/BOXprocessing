//
//  PipeSettingViewController.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/11/28.
//

import UIKit
import PKHUD

class PipeSettingViewController: UIViewController {

    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    let Pipes = ["G16","G22", "G28" ,"G36","G42","G54","G70","G82","G92","G104","C19","C25","C31","C39","C51","C63","C75"]
    let CPipe = ["C19","C25","C31","C39","C51","C63","C75"]
    
    let SGP = ["10A","15A","20A","25A","32A","40A","50A","65A","80A","90A","100A","125A","150A","175A","200A"]
    let HIVP = ["13A","16A","20A","25A"]
    
    let defaultVPDiameters = ["13A":18,"16A":22,"20A":26,"25A":32]
    let defaultSGPDiameters :[String:Float] = ["10A":17.3,"15A":21.7,"20A":27.2,"25A":34,"32A":42.7,"40A":48.6,"50A":60.5,"65A":76.3,"80A":89.1,"90A":101.6,"100A":114.3,"125A":139.8,"150A":165.2,"175A":190.7,"200A":216.3]
    let defaultHoleList =
    ["G16":21,"G22":27, "G28":34 ,"G36":42,"G42":48,"G54":60,"G70":75,"G82":88,"G92":100,"G104":113,"C19":19,"C25":25,"C31":31,"C39":39,"C51":51,"C63":63,"C75":75]

    var userSettingSGP : [String:Float] = [:]
    var userSettingVP : [String:Float] = [:]
    var isLoaded = false
    var selectedIndex : IndexPath?
    
    var offset: CGPoint? //keyboard

    var selectedPipeType = "SGP"

    @IBOutlet weak var uBoltsView: UIView!
    @IBOutlet weak var uBoltsTextField: UITextField!
    @IBOutlet weak var pipeTypeLabel: UILabel!
    @IBOutlet weak var pipeTypeMenu: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.addGestures()
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
        
        if let settingSGP = UserDefaults.standard.dictionary(forKey: "SGP") as? [String:Float]{
            self.userSettingSGP = settingSGP
            self.setupParameters(userSetting: settingSGP)
            self.isLoaded = true
        }else{
            self.isLoaded = true
        }
        
        if let settingVP = UserDefaults.standard.dictionary(forKey: "VP") as? [String:Float]{
            self.userSettingVP = settingVP
            self.isLoaded = true
        }else{
            self.isLoaded = true
        }
        
        
    }
    
    
    private func addGestures(){
        let uBoltsGesture = UITapGestureRecognizer(target: self, action: #selector(tappedUBoltsView))
        uBoltsView.addGestureRecognizer(uBoltsGesture)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedPullDownMenu))
        pipeTypeMenu.addGestureRecognizer(gesture)
        
        
    }
    
    private func setupParameters(userSetting:[String:Float]){
        let uBoltsDiameter = userSetting["uBolts"] ?? 12
            self.uBoltsTextField.text = "\(uBoltsDiameter)"
    }
    
    @objc func saveUserDefaults(){
        if let selectedIndex = self.selectedIndex{
            self.done()
        }
        if let uBoltsDiameter = Float(self.uBoltsTextField.text ?? "12"){
            self.userSettingSGP["uBolts"] = uBoltsDiameter
            self.userSettingVP["uBolts"] = uBoltsDiameter
        }
            UserDefaults.standard.setValue(userSettingSGP, forKey: "SGP")
            UserDefaults.standard.setValue(userSettingVP, forKey: "VP")
        
        
        HUD.flash(.labeledSuccess(title: "保存しました", subtitle: nil),delay: 0.5)
    }
    @objc func tappedUBoltsView(){
        uBoltsTextField.becomeFirstResponder()
    }
    @objc func tappedPullDownMenu(){
        let sheet = UIAlertController(title: "計算方法", message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "SGP", style: .default) { action in
            print("端から中心")
            self.pipeTypeLabel.text = "SGP"
            self.done()
            if self.selectedPipeType != "SGP"{
                self.selectedPipeType = "SGP"
                self.tableView.reloadData()
            }
            sheet.dismiss(animated: true)
            
        }
        let action2 = UIAlertAction(title: "HIVP", style: .default) { action in
            self.pipeTypeLabel.text = "HIVP"
            self.done()
            if self.selectedPipeType != "HIVP"{
                self.selectedPipeType = "HIVP"
                self.tableView.reloadData()
            }
            sheet.dismiss(animated: true)
        }
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel)
        sheet.addAction(action1)
        sheet.addAction(action2)
        sheet.addAction(cancel)
        self.present(sheet, animated: true)
    }
    
    
    
    @objc func tappedDismissButton(){
        //sgpある
            //vpある
            //vpない
        //ない
            //vpある
            //vpない
        
        let settingSGP = UserDefaults.standard.dictionary(forKey: "SGP") as? [String:Float] ?? [:]
        let settingVP = UserDefaults.standard.dictionary(forKey: "VP") as? [String:Float] ?? [:]
            //SGPの設定
            if (settingSGP != self.userSettingSGP || settingVP != self.userSettingVP) && isLoaded{
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
//        }else if !(self.userSettingSGP.isEmpty){
//            //ユーザーデフォルトにないが、変更があり、セーブされていない場合
//            let alert = UIAlertController(title: "変更が保存されていません", message: "保存しますか？", preferredStyle: .alert)
//            let ok = UIAlertAction(title: "保存する", style: .default) { action in
//                self.saveUserDefaults()
//                self.dismiss(animated: true)
//            }
//            let cancel = UIAlertAction(title: "保存しない", style: .destructive) { action in
//                self.dismiss(animated: true)
//            }
//            alert.addAction(ok)
//            alert.addAction(cancel)
//            self.present(alert, animated: true)
//        }else{
//            self.dismiss(animated: true)
//        }
    }
    
    
    @objc func tappedResetButton(){
        
        let alert = UIAlertController(title: "値を初期化します", message: "よろしいですか?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "初期化", style: .destructive) { action in
            if self.selectedPipeType == "SGP"{
                UserDefaults.standard.removeObject(forKey: "SGP")
            }else{
                UserDefaults.standard.removeObject(forKey: "VP")
            }
            self.setupParameters(userSetting: [:])
            self.userSettingSGP = [:]
            self.userSettingVP = [:]
            self.tableView.reloadSections(.init(integer: 0), with: .fade)

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
                    if self.selectedPipeType == "SGP"{
                        userSettingSGP[name] = Float(editedValue)
                    }else{
                        userSettingVP[name] = Float(editedValue)
                    }
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

extension PipeSettingViewController:UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
        case 0:
            if selectedPipeType == "SGP"{
                return SGP.count
            }else{
                return HIVP.count
            }
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "staticCell", for: indexPath) as! StaticTableViewCell
        cell.inputTextField.delegate = self
        if selectedPipeType == "SGP"{
            if indexPath.row < SGP.count{
                let pipeName = SGP[indexPath.row]
                cell.nameLabel.text = pipeName
                if !(self.userSettingSGP.isEmpty){
                    if let userG = userSettingSGP[pipeName]{
                        //userSettingある場合
                        cell.numberLabel.text = "\(userG)"
//                        cell.inputTextField.text = "\(userG)"
                        cell.inputTextField.placeholder = "\(userG)"
                    }else{
                        //そのパイプの設定がない場合
                            if let diameter = defaultSGPDiameters[pipeName]{
                                cell.numberLabel.text = "\(diameter)"
//                                cell.inputTextField.text = "\(diameter)"
                                cell.inputTextField.placeholder = "\(diameter)"
                            }
                    }
                }else{
                    //userSetting自体がない場合
                    if let diameter = defaultSGPDiameters[pipeName]{
                        
                        cell.numberLabel.text = "\(diameter)"
//                        cell.inputTextField.text = "\(diameter)"
                        cell.inputTextField.placeholder = "\(diameter)"

                    }
                }
            }
        }else{
            if indexPath.row < HIVP.count{
                let pipeName = HIVP[indexPath.row]
                cell.nameLabel.text = pipeName
                if let setting = UserDefaults.standard.dictionary(forKey: "VP") as? [String:Float]{
                    if let userG = setting[pipeName]{
                        //userSettingある場合
                        cell.numberLabel.text = "\(userG)"
                        cell.inputTextField.placeholder = "\(userG)"
                    }else{
                        //そのパイプの設定がない場合
                            if let diameter = defaultVPDiameters[pipeName]{
                                cell.numberLabel.text = "\(diameter)"
                                cell.inputTextField.placeholder = "\(diameter)"

                            }
                    }
                }else{
                    //userSetting自体がない場合
                    if let diameter = defaultVPDiameters[pipeName]{
                        
                        cell.numberLabel.text = "\(diameter)"
                        cell.inputTextField.placeholder = "\(diameter)"

                    }
                }
            }
        }
        scrollViewHeight.constant = tableView.contentSize.height + 200

                return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.done()
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
