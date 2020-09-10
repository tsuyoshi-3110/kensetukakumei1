//
//  PostData.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/10.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//

import UIKit
import Firebase

class ProfileData : NSObject{
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
    var chatRoomId: [String:String]? = [:]
    
    init(document: DocumentSnapshot) {
        self.id = document.documentID
        
        guard let postdic = document.data() else { return }
        
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
        
        self.chatRoomId = postdic["chatRoomId"] as? [String:String]
    }
}

