//
//  PostUkeoiData.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/20.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//

import UIKit
import Firebase

class PostUkeoiData: NSObject{
    var id: String
    var imageNo: Int = 0
    var name: String? = ""
    var userID: String? 
    var age: String? = ""
    var area: String? = ""
    var date: Date?
    var comment: String? = ""
    var companyName: String? = ""
    var qualification: String? = ""
    var typeOfWork: String? = ""
    var yearsEx: String? = ""
    var start: String? = ""
    var end: String? = ""
    var conditions: String? = ""
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID
        
        let postdic = document.data()
        
        if let imageNo = postdic["imageNo"] as? Int {
            self.imageNo = imageNo
        }
        self.name = postdic["name"] as? String
        
        self.userID = postdic["userID"] as? String
        
        self.age = postdic["age"] as? String
        
        self.area = postdic["area"] as? String
        
        let timestamp = postdic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
        
        self.comment = postdic["comment"] as? String
        
        self.companyName = postdic["companyName"] as? String
        
        self.qualification = postdic["qualification"] as? String
        
        self.typeOfWork = postdic["typeOfWork"] as? String
        
        self.yearsEx = postdic["yearsEx"] as? String
        
        self.start = postdic["start"] as? String
        
        self.end = postdic["end"] as? String
        
        self.conditions = postdic["conditions"] as? String
    }
}
