//
//  ResultViewController.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/09/10.
//

import Foundation
import UIKit
import XLPagerTabStrip
import Instructions

class UserColor{
    var xColor : UIColor?
    var yColor : UIColor?
}

class ResultViewController:UIViewController, ResultTableViewCellDelegate{
    
    
    func changeDisplayLabel(index: Int) {
        self.didSelectRow(indexPath: IndexPath(row: index, section: 0))
        
    }
    
    
    @IBOutlet weak var pullDownMenu: UIView!
    
    @IBOutlet weak var pullDownImage: UIImageView!
    @IBOutlet weak var pullDownLabel: UILabel!
    
    @IBOutlet weak var drawingViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var drawingViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var drawingView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    var calcMode = 0
    
    var results :[Result]?
//    var holes :[Hole]?
    var bolts :[UBolts]?
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
    var pipeLabels : [UILabel] = []
    //tutorial
    let coachMarksController = CoachMarksController()

    var uBoltsDiameter: Float = 12  //Uボルト穴径

    var displayLabel : [Int:Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate  = self
        scrollView.maximumZoomScale = 8.0
        scrollView.minimumZoomScale = 0.5
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
        
        coachMarksController.delegate = self
        coachMarksController.dataSource = self
        coachMarksController.overlay.backgroundColor = .black.withAlphaComponent(0.6)
        coachMarksController.overlay.isUserInteractionEnabled = true
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        coachMarksController.start(in: .currentWindow(of: self))
//
//    }
    
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
        guard let bolts = bolts,let results = results,let railLength = railLength,let railEx = railEx else{return}
        
       
        let contentWidth = CGFloat(railLength + 200)
        self.drawingViewWidth.constant = contentWidth
        self.scrollView.contentSize = CGSize(width: contentWidth, height: 1000)
        scrollView.minimumZoomScale = scrollView.frame.width / contentWidth
//        print(scrollView.contentSize.width,contentWidth,scrollView.frame.width, (scrollView.contentSize.width - scrollView.frame.width) / 2)
        boxView.removeFromSuperview()
        for label in labels {
            label.removeFromSuperview()
            self.labels.removeFirst()
        }
        boxView = UIView()
        boxView.tag = bolts.count * 2 + 1
        let maxHole = bolts.max { hole, hole1 in
            hole.diameter < hole1.diameter
        }?.diameter ?? 100.0
//        let boxHeight = maxHole + 30.0 + (railHeight ?? 0)
        let boxHeight = 30
        boxView.backgroundColor = .gray
        boxView.translatesAutoresizingMaskIntoConstraints = false
        self.drawingView.addSubview(boxView)
        boxView.widthAnchor.constraint(equalToConstant: CGFloat(railLength)).isActive = true
        boxView.heightAnchor.constraint(equalToConstant: CGFloat(boxHeight)).isActive = true
        boxView.centerXAnchor.constraint(equalTo: drawingView.centerXAnchor).isActive = true
        boxView.centerYAnchor.constraint(equalTo: drawingView.centerYAnchor).isActive = true
        addPipeLabel()

        let zoomScale = scrollView.frame.width / CGFloat(railLength + 20.0)
        scrollView.setZoomScale(zoomScale, animated: true)
        let posx = (contentWidth * zoomScale - scrollView.frame.width) / 2
        let x = posx *  scrollView.frame.width / contentWidth / zoomScale
        
        scrollView.setContentOffset(CGPoint(x: posx, y: (scrollView.contentSize.height - scrollView.frame.height) / 2), animated: true)

        var i = 1
        
        
        for (bolt,result) in zip(bolts,results){
            let pipeView = UIView()
            pipeView.layer.borderColor = UIColor.green.cgColor
            pipeView.layer.borderWidth = 0.5
            
            pipeView.backgroundColor = .clear
            boxView.addSubview(pipeView)
            pipeView.translatesAutoresizingMaskIntoConstraints = false
            pipeView.widthAnchor.constraint(equalToConstant: CGFloat(bolt.diameter)).isActive = true
            pipeView.heightAnchor.constraint(equalToConstant: CGFloat(boxHeight + 50)).isActive = true
            pipeView.centerXAnchor.constraint(equalTo: boxView.leadingAnchor, constant: CGFloat((result.x0 + result.x1) / 2)).isActive = true
            pipeView.centerYAnchor.constraint(equalTo:boxView.bottomAnchor,constant: CGFloat(-result.y)).isActive = true
            
            
            let holeView = UIView()
            holeView.layer.borderColor = UIColor.green.cgColor
            holeView.layer.borderWidth = 0.5
            holeView.backgroundColor = .white
            boxView.addSubview(holeView)
            holeView.translatesAutoresizingMaskIntoConstraints = false
            holeView.widthAnchor.constraint(equalToConstant: CGFloat(uBoltsDiameter)).isActive = true
            holeView.heightAnchor.constraint(equalToConstant: CGFloat(uBoltsDiameter)).isActive = true
            holeView.centerXAnchor.constraint(equalTo: boxView.leadingAnchor, constant: CGFloat(result.x0)).isActive = true
            holeView.centerYAnchor.constraint(equalTo:boxView.bottomAnchor,constant: CGFloat(-result.y)).isActive = true
            holeView.cornerRadius = CGFloat(uBoltsDiameter / 2)
            let gesture0 = UITapGestureRecognizer(target: self, action: #selector(didSelectHole))
            holeView.addGestureRecognizer(gesture0)
            holeView.tag = i
            i += 1
            let holeView1 = UIView()
            holeView1.layer.borderColor = UIColor.green.cgColor
            holeView1.layer.borderWidth = 0.5
            holeView1.backgroundColor = .white
            boxView.addSubview(holeView1)
            holeView1.translatesAutoresizingMaskIntoConstraints = false
            holeView1.widthAnchor.constraint(equalToConstant: CGFloat(uBoltsDiameter)).isActive = true
            holeView1.heightAnchor.constraint(equalToConstant: CGFloat(uBoltsDiameter)).isActive = true
            holeView1.centerXAnchor.constraint(equalTo: boxView.leadingAnchor, constant: CGFloat(result.x1)).isActive = true
            holeView1.centerYAnchor.constraint(equalTo:boxView.bottomAnchor,constant: CGFloat(-result.y)).isActive = true
            holeView1.cornerRadius = CGFloat(uBoltsDiameter / 2)
            let gesture1 = UITapGestureRecognizer(target: self, action: #selector(didSelectHole))
            holeView1.addGestureRecognizer(gesture1)
            holeView1.tag = i
            i += 1
        }

        self.tableView.reloadData()
        
        let tutorialIsShown = UserDefaults.standard.bool(forKey: "tutorial")
        
        if !(tutorialIsShown){
        self.coachMarksController.start(in: .currentWindow(of: self))
        }
        
    }
    
    
    @objc func didSelectHole(sender:UITapGestureRecognizer){
        if let tag = sender.view?.tag{
            let index = tag - 1
            
            self.tableView.selectRow(at: IndexPath(row: Int((tag-1) / 2), section: 0), animated: false, scrollPosition: .top)
            guard let sender = sender.view else{return}
            let lineWidth :CGFloat = 1.0
            let midY  = (sender.center.y  +  boxView.frame.minY + boxView.frame.maxY) / 2
            let isOver = midY - 40 / 2  + 40 > boxView.frame.maxY ? true : false
            if self.calcMode == 0{
                addLine(fromX:sender.center , toX: CGPoint(x:lineWidth / 2 , y: sender.frame.midY), fromY: sender.center, toY: CGPoint(x:sender.center.x,y: boxView.frame.height - lineWidth / 2), isOver: isOver)
            }else if self.calcMode == 1{
                if index == 0{
                    addLine(fromX:sender.center , toX: CGPoint(x:lineWidth / 2 , y: sender.frame.midY), fromY: sender.center, toY: CGPoint(x:sender.center.x,y: boxView.frame.height - lineWidth / 2), isOver: isOver)
                }else{
                    //二番目以降の穴
                    guard let sender2 = drawingView.viewWithTag(index) else{return}
                    addLine(fromX:sender.center , toX: CGPoint(x:lineWidth / 2 + sender2.center.x , y: sender.frame.midY), fromY: sender.center, toY: CGPoint(x:sender.center.x,y: boxView.frame.height - lineWidth / 2), isOver: isOver)
                }
            }
            addLabel(index: index, sender: sender)
            
        }
        
    }
    
    func addPipeLabel(){
        guard let bolts = bolts,let results = results else{return}
        let lineTopY :CGFloat = -20 + boxView.frame.minY
        let zoomScale = scrollView.zoomScale

        for label in pipeLabels{
            label.removeFromSuperview()
        }
        
        for (bolt,result) in zip(bolts,results){
            let pipeLabel = UILabel()
            pipeLabel.tag = 0
            pipeLabel.textAlignment = .center
            pipeLabel.adjustsFontSizeToFitWidth = true
            pipeLabel.text = bolt.name
            
            self.drawingView.addSubview(pipeLabel)
            self.pipeLabels.append(pipeLabel)
            let xx :CGFloat  = CGFloat((result.x0 + result.x1) / 2) + boxView.frame.minX
//                    xy = boxView.frame.minY + sender.center.y - height + 5
            let xy = lineTopY
            pipeLabel.frame.size = CGSize(width: 100 / zoomScale, height: 40 / zoomScale)
            pipeLabel.font = .systemFont(ofSize: 17 / zoomScale )
            pipeLabel.frame.origin = CGPoint(x: xx - 50 / zoomScale, y: xy - 40 / zoomScale)
            
        }
    }
    func addLabel(index:Int,sender:UIView){
        addPipeLabel()
        let zoomScale = scrollView.zoomScale
        guard let results = results else{return}
        for label in labels {
            label.removeFromSuperview()
            self.labels.removeFirst()
        }
        displayLabel = [:]
        displayLabel[index] = true
        self.tableView.reloadData()
            
            
            let labelX = UILabel()
            labelX.tag = 0
            labelX.numberOfLines = 0
            labelX.textAlignment = .center
            labelX.adjustsFontSizeToFitWidth = true
            
            let width :CGFloat = 100
            let height :CGFloat = 40
            //            print(sender.center.x,boxView.frame.minX)
            var xx :CGFloat
            var xy :CGFloat
            let lineTopY :CGFloat = -10 + boxView.frame.minY
            let isX0 = index % 2 == 0 ? true : false
        
        if results.count <= Int(index / 2){
            labelX.text = String(railLength ?? 100)
            xx = boxView.frame.minX + boxView.frame.maxX / 2
            xy = lineTopY
            labelX.frame.size = CGSize(width: 100 / zoomScale, height: 40 / zoomScale)
            labelX.font = .systemFont(ofSize: 17 / zoomScale )
            labelX.sizeToFit()
            labelX.frame.origin = CGPoint(x: xx - labelX.frame.width / 2, y: xy - labelX.frame.height)
            self.labelXPosition = CGPoint(x: xx, y: xy)
            self.drawingView.addSubview(labelX)
            self.labels.append(labelX)
            return
        }else{
            let result = results[Int(index / 2)]
            if calcMode == 0{
                labelX.text = isX0 ?  String(result.x0) : String(result.x1)
                xx  = (sender.center.x + 2 * boxView.frame.minX) / 2 - width / 2
                //                xy = boxView.frame.minY + sender.center.y - height + 5
                xy = lineTopY
                
                labelX.frame.size = CGSize(width: 100 / zoomScale, height: 40 / zoomScale)
                labelX.font = .systemFont(ofSize: 17 / zoomScale )
                labelX.sizeToFit()
                labelX.frame.origin = CGPoint(x: (sender.center.x + 2 * boxView.frame.minX) / 2 - labelX.frame.width / 2, y: xy - labelX.frame.height)
                self.labelXPosition = CGPoint(x: (sender.center.x + 2 * boxView.frame.minX) / 2, y: xy)
            }else{
                
                labelX.text = isX0 ? String(result.interval0) : String(result.interval1)
                
                let lineTopY :CGFloat = -10 + boxView.frame.minY
                
                if index == 0{
                    xx  = (sender.center.x + 2 * boxView.frame.minX) / 2 - width / 2
                    //                    xy = boxView.frame.minY + sender.center.y - height + 5
                    xy = lineTopY
                    labelX.frame.size = CGSize(width: 100 / zoomScale, height: 40 / zoomScale)
                    labelX.font = .systemFont(ofSize: 17 / zoomScale )
                    labelX.frame.origin = CGPoint(x: (sender.center.x + 2 * boxView.frame.minX) / 2 - 50 / zoomScale, y: xy - 40 / zoomScale)
                    self.labelXPosition = CGPoint(x: (sender.center.x + 2 * boxView.frame.minX) / 2, y:xy)
                    
                }else{
                    
                    guard let sender2 = drawingView.viewWithTag(index) else{
                        xx  = (sender.center.x + boxView.frame.minX) / 2 - width / 2
                        xy = boxView.frame.minY + sender.center.y - height + 5
                        return
                    }
                    xx  = (sender.center.x + 2 * boxView.frame.minX + sender2.center.x) / 2 - width / 2
                    //                    xy = boxView.frame.minY + sender.center.y - height + 5
                    xy = lineTopY
                    labelX.frame.size = CGSize(width: 100 / zoomScale, height: 40 / zoomScale)
                    labelX.font = .systemFont(ofSize: 17 / zoomScale )
                    labelX.frame.origin = CGPoint(x: (sender.center.x + sender2.center.x + 2 * boxView.frame.minX) / 2 - 50 / zoomScale, y: xy - 40 / zoomScale)
                    
                    self.labelXPosition = CGPoint(x: (sender.center.x + sender2.center.x + 2 * boxView.frame.minX) / 2, y: xy)
                    
                }
            }
            
            self.drawingView.addSubview(labelX)
            self.labels.append(labelX)
            
//            let labelY = UILabel()
//            labelY.tag = 1
//            labelY.textAlignment = .left
//            labelY.adjustsFontSizeToFitWidth = true
//            labelY.text = String(result.y)
//            //            print(sender.center.x,boxView.frame.minX)
//            let yx  = boxView.frame.minX + sender.center.x + 5
//            let midY  = (sender.center.y  +  boxView.frame.minY + boxView.frame.maxY) / 2
//            let yy = midY - height / 2  + height > boxView.frame.maxY ? boxView.frame.maxY : midY - height / 2
//            labelY.frame = CGRect(x:yx  , y: yy , width: width, height: height)
//            
//            labelY.frame.size = CGSize(width: 100 / zoomScale, height: 40 / zoomScale)
//            labelY.font = .systemFont(ofSize: 17 / zoomScale )
//            
//            //倍率によってポジション調整
//            if  midY - height / 2  + height > boxView.frame.maxY{
//                self.labelYPosition = CGPoint(x: yx, y: boxView.frame.maxY)
//                labelY.frame.origin = CGPoint(x: yx, y: boxView.frame.maxY + 20 * (1 - 1 / zoomScale))
//            }else{
//                self.labelYPosition = CGPoint(x: yx, y: midY)
//                labelY.frame.origin = CGPoint(x: yx, y: midY - 20 / zoomScale)
//            }
//            //倍率によってポジション調整(ここまで)
//            
//            self.drawingView.addSubview(labelY)
//            self.labels.append(labelY)
//            
        }
    }
    func didSelectRow(indexPath:IndexPath){
        guard let sender = drawingView.viewWithTag(indexPath.row + 1) else{return}
        let lineWidth :CGFloat = 1.0
        let midY  = (sender.center.y  +  boxView.frame.minY + boxView.frame.maxY) / 2
        let isOver = midY - 40 / 2  + 40 > boxView.frame.maxY ? true : false
        if self.calcMode == 0{
            addLine(fromX:sender.center , toX: CGPoint(x:lineWidth / 2 , y: sender.frame.midY), fromY: sender.center, toY: CGPoint(x:sender.center.x,y: boxView.frame.height - lineWidth / 2), isOver: isOver)
        }else if self.calcMode == 1{
            if indexPath.row == 0{
                addLine(fromX:sender.center , toX: CGPoint(x:lineWidth / 2 , y: sender.frame.midY), fromY: sender.center, toY: CGPoint(x:sender.center.x,y: boxView.frame.height - lineWidth / 2), isOver: isOver)
            }else{
                //二番目以降の穴
                guard let sender2 = drawingView.viewWithTag(indexPath.row) else{return}
                addLine(fromX:sender.center , toX: CGPoint(x:lineWidth / 2 + sender2.center.x , y: sender.frame.midY), fromY: sender.center, toY: CGPoint(x:sender.center.x,y: boxView.frame.height - lineWidth / 2), isOver: isOver)
            }
        }
        addLabel(index: indexPath.row, sender: sender)
    }
    
    func addLine(fromX:CGPoint,toX:CGPoint,fromY:CGPoint,toY:CGPoint,isOver:Bool){
        
        let arrow = UIBezierPath()
//        if calcMode == 0{
//        arrow.addArrow(start: fromX, end: toX, pointerLineLength: 10, arrowAngle: CGFloat(Double.pi / 6), lineWidth: 1.0,isOver: false)
//        }else if calcMode == 1{
            print(self.boxView.frame.minY)
            let lineTopY :CGFloat = -10
            arrow.addArrowIntervalPipes(start: fromX, end: toX, lineTopY: lineTopY, pointerLineLength: 5, arrowAngle: CGFloat(Double.pi / 6), lineWidth: 1.0)
//        }
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
        if let results = self.results{
            return results.count + 1
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell") as! ResultTableViewCell
        cell.delegate = self
        cell.ymmLabel.isHidden = false
        cell.xEyeImage.isHidden = true
        cell.yEyeImage.isHidden = true
        cell.yShadowView.isHidden = false
        
        if displayLabel[indexPath.row * 2] == true{
            cell.xEyeImage.isHidden = false
        }else if displayLabel[indexPath.row  * 2 + 1] == true{
            cell.yEyeImage.isHidden = false
        }
        if results?.count ?? 0 > indexPath.row{
        if let bolt = bolts?[indexPath.row],let result = results?[indexPath.row]{
            if self.calcMode == 0 {
                cell.nameLabel.text = bolt.name
                
                cell.xpositionLabel.text = String(result.x0.floorNum())
                cell.ypositionLabel.text = String(result.x1.floorNum())
                cell.xShadowView.tag = indexPath.row * 2
                cell.yShadowView.tag = indexPath.row * 2 + 1
            }else{
                cell.nameLabel.text = bolt.name
                cell.xpositionLabel.text = String(result.interval0.floorNum())
                cell.ypositionLabel.text = String(result.interval1.floorNum())
                cell.xShadowView.tag = indexPath.row * 2
                cell.yShadowView.tag = indexPath.row * 2 + 1
            }
        }
            return cell
        }else{
            cell.ypositionLabel.text = nil
            if let railLength = self.railLength{
                cell.nameLabel.text = "レール全長"
                
                cell.xpositionLabel.text = "\(railLength.floorNum())"
                cell.ymmLabel.isHidden = true
                cell.yShadowView.isHidden = true
                cell.xShadowView.tag = indexPath.row * 2
            }
            return cell
        }
        
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
        
        for label in labels {
            
            label.frame.size = CGSize(width: 100 / scale, height: 40 / scale)
            label.font = .systemFont(ofSize: 17 / scale )
            if let labelXPosition = self.labelXPosition,label.tag == 0{
                label.sizeToFit()
                label.frame.origin = CGPoint(x: labelXPosition.x - label.frame.width / 2, y: labelXPosition.y - label.frame.height)
            }else if let labelYPosition = self.labelYPosition,label.tag == 1{
                if labelYPosition.y == boxView.frame.maxY{
                    label.frame.origin = CGPoint(x: labelYPosition.x, y: boxView.frame.maxY + 20 * (1 - 1 / scale))
                }else{
                    label.frame.origin = CGPoint(x: labelYPosition.x, y: labelYPosition.y - 20 / scale)
                }
            }
        }
        
//        print(scale)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset)
    }
}

extension ResultViewController:CoachMarksControllerDelegate,CoachMarksControllerDataSource{
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        //吹き出しのビューを作成します
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(
            withArrow: true,
            withNextText: true,
            arrowOrientation: coachMark.arrowOrientation    //矢印の向き(吹き出しの位置)
        )
        
        coachViews.bodyView.nextLabel.backgroundColor = .systemGreen
        coachViews.bodyView.nextLabel.textColor = .white
        coachViews.bodyView.nextLabel.cornerRadius = 5
        coachViews.bodyView.nextLabel.font = .boldSystemFont(ofSize: 17)
        //index(ステップ)によって表示内容を分岐させます
        switch index {
        case 0:    //tableView
            coachViews.bodyView.hintLabel.text = "ここに計算結果が表示されています。タップするとその寸法が上図に表示されます。"
            coachViews.bodyView.nextLabel.text = "OK"
            
            
        
        case 1:    //boxView
        coachViews.bodyView.hintLabel.text = "この図はBOXを表しています。配管をタップするとその寸法が表示されます。"
            coachViews.bodyView.nextLabel.text = "OK"
        
        case 2:    //piyoSwitch
            coachViews.bodyView.hintLabel.text = "このスイッチで設定を切り替えられます"
            coachViews.bodyView.nextLabel.text = "了解"
        
        default:
            break
        
        }
        
        //その他の設定が終わったら吹き出しを返します
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        //基本的にはチュートリアルの対象にしたいボタンやビューをチュートリアルの順にArrayに入れ、indexで指定する形がいいかなと思います(もっといい方法があったら教えてください)
        let highlightViews: Array<UIView> = [self.tableView, boxView]
        //チュートリアルで使うビューの中からindexで何ステップ目かを指定
        return coachMarksController.helper.makeCoachMark(for: highlightViews[index])
        

    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, didShow coachMark: CoachMark, afterChanging change: ConfigurationChange, at index: Int) {
        if index == 0{
            self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
            self.didSelectRow(indexPath: IndexPath(row: 0, section: 0))
        }
    }
    func coachMarksController(_ coachMarksController: CoachMarksController, didHide coachMark: CoachMark, at index: Int) {
        if index == 1{
            UserDefaults.standard.set(true, forKey: "tutorial")
        }
    }
}
