//
//  FiledValue.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/09/12.
//

import Foundation


class FieldValue{
    
    let fieldName: String
    var value:Float?
    var stringValue : String?
    
    init(fieldName:String){
        self.fieldName = fieldName
    }
}
