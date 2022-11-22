//
//  ViewController.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/09/10.
//

import UIKit
import XLPagerTabStrip

// デフォルトで継承している UIViewController を ButtonBarPagerTabStripViewController に書き換える
class InputViewController: UIViewController {
    @IBOutlet weak var pullDownMenu: UIView!
    
    @IBOutlet weak var pullDownImage: UIImageView!
    @IBOutlet weak var pullDownLabel: UILabel!
    
    @IBOutlet weak var pullDownTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var calculateButton: UILabel!
    var holes : [Hole] = []
    var fields :[FieldValue] = []
    let staticCellStrings = ["BOX横幅","配管隙間","レール高さ","レール余長","管種","配管数"]
    
    let mode = ["端から配管中心までの距離を計算","配管の中心の間隔を計算"]
    let pipeType = ["厚鋼","薄鋼"]
    let GPipe : [Diameter.G] = Diameter.G.allCases
    let CPipe = ["C19","C22"]
    let holeList = ["G16":16,"G22":22,"G36":36,"C19":19,"C22":22]
    
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
    var selectedPipeType:String?
    var pipeNumText:Int?
    
    var values :  [Any] = []
    
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
        pullDownMenu.layer.borderWidth = 1.0
        pullDownMenu.layer.borderColor = UIColor.label.cgColor
        pullDownMenu.cornerRadius = 10
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedPullDownMenu))
        pullDownMenu.addGestureRecognizer(gesture)
        setupPicker()
        let calcGesture = UITapGestureRecognizer(target: self, action: #selector(tappedStartCalcButton))
        self.calculateButton.addGestureRecognizer(calcGesture)
        calculateButton.isUserInteractionEnabled = true
        
        
        
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
        pullDownTextField.inputView = modePickerView
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
    
    @objc func tappedPullDownMenu(){
        
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
                if let selectedPipeType = self.selectedPipeType{
                    print(selectedPipeType)
                    staticCell.numberLabel.text = selectedPipeType
                    staticCell.inputTextField.text = String(selectedPipeType)
                    staticCell.mmLabel.isHidden = true
                    staticCell.numberLabel.textColor = .label
                }else{
                    staticCell.numberLabel.text = "未設定"
                    staticCell.mmLabel.isHidden = true
                    staticCell.numberLabel.textColor = .placeholderText
                }
            case 5:
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
            dynamicCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            
            let number = indexPath.row - staticCellStrings.count + 1
            dynamicCell.nameLabel.text  = "配管\(number)"
            dynamicCell.mmLabel.isHidden = true
            dynamicCell.numberLabel.textColor = .placeholderText
            dynamicCell.inputTextField.delegate = self
            dynamicCell.inputTextField.inputView = diameterPickerView
            return dynamicCell
        }
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        let holeCell
//        if indexPath.row < staticCellStrings.count{
//            let staticCell = tableView.dequeueReusableCell(withIdentifier: "staticCell", for: indexPath) as! StaticTableViewCell
//
//
//            let field = fields[indexPath.row]
//            let value = values[indexPath.row]
//            staticCell.nameLabel.text = field.fieldName
//            if let number = value as? Float{
//                //数値が入るfieldの場合
//                if indexPath.row == 5{
//                    staticCell.numberLabel.text = "\(Int(number))"
//                    staticCell.mmLabel.isHidden = true
//                }else{
//                    staticCell.numberLabel.text = "\(number)"
//                    staticCell.mmLabel.isHidden = false
//                }
//                staticCell.numberLabel.textColor = .label
//            }else if let string = value as? String{
//                //stringが入るfieldの場合
//                staticCell.numberLabel.text = string
//                staticCell.mmLabel.isHidden = true
//                staticCell.numberLabel.textColor = .label
//            }else{
//                //どちらも入っていない場合
//                staticCell.numberLabel.text = "未設定"
//                staticCell.mmLabel.isHidden = true
//                staticCell.numberLabel.textColor = .placeholderText
//            }
//            staticCell.inputTextField.delegate = self
//            if indexPath.row == 4{
//                staticCell.inputTextField.inputView = pipeTypePickerView
//                staticCell.mmLabel.isHidden = true
//            }
//            return staticCell
//        }else{
//            let dynamicCell = tableView.dequeueReusableCell(withIdentifier: "dynamicCell", for: indexPath) as! DynamicTableViewCell
//            dynamicCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
//
//            let number = indexPath.row - staticCellStrings.count + 1
//            dynamicCell.nameLabel.text  = "配管\(number)"
//            dynamicCell.mmLabel.isHidden = true
//            dynamicCell.numberLabel.textColor = .placeholderText
//            dynamicCell.inputTextField.delegate = self
//            dynamicCell.inputTextField.inputView = diameterPickerView
//            return dynamicCell
//        }
//
//
//
//    }
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
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 45))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let nextItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: self, action: #selector(tappedNextButton))
        let backItem = UIBarButtonItem(image: UIImage(systemName: "chevron.up"), style: .plain, target: self, action: #selector(tappedBackButton))
        let cancelItem = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(cancel))
        let doneItem = UIBarButtonItem(title: "決定", style: .done, target: self,action: #selector(save))
       
        
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
//                if let float = pipeInterval{
//                    cell.inputTextField.text = String(float)
//                }
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
            if let selectedRow = GPipe.map({$0.name}).firstIndex(where: {$0 == hole}) as? Int{
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
    func didSelectRowbefore(indexPath:IndexPath){
       
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
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 45))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let nextItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: self, action: #selector(tappedNextButton))
        let backItem = UIBarButtonItem(image: UIImage(systemName: "chevron.up"), style: .plain, target: self, action: #selector(tappedBackButton))
        let cancelItem = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(cancel))
        let doneItem = UIBarButtonItem(title: "決定", style: .done, target: self,action: #selector(save))
       
        
        if indexPath.row < staticCellStrings.count{
            
            self.selectedIndex = indexPath
            let cell = tableView.cellForRow(at: indexPath) as! StaticTableViewCell
            cell.inputTextField.inputAccessoryView = toolbar
            let label = UILabel()
            label.text = self.staticCellStrings[indexPath.row]
            let titleItem = UIBarButtonItem(customView: label)
            if let string = self.fields[indexPath.row].stringValue{
                cell.inputTextField.text = string
            }else if let float = self.fields[indexPath.row].value{
                cell.inputTextField.text = String(float)
            }
            cell.inputTextField.becomeFirstResponder()
        if indexPath.row == 0{
            cell.inputTextField.isHidden = false
            cell.numberLabel.isHidden = true
            toolbar.setItems([nextItem,spacelItem,titleItem,spacelItem,doneItem], animated: true)
        }else if indexPath.row == 4 || indexPath.row == 5{
            toolbar.setItems([cancelItem,spacelItem,titleItem,spacelItem,doneItem], animated: true)
        }else{
            cell.inputTextField.isHidden = false
            cell.numberLabel.isHidden = true
            toolbar.setItems([backItem,nextItem,spacelItem,titleItem,spacelItem,doneItem], animated: true)
        }
        }else{
            //dynamicCellタップ時
            self.selectedIndex = indexPath
            let dynamicCell = tableView.cellForRow(at: indexPath) as! DynamicTableViewCell
            let type = pipeTypePickerView.selectedRow(inComponent: 0)
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
        self.save()
        guard let currentIndex = selectedIndex else{return}
     
        let nextIndex = IndexPath(row: currentIndex.row + 1, section: 0)
        selectedIndex = nextIndex
        self.tableView.selectRow(at: nextIndex, animated: true, scrollPosition: .top)
        self.didSelectRow(indexPath: nextIndex)
    }
    @objc func tappedBackButton(){
        self.save()
        guard let currentIndex = selectedIndex else{return}
        if currentIndex.row != 0{
        let previousIndex = IndexPath(row: currentIndex.row - 1, section: 0)
        selectedIndex = previousIndex
        self.tableView.selectRow(at: previousIndex, animated: true, scrollPosition: .top)
        self.didSelectRow(indexPath: previousIndex)
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
                dynamicCell.numberLabel.text = diameter.name
                dynamicCell.numberLabel.textColor = .label
                let dynamicIndex = indexPath.row - staticCellStrings.count
                if holes.count > dynamicIndex{
                    self.holes[dynamicIndex] = Hole(name: diameter.name)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.endEditing(true)
        
        
    }
    @objc func savebefore(){
        //決定ボタンタップ
        guard let indexPath = self.selectedIndex else{return}
        if indexPath.row < staticCellStrings.count{
            //cellがstaticCellの場合
        let editingField = fields[indexPath.row]
        let cell = tableView.cellForRow(at:indexPath) as! StaticTableViewCell
            cell.inputTextField.isHidden = true
            cell.numberLabel.isHidden = false
            guard let stringInt = cell.inputTextField.text else{
            cell.numberLabel.text  = "未設定"
            cell.numberLabel.textColor = .placeholderText
            return
        }
        if let number = Float(stringInt){
            //Intに変換できる時
            editingField.value = number
            values[indexPath.row] = number
           
            if indexPath.row == 5{
                //配管数の場合
                let int = Int(number)
                cell.numberLabel.text = "\(int)"
                cell.inputTextField.text = "\(int)"
                self.changeNumberOfPipes(numberOfPipes: int)
                cell.mmLabel.isHidden = true
            }else{
                cell.numberLabel.text = "\(number)"
                cell.inputTextField.text = "\(number)"
            }
        }else if !(stringInt.isEmpty) && stringInt != "未設定"{
            editingField.stringValue = stringInt
            values[indexPath.row] = stringInt
            cell.numberLabel.text = stringInt
            cell.mmLabel.isHidden = true
            if indexPath.row == 4{
                self.changePipeType(pipeType: stringInt)
            }
        }else{
            editingField.value = nil
            editingField.stringValue = nil
            cell.numberLabel.text  = "未設定"
            cell.numberLabel.textColor = .placeholderText
            cell.mmLabel.isHidden = true
        }
        }else{
            //
            let dynamicCell = tableView.cellForRow(at:indexPath) as! DynamicTableViewCell
            if let string = dynamicCell.inputTextField.text,!(string.isEmpty){
                let selectedRow = diameterPickerView.selectedRow(inComponent: 0)
                 diameterPickerView.selectRow(selectedRow, inComponent: 0, animated: false)
                if selectedPipeType == "厚鋼"{
                    let diameter = self.GPipe[selectedRow]
                    if holes.count > indexPath.row - staticCellStrings.count{
                    self.holes[indexPath.row] = Hole(name: diameter.name)
                    }
                }else{
                    
                }
                
            }else{
                
            }

        }
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.endEditing(true)
    }
//    @objc func done(){
//        guard let selectedIndex = selectedIndex else{return}
//        let cell = tableView.cellForRow(at: selectedIndex) as! StaticTableViewCell
//
//    }
    
    func changeNumberOfPipes(numberOfPipes : Int){
        if holes.count < numberOfPipes{
            //追加するとき
        for pipe in holes.count ..< numberOfPipes{
            let hole = Hole(name: "G16")
            self.holes.append(hole)
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
        if pipeType == "厚鋼"{
            for (index,hole) in holes.enumerated(){
                let dynamicIndex = index + staticCellStrings.count
                if let dynamicCell = tableView.cellForRow(at:IndexPath(row: dynamicIndex, section: 0)) as? DynamicTableViewCell{
                    dynamicCell.numberLabel.text = "G16"
                }
                hole.name = "G16"
                hole.diameter = 16.0
                
                
            }
        }else{
            for (index,hole) in holes.enumerated(){
                let dynamicIndex = index + staticCellStrings.count
                let dynamicCell = tableView.cellForRow(at:IndexPath(row: dynamicIndex, section: 0)) as! DynamicTableViewCell
                dynamicCell.inputTextField.text = "C22"
                hole.name = "C22"
                hole.diameter = 22.0
            }
        }
    }
    
    
    @objc func cancel(){
        self.view.endEditing(true)
    }
    
    @objc func tappedStartCalcButton(){
        var sum :Float = 0
        guard let boxLength = self.boxLength else{return}
        guard let pipeInterval = self.pipeInterval else{return}
        let railHeight = self.railHeight  ?? 0.0
        let railEx = self.railEx ?? 0.0
        results = []
        var userSetting : [String:Float]?
        if self.selectedPipeType == "厚鋼"{
            if let userSettingG = UserDefaults.standard.dictionary(forKey: "G") as? [String:Float]{
                userSetting = userSettingG
            }
        }else{
            if let userSettingC = UserDefaults.standard.dictionary(forKey: "C") as? [String:Float]{
                userSetting = userSettingC
            }
        }
        let dispatchGroup = DispatchGroup()
        for hole in holes{
            dispatchGroup.enter()
            if let userSetting = userSetting {
                //ユーザー設定がある場合
                if let diameter = userSetting[hole.name]{
                    sum += diameter
                }else{
                    if let diameter = holeList[hole.name] {
                        sum += Float(diameter)
                    }
                }
            }else{
                if let diameter = holeList[hole.name] {
                    sum += Float(diameter)
                }
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main){
            
            //box両端の余長
            let edgeLength = (boxLength - (sum + ( Float(self.holes.count - 1) * pipeInterval))) / 2.0
            self.railLength = sum + pipeInterval * Float(self.holes.count - 1) + 2 * railEx
            
            for index in 0 ..< self.holes.count{
                
                let resultY = self.holes[index].diameter / 2 + railHeight
                if index == 0{
                    let  resultX = edgeLength + self.holes[index].diameter / 2
                    let result = Result(x: resultX, y: resultY)
                    self.results.append(result)
                }
                if index >= 1{
                    let resultX = self.results[index - 1].x + ( self.holes[index - 1].diameter  +  self.holes[index].diameter ) / 2 + pipeInterval
                    let result = Result(x: resultX, y: resultY)
                    self.results.append(result)
                }
                print(self.results[index])
            }
            
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
                return GPipe[row].name
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
            self.pullDownLabel.text = string
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
                    let string = GPipe[row].name
//                    cell.inputTextField.text = string
                }else{
                    let cell = tableView.cellForRow(at:selectedIndex) as! DynamicTableViewCell
                    let string = CPipe[row]
//                    cell.inputTextField.text = string
                }

            }
        }
    }
//    func textFieldDidChangeSelection(_ textField: UITextField) {
//        guard let selectedIndex = self.selectedIndex else{return}
//        let cell = tableView.cellForRow(at: selectedIndex) as! StaticTableViewCell
//        cell.numberLabel.text = textField.text
//        cell.numberLabel.textColor = .label
//        if selectedIndex.row == 4 || selectedIndex.row == 5{
//            cell.mmLabel.isHidden = true
//        }else{
//            cell.mmLabel.isHidden = false
//        }
//    }
}




extension InputViewController: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "数値入力") // ButtonBarItemに表示される名前になります
    }
}

