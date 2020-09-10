//
//  PostDeaiData.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/19.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//


import UIKit
import Firebase

class PostDeaiData : NSObject{
    var id: String
    var imageNo: Int = 0
    var name: String? = ""
    var userID: String? 
    var date : Date?
    var comment: String? = ""
    var likes: [String] = []
    var isLiked: Bool = false
    var postName: [String]?
    var returnComment : [String]?
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID
        
        let postdic = document.data()
        
        if let imageNo = postdic["imageNo"] as? Int {
            self.imageNo = imageNo
        }
        
        self.name = postdic["name"] as? String
        
        self.userID = postdic["userID"] as? String
        
        self.comment = postdic["comment"] as? String
        
        let timestamp = postdic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
        
        if let likes = postdic["likes"] as? [String]{
            self.likes = likes
            
        }
        if let myid = Auth.auth().currentUser?.uid{
            //likesの配列の中にmyidが含まれているかチェックする事で、自分がいいねを押しているかを判断
            if self.likes.firstIndex(of: myid) != nil{
                //myidがあれば、言い値を押していると認識する。
                self.isLiked = true
            }
            
        }
        if let postname = postdic["postname"] as? [String]{
            self.postName = postname
        }
        if let returnComment = postdic["returnComment"] as? [String]{
            self.returnComment = returnComment
            
        }
    }
}
