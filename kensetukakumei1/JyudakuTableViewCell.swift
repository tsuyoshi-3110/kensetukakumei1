//
//  JyudakuTableViewCell.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/20.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//

import UIKit
import FirebaseUI

class JyudakuTableViewCell: UITableViewCell {
    @IBOutlet weak var profileimage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var workAreaLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var typeOfWorkLabel: UILabel!
    @IBOutlet weak var yearsOfExLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var dmMailButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileimage.layer.cornerRadius = 5
        profileimage.clipsToBounds = true
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setPostOenData(_ postData: PostOenData){
    //画像の表示
    profileimage.sd_imageIndicator = SDWebImageActivityIndicator.gray
    let imageRef = Storage.storage().reference().child(Const.ProfileImagePath).child(postData.userID! + "_" + String(postData.imageNo) + ".jpg")
    print("imageRefの値は、\(imageRef)")
    profileimage.sd_setImage(with: imageRef)
    
    //名前の表示
    nameLabel.text = "投稿者:\(postData.name!)"
    //コメントの表示
    commentLabel.text = postData.comment
    //現場地域の表示
    workAreaLabel.text = "現場地域：\(postData.area!)"
    //期間の表示
    startLabel.text = postData.start
    endLabel.text = postData.end
    //工種の表示
    typeOfWorkLabel.text = "工種:\(postData.typeOfWork ?? "指定なし")"
    //条件の表示
    conditionLabel.text = "条件:\(postData.conditions!)"
    //経験年数の表示
    yearsOfExLabel.text = "経験:\(postData.yearsEx!)年"
    //会社名を表示
        companyNameLabel.text = postData.companyName
    
    }
}
