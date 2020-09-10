//
//  SetProfileViewController.swift
//  kensetukakumei
//
//  Created by 斉藤　剛 on 2020/08/02.
//  Copyright © 2020 tsuyoshi.saito. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import SVProgressHUD

class SetProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var qualificationLabel: UILabel!
    @IBOutlet weak var typeOfWorkLabel: UILabel!
    @IBOutlet weak var yearsExLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    var profileImage: UIImage!
    
    var profileData: ProfileData!
    
    var imageNo : Int = 0
    
    var age: String!
    
    @IBAction func setButton(_ sender: Any) {
        //if ( self.profileData != nil ) {
        let settingViewController = self.storyboard?.instantiateViewController(withIdentifier: "Setting") as! SettingViewController
        //最新のImageNoを画像更新のためSettingViewControllerに渡す。
        settingViewController.imageNo = imageNo
        settingViewController.profileData = profileData
        self.present(settingViewController, animated: true, completion: nil)
        //  }
    }
    @IBAction func logoutButton(_ sender: Any) {
        //ログアウトする
        try! Auth.auth().signOut()
        
        //ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        self.present(loginViewController!,animated: true,completion: nil)
        
        //ログイン画面から戻ってきたときのためにホーム画面(index = 0)を選択している状態にしておく
        tabBarController?.selectedIndex = 0
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        // Initialization code
        
    }
    
    //画面が呼ばれるたびに、各ラベルの内容は更新される
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        //サインインしていなければ、何もしない。
        guard let user = Auth.auth().currentUser else {
            // サインインしていない場合の処理をするなど
            return
        }
        //サインインしていれば、Firebaseからドキュメントをダウンロードする。
        Firestore.firestore().collection(Const.ProfilePath).document(user.uid).getDocument { (snap, error) in
            if let error = error {
                print("\(error)")
            }
            //ダウンロードできているかの確認
            guard let data = snap?.data() else {
                let name = Auth.auth().currentUser?.displayName
                self.nameLabel.text = name
                return
            }
            print(data)
            
            //DocumentSnapshotクラスのデータをProfilerDataクラスに当てはめる
            self.profileData = ProfileData(document: snap!)
            
            let name = Auth.auth().currentUser?.displayName
            
            print(self.profileData.age!)
            
            
            //DateとStringの相互変換　profileData.ageをString型からDate型に変換するため
            class DateUtils {
                class func dateFromString(string: String, format: String) -> Date {
                    let formatter: DateFormatter = DateFormatter()
                    formatter.calendar = Calendar(identifier: .gregorian)
                    formatter.dateFormat = format
                    return formatter.date(from: string)!
                }
                
                class func stringFromDate(date: Date, format: String) -> String {
                    let formatter: DateFormatter = DateFormatter()
                    formatter.calendar = Calendar(identifier: .gregorian)
                    formatter.dateFormat = format
                    return formatter.string(from: date)
                }
            }
            
            //初期段階で、profileData.age = "" でエラーになるのをIfで　判定し改善
            if self.profileData.age != "" {
                // profileData.ageの生年月日の日付の文字列
                let dateString = self.profileData.age!
                
                // profileData.ageに格納されているString型をDate型に変換
                let birthdate = DateUtils.dateFromString(string: dateString, format: "yyyy年MM月dd日")
                print("生年月日\(birthdate)")
                // => "2015-03-04 03:34:56 +0000\n"
                
                //今日の日付を取得
                let todayDate = Date()
                
                let calendar = Calendar(identifier: .gregorian)
                let year = calendar.component(.year, from: todayDate)
                let month = calendar.component(.month, from: todayDate)
                let day = calendar.component(.day, from: todayDate)
                let now = DateComponents(calendar: calendar, year: year, month: month, day: day).date!
                
                print(birthdate)
                print(now)
                
                //今日の日付と生年月日で年齢を算出
                let age = calendar.dateComponents([.year], from: birthdate, to: now).year!
                
                print("年齢\(age)歳")
                
                self.nameLabel.text = name
                self.ageLabel.text = String("\(age)歳")
                self.companyNameLabel.text = self.profileData.companyName
                self.areaLabel.text = self.profileData.area
                self.qualificationLabel.text = self.profileData.qualification
                self.typeOfWorkLabel.text = self.profileData.typeOfWork
                self.yearsExLabel.text = self.profileData.yearsEx
                
                print(self.profileData.imageNo)
                // 画像の表示
                self.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                let imageRef = Storage.storage().reference().child(Const.ProfileImagePath).child(self.profileData.id + "_" + String(self.profileData.imageNo) + ".jpg")
                self.imageView.sd_setImage(with: imageRef)
                
                //imageNoを更新するために、imageNoにProfileData.ImageNoを代入しておく
                self.imageNo = self.profileData.imageNo
                
                print("最終##################\(self.imageNo)")
            } else {
                self.companyNameLabel.text = self.profileData.companyName
                self.areaLabel.text = self.profileData.area
                self.qualificationLabel.text = self.profileData.qualification
                self.typeOfWorkLabel.text = self.profileData.typeOfWork
                self.yearsExLabel.text = self.profileData.yearsEx
                
                print(self.profileData.imageNo)
                // 画像の表示
                self.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                let imageRef = Storage.storage().reference().child(Const.ProfileImagePath).child(self.profileData.id + "_" + String(self.profileData.imageNo) + ".jpg")
                self.imageView.sd_setImage(with: imageRef)
                
                //imageNoを更新するために、imageNoにProfileData.ImageNoを代入しておく
                self.imageNo = self.profileData.imageNo
                
                print("最終##################\(self.imageNo)")
              
            }
            
        }
        
    }
    
}



