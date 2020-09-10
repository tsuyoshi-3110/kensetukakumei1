//
//  ChatListData.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/24.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//

import UIKit
import Firebase

class ChatRoomData: NSObject{
    
    var id: String
    var chatRoomId: String? = ""
    var chatMessage: String? = ""
    var senderId: String? = ""
    var senderImageNo: Int? = 0
    var senderImageId: String? = ""
    var senderName: String? = ""
    var date: Date?
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID
        
        let postDic = document.data()
        
        self.chatRoomId = postDic["chatRoomId"] as? String
        
        self.chatMessage = postDic["chatMessage"] as? String
        
        self.senderId = postDic["senderId"] as? String
        
        if let senderImageNo = postDic["senderImageNo"] as? Int {
            self.senderImageNo = senderImageNo
        }
        
        self.senderImageId = postDic["senderImageId"] as? String
        
        self.senderName = postDic["senderName"] as? String
        
        let timestamp = postDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
    }
}
