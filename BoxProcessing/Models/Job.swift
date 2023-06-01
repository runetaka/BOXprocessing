//
//  Job.swift
//  BoxProcessing
//
//  Created by 池島孝浩 on 2022/12/27.
//

import Foundation


class Job:Equatable,Codable{
    static func == (lhs: Job, rhs: Job) -> Bool {
       return lhs.jobId == rhs.jobId
    }
    
    var jobId : String
    var companyName : String?
    var title:String?
    var context :String?
    var area: String?
    var salary : String?
    var companyImages : [String]?
    
    enum CodingKeys: String, CodingKey {
            case jobId,companyName,title,context,area,salary,companyImages
        
            
        }
    
    init(dic:[String:Any]){
        self.jobId = dic["jobId"] as? String ?? ""
        self.companyName = dic["name"] as? String
        self.title = dic["title"] as? String
        self.context = dic["context"] as? String
        self.area = dic["area"] as? String
        self.salary = dic["salary"] as? String
        self.companyImages = dic["companyImages"] as? [String]
        
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            if let jobId = try? values.decode(String.self, forKey: .jobId){
                self.jobId = jobId
            }else{
                self.jobId = ""
            }
            if let companyName = try? values.decode(String.self, forKey: .companyName){
                self.companyName = companyName
            }else{
                self.companyName = ""
            }
            if let title = try? values.decode(String.self,forKey: .title){
                self.title = title
            }else{
                self.title = ""
            }
            if let context = try? values.decode(String.self, forKey: .context){
                self.context = context
            }else{
                self.context = ""
            }
            if let area = try? values.decode(String.self, forKey: .area){
                self.area = area
            }else{
                self.area = ""
            }
            if let salary = try? values.decode(String.self, forKey: .salary){
                self.salary = salary
            }else{
                self.salary = "100万円以下"
            }
            if let companyImages = try? values.decode([String].self, forKey: .companyImages){
                self.companyImages = companyImages
            }else{
                self.companyImages = []
            }
        }
    }
}
