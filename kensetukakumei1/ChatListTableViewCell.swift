//
//  ChatListTableViewCell.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/24.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//

import UIKit
import FirebaseUI

class ChatListTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImage.layer.cornerRadius = 5
        profileImage.clipsToBounds = true
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setChatListData(_ postData: UsersData){
        //画像の表示
        profileImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ProfileImagePath).child(postData.id + "_" + String(postData.imageNo) + ".jpg")
        print("imageRefの値は、\(imageRef)")
        profileImage.sd_setImage(with: imageRef)
        
        //名前の表示
        nameLabel.text =  postData.name
    
        
    }
    
}
