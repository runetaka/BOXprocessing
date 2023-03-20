//
//   Hole.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/09/10.
//

import Foundation


class Hole {
    
    
    var diameter : Float = 16.0
    var name : String = "G16"
    
    init(name:String){
        self.name = name
    }
    
}

class UBolts{
    var Plist : [String:Float] = ["10A":28,"15A":34,"20A":40,"25A":46,"32A":56,"40A":62,"50A":74,"65A":88,"80A":101,"90A":115,"100A":126,"125A":152,"150A":180]
    var name : String = "10A"
    var diameter : Float = 17.3
    var P : Float = 28.0
    
    init(name: String) {
        self.name = name
        self.P = Plist[name] ?? 28
    }
}

class Diameter{
    
    var g:G?
    
    enum G :CaseIterable{
        case G16
        case G22
        case G28
        case G36
        
        
        var name:String{
            switch self{
            case .G16: return "G16"
            case .G22: return "G22"
            case .G28: return "G28"
            case .G36: return "G36"
            }
        }
        
        var value :Float{
            switch self{
            case .G16: return 16.0
            case .G22: return 22.0
            case .G28: return 28.0
            case .G36: return 36.0
            }
        }
        
        init(type:Int){
            switch(type){
            case 0:
                self = G.G16
            case 1:
                self = G.G22
            case 2:
                self = G.G28
            case 3:
                self = G.G36
            case 4:
                self = G.G16
            default:
                self = G.G16
            }
        }
        
        }
    
    init(type:Int,kind:String){
        if kind == "厚鋼"{
            let g = G.init(type: type)
            self.g = g
        }
    }
    
        
    }

class Result{
    var x0 : Float
    var x1 : Float
    var y : Float
    var interval0 : Float
    var interval1 : Float
    
    init(x0:Float,x1:Float,y:Float,interval0: Float){
        self.x0 = x0
        self.x1 = x1
        self.y = y
        self.interval0 = interval0
        self.interval1 = x1 - x0
    }
}
