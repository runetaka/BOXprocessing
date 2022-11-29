//
//  ViewController.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/09/10.
//

import UIKit
import XLPagerTabStrip
import PKHUD
// デフォルトで継承している UIViewController を ButtonBarPagerTabStripViewController に書き換える
class InputViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var resetButton: UILabel!
    @IBOutlet weak var calculateButton: UILabel!
    @IBOutlet weak var calcButtonBottom: NSLayoutConstraint!
    @IBOutlet weak var resetButtonBottom: NSLayoutConstraint!
    var holes : [Hole] = []
    var fields :[FieldValue] = []
    let staticCellStrings = ["BOX横幅","配管隙間","レール高さ","レール余長","管種","配管数"]
    
    let mode = ["端から配管中心までの距離を計算","配管の中心の間隔を計算"]
    let pipeType = ["厚鋼","薄鋼"]
    let GPipe = ["G16","G22", "G28" ,"G36","G42","G54","G70","G82","G92","G104"]
    let CPipe = ["C19","C25","C31","C39","C51","C63","C76"]
    let holeList =
    ["G16":21,"G22":27, "G28":34 ,"G36":42,"G42":48,"G54":60,"G70":75,"G82":88,"G92":100,"G104":113,"C19":19,"C25":25,"C31":31,"C39":39,"C51":51,"C63":63,"C76":76]        
    var numberOfPipes : [Int] = Array(1..<20)
    
    var modePickerView = UIPickerView()
    var numberPickerView = UIPickerView()
    var pipeTypePickerView = UIPickerView()
    var diameterPickerView = UIPickerView()
    
    var selectedIndex :IndexPath?
    
    var boxLength : Float? // 全長
    var pipeInterval :Float? //配管間隔
    var railHeight :Float?//レール高さ
    var railEx :Float? //レール余長
    var railLength : Float = 0.0 //レール全長
    var selectedPipeType:String = "厚鋼"
    var pipeNumText:Int?
    
    var values :  [Any] = []
    
    var offset: CGPoint?
    
    
    //結果
    var results :[Result] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        values = [boxLength,pipeInterval,railHeight,railEx,selectedPipeType,pipeNumText]
        for string in staticCellStrings{
            let fieldValue = FieldValue(fieldName: string)
            fields.append(fieldValue)
        }
        setupTableView()
        calculateButton.cornerRadius = 10
        resetButton.cornerRadius = 10
        setupPicker()
        let calcGesture = UITapGestureRecognizer(target: self, action: #selector(tappedStartCalcButton))
        self.calculateButton.addGestureRecognizer(calcGesture)
        calculateButton.isUserInteractionEnabled = true
        let resetGesture = UITapGestureRecognizer(target: self, action: #selector(reset))
        self.resetButton.addGestureRecognizer(resetGesture)
        resetButton.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
                
        
    }
    
    @objc func reset(){
        let alert = UIAlertController(title: "値をリセットします", message: "よろしいですか？", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { action in
            self.boxLength = nil
            self.pipeInterval = nil
            self.railHeight = nil
            self.railEx = nil
            self.pipeNumText = nil
            self.holes = []
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel)
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true)
       
    }
    
    private func loadUserSetting(){
        
    }
    
    private func setupTableView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UINib(nibName: "StaticTableViewCell", bundle: nil), forCellReuseIdentifier: "staticCell")
        tableView.register(UINib(nibName: "DynamicTableViewCell", bundle: nil), forCellReuseIdentifier: "dynamicCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    private func setupPicker(){
        modePickerView.delegate = self
        modePickerView.dataSource = self
        modePickerView.tag = 0
        pipeTypePickerView.delegate  = self
        pipeTypePickerView.dataSource = self
        pipeTypePickerView.tag  = 1
        
        numberPickerView.delegate = self
        numberPickerView.dataSource = self
        numberPickerView.tag = 2
        
        diameterPickerView.delegate = self
        diameterPickerView.dataSource = self
        diameterPickerView.tag = 3
    }
    
    
    private func enterHoleNumber(){
        
    }
    


}

