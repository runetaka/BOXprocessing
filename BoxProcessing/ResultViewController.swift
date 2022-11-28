//
//  ResultViewController.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/09/10.
//

import Foundation
import UIKit
import XLPagerTabStrip


class UserColor{
    var xColor : UIColor?
    var yColor : UIColor?
}

class ResultViewController:UIViewController{
    
    @IBOutlet weak var pullDownMenu: UIView!
    
    @IBOutlet weak var pullDownImage: UIImageView!
    @IBOutlet weak var pullDownLabel: UILabel!
    
    @IBOutlet weak var pullDownTextField: UITextField!
    
    @IBOutlet weak var drawingView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    var calcMode = 0
    
    var results :[Result]?
    var holes :[Hole]?
    var boxLength :Float?
    var railLength :Float?
    var railEx :Float?
    var railHeight :Float?
    
    var arrowViews : [ArrowView]?
    var arrowLayers : [CAShapeLayer]?
    var boxView =  UIView()
    var labels : [UILabel] = []
    var userColor : UserColor?
    var beforeScale : CGFloat?
    var labelXPosition : CGPoint?
    var labelYPosition : CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate  = self
        scrollView.maximumZoomScale = 8.0
        scrollView.minimumZoomScale = 0.1
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ResultTableViewCell", bundle: nil), forCellReuseIdentifier: "resultCell")
        tableView.register(
            UINib(nibName: "ResultTableViewHeader", bundle: nil),
            forHeaderFooterViewReuseIdentifier: "resultHeader")
        getUserColor()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedPullDownMenu))
        pullDownMenu.addGestureRecognizer(gesture)
        pullDownMenu.layer.borderWidth = 1.0
        pullDownMenu.layer.borderColor = UIColor.label.cgColor
        pullDownMenu.cornerRadius = 10
        
    }
    
    @objc func tappedPullDownMenu(){
        let sheet = UIAlertController(title: "計算方法", message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "BOX端から配管中心までの距離を計算", style: .default) { action in
            print("端から中心")
            self.pullDownLabel.text = "BOX端から配管中心までの距離を計算"
            if self.calcMode != 0{
                self.calcMode = 0
                self.tableView.reloadData()
            }
            self.dismiss(animated: true)
        }
        let action2 = UIAlertAction(title: "配管の中心の間隔を計算", style: .default) { action in
            self.pullDownLabel.text = "配管の中心の間隔を計算"
            if self.calcMode != 1{
                self.calcMode = 1
                self.tableView.reloadData()
            }
            self.dismiss(animated: true)
        }
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel)
        sheet.addAction(action1)
        sheet.addAction(action2)
        sheet.addAction(cancel)
        self.present(sheet, animated: true)
    }
    
    func getUserColor(){
        let userColor = UserColor()
        userColor.xColor = .red
        userColor.yColor = .blue
        self.userColor = userColor
        
    }
    
    func renderDrawingView(){
        //BOXと穴の描画
        guard let holes = holes,let results = results,let boxLength = boxLength,let railLength = railLength,let railEx = railEx else{return}
        boxView.removeFromSuperview()
        boxView = UIView()
        let maxHole = holes.max { hole, hole1 in
            hole.diameter < hole1.diameter
        }?.diameter ?? 100.0
        let boxHeight = maxHole + 30.0 + (railHeight ?? 0)
        boxView.backgroundColor = .gray
        boxView.translatesAutoresizingMaskIntoConstraints = false
        self.drawingView.addSubview(boxView)
        boxView.widthAnchor.constraint(equalToConstant: CGFloat(boxLength)).isActive = true
        boxView.heightAnchor.constraint(equalToConstant: CGFloat(boxHeight)).isActive = true
        boxView.centerXAnchor.constraint(equalTo: drawingView.centerXAnchor).isActive = true
        boxView.centerYAnchor.constraint(equalTo: drawingView.centerYAnchor).isActive = true
        scrollView.setZoomScale(scrollView.frame.width / CGFloat(boxLength + 10.0), animated: true)
        scrollView.setContentOffset(CGPoint(x: (scrollView.contentSize.width - scrollView.frame.width) / 2, y: (scrollView.contentSize.height - scrollView.frame.height) / 2), animated: true)
        var i = 1
        for (hole,result) in zip(holes,results){
            let holeView = UIView()
            holeView.layer.borderColor = UIColor.green.cgColor
            holeView.layer.borderWidth = 0.5
            holeView.backgroundColor = .white
            boxView.addSubview(holeView)
            holeView.translatesAutoresizingMaskIntoConstraints = false
            holeView.widthAnchor.constraint(equalToConstant: CGFloat(hole.diameter)).isActive = true
            holeView.heightAnchor.constraint(equalToConstant: CGFloat(hole.diameter)).isActive = true
            holeView.centerXAnchor.constraint(equalTo: boxView.leadingAnchor, constant: CGFloat(result.x)).isActive = true
            holeView.centerYAnchor.constraint(equalTo:boxView.bottomAnchor,constant: CGFloat(-result.y)).isActive = true
            holeView.cornerRadius = CGFloat(hole.diameter / 2)
            let gesture = UITapGestureRecognizer(target: self, action: #selector(didSelectHole))
            holeView.addGestureRecognizer(gesture)
            holeView.tag = i
            i += 1
        }
        self.tableView.reloadData()
    }
    
    
    @objc func didSelectHole(sender:UITapGestureRecognizer){
        if let tag = sender.view?.tag{
            let index = tag - 1
            if let hole = holes?[index]{
                self.tableView.selectRow(at: IndexPath(row: tag - 1, section: 0), animated: false, scrollPosition: .top)
                guard let sender = sender.view else{return}
                let lineWidth :CGFloat = 1.0
                let midY  = (sender.center.y  +  boxView.frame.minY + boxView.frame.maxY) / 2
                let isOver = midY - 40 / 2  + 40 > boxView.frame.maxY ? true : false
                addLine(fromX:sender.center , toX: CGPoint(x:lineWidth / 2 , y: sender.frame.midY), fromY: sender.center, toY: CGPoint(x:sender.center.x,y: boxView.frame.height - lineWidth / 2), isOver: isOver)
                if let result = self.results?[index]{
                    for label in labels {
                        label.removeFromSuperview()
                        self.labels.removeFirst()
                    }
                    let labelX = UILabel()
                    labelX.textAlignment = .center
                    labelX.adjustsFontSizeToFitWidth = true
                    labelX.text = String(result.x)
                    let width :CGFloat = 100
                    let height :CGFloat = 40
                    print(sender.center.x,boxView.frame.minX)
                    let midX  = (sender.center.x + 2 * boxView.frame.minX) / 2
                    let midY  = (sender.center.y  + 2 *  boxView.frame.minY) / 2
                    let y = boxView.frame.minY + sender.center.y - height
                    self.labelXPosition = CGPoint(x: midX, y: midY)
                    labelX.frame = CGRect(x: midX - width / 2  , y: y , width: width, height: height)
                    self.drawingView.addSubview(labelX)
                    self.labels.append(labelX)
                }
//                addLabel(index: indexPath.row, sender: sender)

                
            }
        }
    }
    func addLabel(index:Int,sender:UIView){
        if let result = self.results?[index]{
            for label in labels {
                label.removeFromSuperview()
                self.labels.removeFirst()
            }
            let labelX = UILabel()
            labelX.textAlignment = .center
            labelX.adjustsFontSizeToFitWidth = true
            labelX.text = String(result.x)
            let width :CGFloat = 100
            let height :CGFloat = 40
            print(sender.center.x,boxView.frame.minX)
            let midX  = (sender.center.x + 2 * boxView.frame.minX) / 2
            let y = boxView.frame.minY + sender.center.y - height + 5
            self.labelXPosition = CGPoint(x: midX, y: y)
            labelX.frame = CGRect(x: midX - width / 2  , y: y , width: width, height: height)
            self.drawingView.addSubview(labelX)
            self.labels.append(labelX)
            
            let labelY = UILabel()
            labelY.textAlignment = .left
            labelY.adjustsFontSizeToFitWidth = true
            labelY.text = String(result.y)
            print(sender.center.x,boxView.frame.minX)
            let x  = boxView.frame.minX + sender.center.x + 5
            let midY  = (sender.center.y  +  boxView.frame.minY + boxView.frame.maxY) / 2
            let labelYY = midY - height / 2  + height > boxView.frame.maxY ? boxView.frame.maxY : midY - height / 2
            self.labelYPosition = CGPoint(x: x, y: midY)
            labelY.frame = CGRect(x:x  , y: labelYY , width: width, height: height)
            self.drawingView.addSubview(labelY)
            self.labels.append(labelY)
        }

    }
    func didSelectRow(indexPath:IndexPath){
        guard let sender = drawingView.viewWithTag(indexPath.row + 1) else{return}
        let lineWidth :CGFloat = 1.0
        let midY  = (sender.center.y  +  boxView.frame.minY + boxView.frame.maxY) / 2
        let isOver = midY - 40 / 2  + 40 > boxView.frame.maxY ? true : false
        addLine(fromX:sender.center , toX: CGPoint(x:lineWidth / 2 , y: sender.frame.midY), fromY: sender.center, toY: CGPoint(x:sender.center.x,y: boxView.frame.height - lineWidth / 2), isOver: isOver)
        addLabel(index: indexPath.row, sender: sender)
    }
    
    func addLine(fromX:CGPoint,toX:CGPoint,fromY:CGPoint,toY:CGPoint,isOver:Bool){
        
        let arrow = UIBezierPath()
        arrow.addArrow(start: fromX, end: toX, pointerLineLength: 10, arrowAngle: CGFloat(Double.pi / 6), lineWidth: 1.0,isOver: false)
        
        let arrowY = UIBezierPath()
        let pointerLineLength :CGFloat = toY.y - fromY.y < 20 ? 5 : 10
        arrowY.addArrow(start: fromY, end: toY, pointerLineLength: pointerLineLength, arrowAngle: CGFloat(Double.pi / 6), lineWidth: 1.0,isOver: isOver)
        
        if let arrowLayers = arrowLayers {
            for arrowLayer in arrowLayers {
                arrowLayer.removeFromSuperlayer()
            }
        }
        let arrowLayer = CAShapeLayer()
        if let userXColor = self.userColor?.xColor{
            arrowLayer.strokeColor = userXColor.cgColor
        }else{
        arrowLayer.strokeColor = UIColor.black.cgColor
        }
        arrowLayer.lineWidth = 1.0
        arrowLayer.path = arrow.cgPath
        arrowLayer.fillColor = UIColor.clear.cgColor
        arrowLayer.lineJoin = .round
        arrowLayer.lineCap =  .round
        self.boxView.layer.addSublayer(arrowLayer)
        
        let arrowYLayer = CAShapeLayer()
        if let userYColor = self.userColor?.yColor{
            arrowYLayer.strokeColor = userYColor.cgColor
        }else{
            arrowYLayer.strokeColor = UIColor.black.cgColor
        }
        arrowYLayer.lineWidth = 1.0
        arrowYLayer.path = arrowY.cgPath
        arrowYLayer.fillColor = UIColor.clear.cgColor
        arrowYLayer.lineJoin = .round
        arrowYLayer.lineCap =  .round
        self.boxView.layer.addSublayer(arrowYLayer)
        self.arrowLayers = [arrowLayer,arrowYLayer]
    }
}



extension ResultViewController: IndicatorInfoProvider,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell") as! ResultTableViewCell
        if let hole = holes?[indexPath.row],let result = results?[indexPath.row]{
            if self.calcMode == 0 {
                cell.nameLabel.text = hole.name
                cell.xpositionLabel.text = String(result.x)
                cell.ypositionLabel.text = String(result.y)
            }else{
                cell.nameLabel.text = hole.name
                if let interval = result.interval{
                    cell.xpositionLabel.text = String(interval)
                }
                cell.ypositionLabel.text = String(result.y)
            }
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRow(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "resultHeader") as! ResultTableViewHeader
        headerFooterView.setupTitle()
        return headerFooterView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "計算結果") // ButtonBarItemに表示される名前になります
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return drawingView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let scale = scrollView.zoomScale
        
//        for label in labels {
//            label.frame.size = CGSize(width: 100 / scale, height: 40 / scale)
//            if let labelXPosition = self.labelXPosition{
//                label.frame.origin = CGPoint(x: labelXPosition.x - 50 / scale, y: labelXPosition.y - 20 / scale)
//            }
//        }
        
        print(scale)
    }
}
