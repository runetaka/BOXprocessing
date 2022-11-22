//
//  Utility.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/09/10.
//

import Foundation
import UIKit
//import Nuke
//import Firebase

@IBDesignable

extension UIView{
    
    /// 角丸の大きさ
    @IBInspectable var cornerRadius: CGFloat {
      get {
        layer.cornerRadius
      }
      set {
        layer.cornerRadius = newValue
        layer.masksToBounds = newValue > 0
      }
    }
    @IBInspectable var shadowOffset: CGSize {
      get {
        layer.shadowOffset
      }
      set {
        layer.shadowOffset = newValue
      }
    }
    /// 影の色
     @IBInspectable var shadowColor: UIColor? {
       get {
         layer.shadowColor.map { UIColor(cgColor: $0) }
       }
       set {
         layer.shadowColor = newValue?.cgColor
         layer.masksToBounds = false
       }
     }

}

extension UIPickerView {
    
    func setLabelAtCenter(label:UILabel){
        label.adjustsFontSizeToFitWidth = true
        let fontSize:CGFloat = 26
        let labelWidth:CGFloat = self.frame.size.width / 2
        let x:CGFloat = self.frame.width / 4 + labelWidth / 3
//        let x = self.frame.midX  - labelWidth / 2
//        let x = self.frame.width / 2
//        print(x)
        print(self.frame)
        let y:CGFloat = (self.frame.size.height / 2) - (fontSize / 2)
        
        label.frame = CGRect(x:x,y: y,width:labelWidth  ,height:fontSize)
        label.textAlignment = .center
        label.backgroundColor = .clear
        self.addSubview(label)
//        print(label.frame.midX)
        print(label.frame)
        
    }
}

extension URL {

    var queryParams: [String: String] {
        var params: [String: String] = [:]
        guard let comps = URLComponents(string: absoluteString), let queryItems = comps.queryItems else { return params }
        for queryItem in queryItems {
            params[queryItem.name] = queryItem.value
        }
        return params
    }
}
extension NSLayoutConstraint {
    func setMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem!,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = shouldBeArchived
        newConstraint.identifier = identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

extension Array {
    subscript (element index: Index) -> Element? {
        //　MARK: 配列の要素以上を指定していたらnilを返すようにする
        indices.contains(index) ? self[index] : nil
    }
}

//class GalleryDelegate: GalleryItemsDataSource {
//
//
//
////    private let items: [GalleryItem]
//    private let item :GalleryItem
//
//    init(image:UIImage){
//
//        item = GalleryItem.image(fetchImageBlock: { imageCompletion in
//            imageCompletion(image)
//        })
//    }
    // 一応ギャラリーとしても使えるように複数のURL読み込みに対応してます。
//    init(imageMessages: [Message]) {
//        items = imageMessages.reduce(into: [GalleryItem]()) { partialResult, message in
//            guard let urlString = message.imageURL else{return}
//            let url = URL(string: urlString)
//            let galleryItem = GalleryItem.image { imageCompletion in
//                ImagePipeline.shared.loadImage(with: url, progress: nil, completion: { result in
//                    switch result{
//                    case .success(let response):
//                        imageCompletion(response.image)
//
//                    case .failure(let error):
//                        print(error)
//                    }
//                })
//            }
//            partialResult.append(galleryItem)
//
//        }
//    }
    