extension InputViewController: UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.holes.count + fields.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < staticCellStrings.count{
            return 50
        }else{
            return 60
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < staticCellStrings.count{
            let staticCell = tableView.dequeueReusableCell(withIdentifier: "staticCell", for: indexPath) as! StaticTableViewCell

            staticCell.inputTextField.delegate = self

            let field = fields[indexPath.row]
            staticCell.nameLabel.text = field.fieldName
            
            switch(indexPath.row){
            case 0:
                staticCell.inputTextField.inputView = nil
                if let boxLength = self.boxLength{
                    print(boxLength)
                    staticCell.numberLabel.text = String(boxLength)
                    staticCell.inputTextField.text = String(boxLength)
                    staticCell.mmLabel.isHidden = false
                    staticCell.numberLabel.textColor = .label
                }else{
                    staticCell.numberLabel.text = "未設定"
                    staticCell.mmLabel.isHidden = true
                    staticCell.numberLabel.textColor = .placeholderText
                }
            case 1:
                staticCell.inputTextField.inputView = nil
                if let pipeInterval = self.pipeInterval{
                    print(pipeInterval)
                    staticCell.numberLabel.text = String(pipeInterval)
                    staticCell.inputTextField.text = String(pipeInterval)
                    staticCell.mmLabel.isHidden = false
                    staticCell.numberLabel.textColor = .label
                }else{
                    staticCell.numberLabel.text = "未設定"
                    staticCell.mmLabel.isHidden = true
                    staticCell.numberLabel.textColor = .placeholderText
                }
            case 2:
                staticCell.inputTextField.inputView = nil

                if let railHeight = self.railHeight{
                    print(railHeight)
                    staticCell.numberLabel.text = String(railHeight)
                    staticCell.inputTextField.text = String(railHeight)
                    staticCell.mmLabel.isHidden = false
                    staticCell.numberLabel.textColor = .label
                }else{
                    staticCell.numberLabel.text = "未設定"
                    staticCell.mmLabel.isHidden = true
                    staticCell.numberLabel.textColor = .placeholderText
                }
                
            case 3:
                staticCell.inputTextField.inputView = nil

                if let railEx = self.railEx{
                    print(railEx)
                    staticCell.numberLabel.text = String(railEx)
                    staticCell.inputTextField.text = String(railEx)
                    staticCell.mmLabel.isHidden = false
                    staticCell.numberLabel.textColor = .label
                }else{
                    staticCell.numberLabel.text = "未設定"
                    staticCell.mmLabel.isHidden = true
                    staticCell.numberLabel.textColor = .placeholderText
                }
            case 4:
                staticCell.inputTextField.inputView = pipeTypePickerView
//                if let selectedPipeType = self.selectedPipeType{
                    print(selectedPipeType)
                    staticCell.numberLabel.text = selectedPipeType
                    staticCell.inputTextField.text = String(selectedPipeType)
                    staticCell.mmLabel.isHidden = true
                    staticCell.numberLabel.textColor = .label
//                }else{
//                    staticCell.numberLabel.text = "未設定"
//                    staticCell.mmLabel.isHidden = true
//                    staticCell.numberLabel.textColor = .placeholderText
//                }
            case 5:
                staticCell.inputTextField.inputView = nil
                staticCell.inputTextField.tag = 5
                staticCell.inputTextField.keyboardType = .numberPad
                if let pipeNumText = self.pipeNumText{
                    print(pipeNumText)
                    staticCell.numberLabel.text = String(pipeNumText)
                    staticCell.inputTextField.text = String(pipeNumText)
                    staticCell.mmLabel.isHidden = true
                    staticCell.numberLabel.textColor = .label
                }else{
                    staticCell.numberLabel.text = "未設定"
                    staticCell.mmLabel.isHidden = true
                    staticCell.numberLabel.textColor = .placeholderText
                }
            default:
                print(indexPath)
            }
            return staticCell
        }else{
            let dynamicCell = tableView.dequeueReusableCell(withIdentifier: "dynamicCell", for: indexPath) as! DynamicTableViewCell
            dynamicCell.delegate = self
            dynamicCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            
            let number = indexPath.row - staticCellStrings.count + 1
            dynamicCell.nameLabel.text  = "配管\(number)"
            dynamicCell.mmLabel.isHidden = true
            dynamicCell.numberLabel.textColor = .label
            dynamicCell.inputTextField.delegate = self
            dynamicCell.inputTextField.inputView = diameterPickerView
            if selectedPipeType == "厚鋼"{
                dynamicCell.numberLabel.text = "G16"
            }else{
                dynamicCell.numberLabel.text = "C19"
            }
            return dynamicCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        tableView.deselectRow(at: indexPath, animated: true)
        self.didSelectRow(indexPath:indexPath)
    }
    func didSelectRow(indexPath:IndexPath){
        if let beforeIndex = self.selectedIndex{
            self.save()
            if let beforeCell =  tableView.cellForRow(at: beforeIndex) as? StaticTableViewCell{
                beforeCell.inputTextField.isHidden = true
                beforeCell.numberLabel.isHidden = false
                if beforeIndex.row < 4 && beforeCell.numberLabel.text != "未設定"{
                    beforeCell.mmLabel.isHidden = false
                }
                
            }else if let beforeCell = tableView.cellForRow(at: beforeIndex) as? DynamicTableViewCell{
                beforeCell.inputTextField.isHidden = true
                beforeCell.numberLabel.isHidden = false
            }
        }
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let nextItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: self, action: #selector(tappedNextButton))
        let backItem = UIBarButtonItem(image: UIImage(systemName: "chevron.up"), style: .plain, target: self, action: #selector(tappedBackButton))
        let cancelItem = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(cancel))
        let doneItem = UIBarButtonItem(title: "決定", style: .done, target: self,action: #selector(tappedSaveButton))
        
        if indexPath.row < staticCellStrings.count{
            
            self.selectedIndex = indexPath
            let cell = tableView.cellForRow(at: indexPath) as! StaticTableViewCell
            cell.inputTextField.inputAccessoryView = toolbar
            let label = UILabel()
            label.text = staticCellStrings[indexPath.row]
            let titleItem = UIBarButtonItem(customView: label)
            cell.inputTextField.becomeFirstResponder()
            print(values)
            switch(indexPath.row){
//                let staticCellStrings = ["BOX横幅","配管隙間","レール高さ","レール全長","管種","配管数"]

            case 0:
//                if let float = boxLength{
//                    cell.inputTextField.text = String(float)
//                }
                
                cell.inputTextField.isHidden = false
                cell.numberLabel.isHidden = true
                toolbar.setItems([nextItem,spacelItem,titleItem,spacelItem,doneItem], animated: true)

            case 1:
                cell.inputTextField.isHidden = false
                cell.numberLabel.isHidden = true
                toolbar.setItems([backItem,nextItem,spacelItem,titleItem,spacelItem,doneItem], animated: true)
            case 2:
//                if let float = railHeight{
//                    cell.inputTextField.text = String(float)
//                }
                cell.inputTextField.isHidden = false
                cell.numberLabel.isHidden = true
                toolbar.setItems([backItem,nextItem,spacelItem,titleItem,spacelItem,doneItem], animated: true)
            case 3:
//                if let float = railEx{
//                    cell.inputTextField.text = String(float)
//                }
                cell.inputTextField.isHidden = false
                cell.numberLabel.isHidden = true
                toolbar.setItems([backItem,nextItem,spacelItem,titleItem,spacelItem,doneItem], animated: true)
            case 4:
//                if let string = selectedPipeType{
//                    cell.inputTextField.text = string
//                }
                cell.inputTextField.isHidden = false
                cell.numberLabel.isHidden = true
                toolbar.setItems([backItem,nextItem,spacelItem,titleItem,spacelItem,doneItem], animated: true)
            case 5:
//                if let int = pipeNumText{
//                    cell.inputTextField.text = String(int)
//                }
                cell.inputTextField.isHidden = false
                cell.numberLabel.isHidden = true
                toolbar.setItems([backItem,spacelItem,titleItem,spacelItem,doneItem], animated: true)
            default:
                print(indexPath)
            }
        }else{
            //dynamicCell
            self.selectedIndex = indexPath
            let dynamicCell = tableView.cellForRow(at: indexPath) as! DynamicTableViewCell
            dynamicCell.inputTextField.inputAccessoryView = toolbar
            let dynamicIndex = indexPath.row - self.staticCellStrings.count
            let hole = self.holes[dynamicIndex].name
            if let selectedRow = GPipe.firstIndex(where: {$0 == hole}){
                print(selectedRow)
                self.diameterPickerView.selectRow(selectedRow, inComponent: 0, animated: false)
            }
            dynamicCell.inputTextField.isHidden = false
            dynamicCell.numberLabel.isHidden = true
            let label = UILabel()
            label.text = dynamicCell.nameLabel.text
            let titleItem = UIBarButtonItem(customView: label)
            dynamicCell.inputTextField.becomeFirstResponder()
            toolbar.setItems([cancelItem,spacelItem,titleItem,spacelItem,doneItem], animated: true)
            
        }
        
    }
    
    @objc func tappedNextButton(){
        guard let currentIndex = selectedIndex else{return}
        
        let cellRect = tableView.rectForRow(at: currentIndex)
        let cellRectInView = tableView.convert(cellRect, to: self.view)
        if tableView.frame.minY + tableView.verticalScrollIndicatorInsets.top <= cellRectInView.minY && cellRectInView.maxY <= tableView.frame.maxY { print("収まっている")
            self.save()
            let nextIndex = IndexPath(row: currentIndex.row + 1, section: 0)
            self.selectedIndex = nextIndex
            self.tableView.selectRow(at: nextIndex, animated: true, scrollPosition: .top)
            self.didSelectRow(indexPath: nextIndex)
        } else {
            print("収まっていない")
            self.tableView.scrollToRow(at: currentIndex, at: .top, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.save()
                let nextIndex = IndexPath(row: currentIndex.row + 1, section: 0)
                self.selectedIndex = nextIndex
                self.tableView.selectRow(at: nextIndex, animated: true, scrollPosition: .top)
                self.didSelectRow(indexPath: nextIndex)
            }
            
        }
        
        
    }
    @objc func tappedBackButton(){
        guard let currentIndex = selectedIndex else{return}
        let cellRect = tableView.rectForRow(at: currentIndex)
        let cellRectInView = tableView.convert(cellRect, to: self.view)
        if tableView.frame.minY + tableView.verticalScrollIndicatorInsets.top <= cellRectInView.minY && cellRectInView.maxY <= tableView.frame.maxY { print("収まっている")
            self.save()
            if currentIndex.row != 0{
                let previousIndex = IndexPath(row: currentIndex.row - 1, section: 0)
                selectedIndex = previousIndex
                self.tableView.selectRow(at: previousIndex, animated: true, scrollPosition: .top)
                self.didSelectRow(indexPath: previousIndex)
            }
        } else {
            print("収まっていない")
            self.tableView.scrollToRow(at: currentIndex, at: .top, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if currentIndex.row != 0{
                    let previousIndex = IndexPath(row: currentIndex.row - 1, section: 0)
                    self.selectedIndex = previousIndex
                    self.tableView.selectRow(at: previousIndex, animated: false, scrollPosition: .top)
                    self.didSelectRow(indexPath: previousIndex)
                }
                
            }
        }
    }
    
    @objc func tappedSaveButton(){
        guard let indexPath = self.selectedIndex else{return}
        let cellRect = tableView.rectForRow(at: indexPath)
        let cellRectInView = tableView.convert(cellRect, to: self.view)
        if tableView.frame.minY + tableView.verticalScrollIndicatorInsets.top <= cellRectInView.minY && cellRectInView.maxY <= tableView.frame.maxY { print("収まっている")
            self.save()
        }else{
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.save()
            }
        }
    }
    
    @objc func save(){
        guard let indexPath = self.selectedIndex else{return}
      
        if staticCellStrings.count > indexPath.row{
            guard let cell = tableView.cellForRow(at:indexPath) as? StaticTableViewCell else{return}
            cell.inputTextField.isHidden = true
            cell.numberLabel.isHidden = false
            
            switch(indexPath.row){
                //                ["BOX横幅","配管隙間","レール高さ","レール全長","管種","配管数"]
            case 0:
                guard let string = cell.inputTextField.text,!(string.isEmpty) else{
                    cell.numberLabel.text  = "未設定"
                    cell.numberLabel.textColor = .placeholderText
                    cell.mmLabel.isHidden = true
                    boxLength = nil
                    tableView.deselectRow(at: indexPath, animated: true)
                    self.view.endEditing(true)
                    return
                }
                if let length = Float(string){
                    self.boxLength = length
                    cell.numberLabel.text = "\(length)"
                    cell.inputTextField.text = "\(length)"
                    cell.mmLabel.isHidden = false
                    cell.numberLabel.textColor = .label

                }
            case 1:
                guard let string = cell.inputTextField.text,!(string.isEmpty) else{
                    cell.numberLabel.text  = "未設定"
                    cell.numberLabel.textColor = .placeholderText
                    cell.mmLabel.isHidden = true
                    self.pipeInterval = nil
                    tableView.deselectRow(at: indexPath, animated: true)
                    self.view.endEditing(true)
                    return
                }
                if let length = Float(string){
                    self.pipeInterval = length
                    cell.numberLabel.text = "\(length)"
                    cell.inputTextField.text = "\(length)"
                    cell.mmLabel.isHidden = false
                    cell.numberLabel.textColor = .label

                }
            case 2:
                guard let string = cell.inputTextField.text,!(string.isEmpty) else{
                    cell.numberLabel.text  = "未設定"
                    cell.numberLabel.textColor = .placeholderText
                    cell.mmLabel.isHidden = true
                    railHeight = nil
                    tableView.deselectRow(at: indexPath, animated: true)
                    self.view.endEditing(true)
                    return
                }
                if let length = Float(string){
                    self.railHeight = length
                    cell.numberLabel.text = "\(length)"
                    cell.inputTextField.text = "\(length)"
                    cell.mmLabel.isHidden = false
                    cell.numberLabel.textColor = .label
                }
            case 3:
                guard let string = cell.inputTextField.text,!(string.isEmpty) else{
                    cell.numberLabel.text  = "未設定"
                    cell.numberLabel.textColor = .placeholderText
                    cell.mmLabel.isHidden = true
                    
                    railEx = nil
                    tableView.deselectRow(at: indexPath, animated: true)
                    self.view.endEditing(true)
                    return
                }
                if let length = Float(string){
                    self.railEx = length
                    cell.numberLabel.text = "\(length)"
                    cell.inputTextField.text = "\(length)"
                    cell.mmLabel.isHidden = false
                    cell.numberLabel.textColor = .label
                }
            case 4:
                let row = self.pipeTypePickerView.selectedRow(inComponent: 0)
                self.pipeTypePickerView.selectRow(row, inComponent: 0, animated: false)
                let string = pipeType[row]
                self.changePipeType(pipeType: string)
                cell.numberLabel.text = string
                cell.inputTextField.text = string
                cell.mmLabel.isHidden = true
                self.selectedPipeType = string
                cell.numberLabel.textColor = .label
            case 5:
                guard let string = cell.inputTextField.text,!(string.isEmpty) else{
                    cell.numberLabel.text  = "未設定"
                    cell.numberLabel.textColor = .placeholderText
                    cell.mmLabel.isHidden = true
                    pipeNumText = nil
                    tableView.deselectRow(at: indexPath, animated: true)
                    self.view.endEditing(true)
                    return
                }
                if let numberOfPipes = Int(string){
                    cell.numberLabel.text = "\(numberOfPipes)"
                    cell.inputTextField.text = "\(numberOfPipes)"
                    self.pipeNumText = numberOfPipes
                    self.changeNumberOfPipes(numberOfPipes: numberOfPipes)
                    cell.mmLabel.isHidden = true
                    cell.numberLabel.textColor = .label
                }
            default:
                print(indexPath)
            }
        }else{
            let dynamicCell = tableView.cellForRow(at:indexPath) as! DynamicTableViewCell
            dynamicCell.inputTextField.isHidden = true
            dynamicCell.numberLabel.isHidden = false
            let selectedRow = diameterPickerView.selectedRow(inComponent: 0)
            diameterPickerView.selectRow(selectedRow, inComponent: 0, animated: false)
            if selectedPipeType == "厚鋼"{
                let diameter = self.GPipe[selectedRow]
                dynamicCell.numberLabel.text = diameter
                dynamicCell.numberLabel.textColor = .label
                let dynamicIndex = indexPath.row - staticCellStrings.count
                if holes.count > dynamicIndex{
                    self.holes[dynamicIndex] = Hole(name: diameter)
                }
            }else{
                let diameter = self.CPipe[selectedRow]
                dynamicCell.numberLabel.text = diameter
                dynamicCell.numberLabel.textColor = .label
                let dynamicIndex = indexPath.row - staticCellStrings.count
                if holes.count > dynamicIndex{
                    self.holes[dynamicIndex] = Hole(name: diameter)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.endEditing(true)
        
        
    }

    
    func changeNumberOfPipes(numberOfPipes : Int){
        if holes.count < numberOfPipes{
            //追加するとき
        for pipe in holes.count ..< numberOfPipes{
            if selectedPipeType == "厚鋼"{
                let hole = Hole(name: "G16")
                self.holes.append(hole)
            }else{
                let hole = Hole(name: "C19")
                self.holes.append(hole)
            }
        }
            tableView.reloadData()
        }else{
            //減る時
            let diff = holes.count - numberOfPipes
            holes.removeLast(diff)
            tableView.reloadData()
        }
    }
    
    func changePipeType(pipeType:String){
        if pipeType == "厚鋼" && selectedPipeType != "厚鋼"{
            for (index,hole) in holes.enumerated(){
                let dynamicIndex = index + staticCellStrings.count
                if let dynamicCell = tableView.cellForRow(at:IndexPath(row: dynamicIndex, section: 0)) as? DynamicTableViewCell{
                    dynamicCell.numberLabel.text = "G16"
                }
                hole.name = "G16"
                hole.diameter = 16
                
            }
        }else if pipeType == "薄鋼" && selectedPipeType != "薄鋼"{
            for (index,hole) in holes.enumerated(){
                let dynamicIndex = index + staticCellStrings.count
                let dynamicCell = tableView.cellForRow(at:IndexPath(row: dynamicIndex, section: 0)) as! DynamicTableViewCell
                dynamicCell.inputTextField.text = "C19"
                hole.name = "C19"
                hole.diameter = 19
            }
        }
    }
    
    
    @objc func cancel(){
        if let selectedInedx = selectedIndex{
        if let cell = tableView.cellForRow(at: selectedInedx) as? DynamicTableViewCell{
            cell.inputTextField.isHidden = true
            cell.numberLabel.isHidden = false
        }

            
        }
        self.view.endEditing(true)
    }
    
    @objc func tappedStartCalcButton(){
        var sum :Float = 0
        self.save()
        guard let boxLength = self.boxLength else{
            let alert = UIAlertController(title: "エラー", message: "BOX横幅の値を入力してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default)
            alert.addAction(ok)
            self.present(alert, animated: true)
            return
            
        }
        guard let pipeInterval = self.pipeInterval else{
            
            let alert = UIAlertController(title: "エラー", message: "配管隙間の値を入力してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default)
            alert.addAction(ok)
            self.present(alert, animated: true)
            return
        }
        if holes.count == 0{
            let alert = UIAlertController(title: "エラー", message: "配管がありません", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default)
            alert.addAction(ok)
            self.present(alert, animated: true)
            return
        }
        let railHeight = self.railHeight  ?? 0.0
        let railEx = self.railEx ?? 0.0
        results = []
        var userSetting : [String:Float]?
        
        if let setting = UserDefaults.standard.dictionary(forKey: "pipe") as? [String:Float]{
            userSetting = setting
        }
        
        let dispatchGroup = DispatchGroup()
        for hole in holes{
            dispatchGroup.enter()
            if let userSetting = userSetting {
                //ユーザー設定がある場合
                if let diameter = userSetting[hole.name]{
                    sum += diameter
                    hole.diameter = diameter
                }else{
                    if let diameter = holeList[hole.name] {
                        sum += Float(diameter)
                        hole.diameter = Float(diameter)
                    }
                }
            }else{
                if let diameter = holeList[hole.name] {
                    sum += Float(diameter)
                    hole.diameter = Float(diameter)
                }
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main){
            let dg = DispatchGroup()
            //box両端の余長
            let edgeLength = (boxLength - (sum + ( Float(self.holes.count - 1) * pipeInterval))) / 2.0
            self.railLength = sum + pipeInterval * Float(self.holes.count - 1) + 2 * railEx
            
            if edgeLength < 0{
                HUD.flash(.labeledError(title: "エラー", subtitle: "BOX幅が足りません"),delay: 0.4)
                return
            }
            
            for index in 0 ..< self.holes.count{
                dg.enter()
                let resultY = self.holes[index].diameter / 2 + railHeight
                if index == 0{
                    let  resultX = edgeLength + self.holes[index].diameter / 2
                    let result = Result(x: resultX, y: resultY)
                    result.interval = resultX
                    self.results.append(result)
                }
                if index >= 1{
                    let resultX = self.results[index - 1].x + ( self.holes[index - 1].diameter  +  self.holes[index].diameter ) / 2 + pipeInterval
                    let interval = ( self.holes[index - 1].diameter  +  self.holes[index].diameter ) / 2 + pipeInterval
                    let result = Result(x: resultX, y: resultY)
                    result.interval = interval
                    self.results.append(result)
                }
                print(self.results[index])
                dg.leave()
            }
            
            dg.notify(queue: .main){
               
                if let parent = self.parent as? PagerTabStripViewController{
                    parent.moveToViewController(at: 1)
                    let vc = parent.viewControllers[1] as! ResultViewController
                    vc.results = self.results
                    vc.holes  = self.holes
                    vc.boxLength = boxLength
                    vc.railLength = self.railLength
                    vc.railEx = railEx
                    vc.railHeight = railHeight
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        vc.renderDrawingView()
                    }
                }
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return  indexPath.row >= staticCellStrings.count
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = holes.remove(at: sourceIndexPath.row)
        holes.insert(itemToMove, at: destinationIndexPath.row)
    }
    
    
    
//    func textFieldDidChangeSelection(_ textField: UITextField) {
//
////        guard let password = textField.text else { return }
////        if textField.tag == 5{
////        if password.count > 2 {
////            textField.text = String(password.prefix(2))
////        }
////        }else{
////            if password.count > 4 {
//        //                textField.text = String(password.prefix(4))
//        //            }
//        //        }
//
//        guard let text = textField.text else { return }
//        guard let intText = Float(text) else { textField.text = ""; return }
//        if textField.tag != 5{
//            if intText > 9999 {
//                textField.text = text.substring(to: text.index(text.startIndex, offsetBy: 3))
//            }
//        }else{
//            if intText > 100 {
//                textField.text = text.substring(to: text.index(text.startIndex, offsetBy: 2))
//            }
//        }
//    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        var maxValue : Float = 9999
        if selectedIndex?.row == 5{
            maxValue = 100
        }
      if newText.isEmpty {
        return true
      }else if let floatValue = Float(newText), floatValue <= maxValue {
        return true
      }
      return false
    }
    
    
}

extension InputViewController:DynamicTableViewCellDelegate{
    func tappedDeleteButton(cell:DynamicTableViewCell){
        self.save()
        self.selectedIndex = nil
        guard let indexPath = self.tableView.indexPath(for: cell) else{return}
        let index = indexPath.row - staticCellStrings.count
        self.holes.remove(at: index)
        tableView.deleteRows(at: [indexPath], with: .left)
        pipeNumText = self.holes.count
        if let pipeNumCell = tableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? StaticTableViewCell{
        pipeNumCell.inputTextField.text = "\(self.holes.count)"
        pipeNumCell.numberLabel.text = "\(self.holes.count)"
        }
    }
}


extension InputViewController :UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(pickerView.tag){
        case 0:
            return mode.count
        case 1:
            return pipeType.count
        case 2:
            return numberOfPipes.count
        case 3:
            if selectedPipeType == "厚鋼"{
                return GPipe.count
            }else{
                return CPipe.count
            }
        default:
            return 0
            
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch(pickerView.tag){
        case 0:
            return mode[row]
        case 1:
            return pipeType[row]
        case 2:
            let int = numberOfPipes[row]
            return String(int)
        case 3:
            if selectedPipeType == "厚鋼"{
                return GPipe[row]
            }else{
                return CPipe[row]
            }
        default:
            return ""
            
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let selectedIndex = selectedIndex{
            if selectedIndex.row < staticCellStrings.count{
            let cell = tableView.cellForRow(at:selectedIndex) as! StaticTableViewCell
        switch(pickerView.tag){
        case 0:
            let string =  mode[row]
            
        case 1:
            let string =  pipeType[row]
            cell.inputTextField.text = string
            
        case 2:
            let int = numberOfPipes[row]
            let string =  String(int)
            cell.inputTextField.text = string
            
        default:
            let string =  ""
        
        }
            }else{
                if selectedPipeType == "厚鋼" {
                    let cell = tableView.cellForRow(at:selectedIndex) as! DynamicTableViewCell
                    let string = GPipe[row]
//                    cell.inputTextField.text = string
                }else{
                    let cell = tableView.cellForRow(at:selectedIndex) as! DynamicTableViewCell
                    let string = CPipe[row]
//                    cell.inputTextField.text = string
                }

            }
        }
    }
    @objc func keyboardWillShow(_ notification: NSNotification) {
      
           offset = tableView.contentOffset
           if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
               tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
               tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
               resetButtonBottom.constant = keyboardHeight - 60
               calcButtonBottom.constant = keyboardHeight - 60
               UIView.animate(withDuration: 0.2, animations: {
                   self.view.layoutIfNeeded()
               })
           }
       }

       @objc func keyboardWillHide(_ notification: NSNotification) {
         

           self.resetButtonBottom.constant = 20
           self.calcButtonBottom.constant = 20
           UIView.animate(withDuration: 0.2, animations: {
               if let unwrappedOffset = self.offset {
                   self.tableView.contentOffset = unwrappedOffset
               }
               self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
               self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
           })
           
       }
           
}




extension InputViewController: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "数値入力") // ButtonBarItemに表示される名前になります
    }
}
