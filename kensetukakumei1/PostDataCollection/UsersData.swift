//
//  UsersData.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/26.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//

import UIKit
import Firebase

class UsersData : NSObject{
    var id: String
    var imageNo: Int = 0
    var name: String? = ""
    var age: String? = ""
    var area: String? = ""
    var companyName: String? = ""
    var qualification: String? = ""
    var typeOfWork: String? = ""
    var yearsEx: String? = ""
    var chatRoom: [String:String]? = [:]
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID
        
        let postdic = document.data()
        
        if let imageNo = postdic["imageNo"] as? Int {
            self.imageNo = imageNo
        }
        
        self.name = postdic["name"] as? String
        
        self.age = postdic["age"] as? String
        
        self.area = postdic["area"] as? String
        
        self.companyName = postdic["companyName"] as? String
        
        self.qualification = postdic["qualification"] as? String
        
        self.typeOfWork = postdic["typeOfWork"] as? String
        
        self.yearsEx = postdic["yearsEx"] as? String
        
        self.chatRoom = postdic["chatRoom"] as? [String:String]
        
    }
}
