//
//  SearchQuery.swift
//  GroupMatching
//
//  Created by 中島英輔 on 2022/05/08.
//

import Foundation
import FirebaseCore

class SearchQuery{
    var freeWords : [String]?
    
    var sex:String?
    var area:String?
    var minAge:Int?
    var maxAge:Int?
    var memberNum:Int?
    var hashTags : [String]?
    
    init(dic:[String:Any]){
        self.freeWords = dic["freeWords"] as? [String] ?? []
        self.sex = dic["sex"] as? String ?? nil
        self.area = dic["area"] as? String ?? nil
        self.minAge = dic["minAge"] as? Int ?? nil
        self.maxAge = dic["maxAge"] as? Int ?? nil
        self.memberNum = dic["memberNum"] as? Int ?? nil
        self.hashTags = dic["hashTags"] as? [String] ?? []
    }
    func toDictionary() -> [String:Any]{
        let dic = ["sex":self.sex,"area":self.area,"minAge":self.minAge,"maxAge":self.maxAge,"memberNum":self.memberNum,"hashTags":self.hashTags] as [String : Any]
        return dic
    }
}

class  PostQuery :SearchQuery{

    var datingAt : [String]? //Firestoreでの検索に必要 whereField("datingAt", in: [dateStrings])
    var datingAtDic : [String:Date]?
    var isClosed : Bool
    
    init(){
        self.isClosed = false
//        self.numberOfMembers = 2
        super.init(dic: [:])
    }
    override init(dic:[String:Any]){
        self.isClosed = false
        super.init(dic: dic)
    }
    
    init(searchQuery:SearchQuery){
        self.isClosed = false
        super.init(dic: searchQuery.toDictionary())
    }
}