    func itemCount() -> Int {
//        return items.count
        return 1
    }
    
//    func provideGalleryItem(_ index: Int) -> GalleryItem {
//        return item
//
//    }
//}
//
//extension UIImageView: DisplaceableView {}

extension UIImageView {
    func transformByImage(rect : CGRect) -> CGRect? {
        guard let image = self.image else { return nil }
        let imageSize = image.size
        let imageOrientation = image.imageOrientation
        let selfSize = self.frame.size

        let scaleWidth = imageSize.width / selfSize.width
        let scaleHeight = imageSize.height / selfSize.height

        var transform: CGAffineTransform

        switch imageOrientation {
        case .left:
            transform = CGAffineTransform(rotationAngle: .pi / 2).translatedBy(x: 0, y: -image.size.height)
        case .right:
            transform = CGAffineTransform(rotationAngle: -.pi / 2).translatedBy(x: -image.size.width, y: 0)
        case .down:
            transform = CGAffineTransform(rotationAngle: -.pi).translatedBy(x: -image.size.width, y: -image.size.height)
        default:
            transform = .identity
        }

        transform = transform.scaledBy(x: scaleWidth, y: scaleHeight)

        return rect.applying(transform)
    }
}


extension UITextView {
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}


//extension Timestamp{
//    
//    func age() -> Int{
//        let now = Date()
//        let ageMillSec = now.timeIntervalSince(self.dateValue())
//        
//        let ageFloat = ageMillSec/(60*60*24*365.24)
//        let age = Int(ageFloat)
//        return age
//    }
//}
//
//extension Int{
//    func toTimestamp() -> Timestamp{
//        //現在からInt年前のTimestamp
//        let date = Date()
//        let addingInt = -self
//        guard let addedDate =  Calendar.current.date(byAdding: .year, value: addingInt, to: date) else{return Timestamp()}
//        print("addedDate",addedDate)
//        return Timestamp(date: addedDate)
//    }
//    func ageMillSec() -> Int{
//        let date = Date()
//        let addingInt = -self
//        guard let addedDate =  Calendar.current.date(byAdding: .year, value: addingInt, to: date) else{return 0}
//        return Int(addedDate.timeIntervalSince1970 * 1000)
//    }
//}

extension UINavigationController{
    func popViewController(animated: Bool, completion: @escaping (() -> Void)) {
        popViewController(animated: animated)
        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                // coordinatorで実行するanimationの完了時にcompletionが実行されます
                // 本メソッドにおいてcontextが同じanimationはpopViewControllerのため
                // pop完了後に本メソッドが実行されます
                completion()
            }
        } else {
            completion()
        }
    }
}

extension UINavigationController {
 
   override open var childForStatusBarStyle : UIViewController? {
        return topViewController
    }

    override open var childForStatusBarHidden: UIViewController? {
        return topViewController
    }

}

extension UIViewController {
    
    func setupNavigaitonBar(color : UIColor){
        if #available(iOS 15.0, *) {
            //navigationBarの線の削除と背景色を白に設定
            let navigationBar = navigationController?.navigationBar
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.backgroundColor = color
            navigationBarAppearance.shadowColor = .clear
            navigationBar?.scrollEdgeAppearance = navigationBarAppearance
        }else{
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
    }
   
}

extension String{
    func removingWhiteSpace() -> String {
        let whiteSpaces: CharacterSet = [" ", "　"]
        return self.trimmingCharacters(in: whiteSpaces)
    }
}

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
    
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let v = Int("000000" + hex, radix: 16) ?? 0
        let r = CGFloat(v / Int(powf(256, 2)) % 256) / 255
        let g = CGFloat(v / Int(powf(256, 1)) % 256) / 255
        let b = CGFloat(v / Int(powf(256, 0)) % 256) / 255
        self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0), 1))
    }
    func adjustBrightness(ratio : CGFloat) -> UIColor{
        var hue : CGFloat = 0.0
        var saturation : CGFloat = 0.0
        var brightness : CGFloat = 0.0
        var alpha : CGFloat = 1.0
        if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha){
            return UIColor(hue: hue, saturation: saturation, brightness: brightness * ratio, alpha: alpha)
        }else{return self}
        
    }
    
}


extension UITableViewCell {

    @IBInspectable
    var selectedBackgroundColor: UIColor? {
        get {
            return selectedBackgroundView?.backgroundColor
        }
        set(color) {
            let background = UIView()
            background.backgroundColor = color
            selectedBackgroundView = background
        }
    }

}
