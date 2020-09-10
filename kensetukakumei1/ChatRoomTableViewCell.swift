//
//  ChatRoomTableViewCell.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/30.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase
import SVProgressHUD

class ChatRoomTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
         profileImage.layer.cornerRadius = 5
           profileImage.clipsToBounds = true
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func setChatRoomData(_ postData: ChatRoomData){
       
        //画像の表示
        profileImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ProfileImagePath).child(String(postData.senderId!) + "_" + String(postData.senderImageNo!) + ".jpg")
        print("imageRefの値は、\(imageRef)")
        profileImage.sd_setImage(with: imageRef)
        
        //名前の表示
        nameLabel.text = postData.senderName
        
        //コメントの表示
        commentLabel.text = postData.chatMessage
        
        
        //日時の表示
        self.dateLabel.text = ""
        if let date = postData.date{
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let dateString = formatter.string(from: date)
            self.dateLabel.text = dateString
            
        }
    }
}


