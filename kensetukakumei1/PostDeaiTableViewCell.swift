//
//  PostDeaiTableViewCell.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/19.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase

class PostDeaiTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var returnCommentButton: UIButton!
    @IBOutlet weak var returnCommentLabel: UILabel!
    @IBOutlet weak var dmMailButton: UIButton!
    
    
    var profileData: ProfileData!
   
    
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
    //PostDataの内容をセルに表示
    func setPostDeaiData(_ postData: PostDeaiData){
        
      
             
            //画像の表示
            profileImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
            let imageRef = Storage.storage().reference().child(Const.ProfileImagePath).child(postData.userID! + "_" + String(postData.imageNo) + ".jpg")
            print("imageRefの値は、\(imageRef)")
            profileImage.sd_setImage(with: imageRef)
        
            //名前の表示
            nameLabel.text = "投稿者:\(postData.name!)"
            
            //コメントの表示
            commentLabel.text = postData.comment
            
            
            //返信コメントの表示
            let returnCommentUnion = postData.returnComment?.joined()
            self.returnCommentLabel.text = returnCommentUnion
            
            //日時の表示
            self.dateLabel.text = ""
            if let date = postData.date{
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                let dateString = formatter.string(from: date)
                self.dateLabel.text = dateString
            }
            //いいね数の表示
            let likeNumber = postData.likes.count
            likeLabel.text = "\(likeNumber)"
            
            //いいねボタンの表示
            if postData.isLiked{
                let buttonImage = UIImage(named: "like_exist")
                self.likeButton.setImage(buttonImage, for: .normal)
            }else{
                let buttonImage = UIImage(named: "like_none")
                self.likeButton.setImage(buttonImage, for: .normal)
            }
            //セルが削除が可能なことを伝えるメソッド
            func tableView(_ table: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle{
                return .delete
            }
            
    
            
        }
    }

