//
//  Job.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/12/27.
//

import Foundation


class Job{
    var companyName : String?
    var title:String?
    var context :String?
    var area: String?
    var salary : String?
    
    
    init(dic:[String:Any]){
        self.companyName = dic["name"] as? String
        self.title = dic["title"] as? String
        self.context = dic["context"] as? String
        self.area = dic["area"] as? String
        self.salary = dic["salary"] as? String
    }
}
