//
//  ProfileViewController.swift
//  Swifty Companion
//
//  Created by MacBook Pro on 8/12/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SVProgressHUD

class ProfileViewController: UIViewController {
    
    let API_URL = "https://api.intra.42.fr/v2/users/"
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var loginLable: UILabel!
    @IBOutlet weak var emailLable: UILabel!
    @IBOutlet weak var corectionLable: UILabel!
    @IBOutlet weak var walletLable: UILabel!
    @IBOutlet weak var locationLable: UILabel!
    @IBOutlet weak var coalitionImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func goBackButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    func getUserData(login: String, token: String){
        SVProgressHUD.show()
        let parameters = ["access_token": token]
        Alamofire.request(API_URL + login, method: .get, parameters: parameters).responseJSON { (responce) in
            SVProgressHUD.dismiss()
            if responce.result.isSuccess{
                let userJSON: JSON = JSON(responce.result.value!)
//                                print(userJSON)
                self.loadInfo(json: userJSON, parameters: parameters)
            }else{
                print("Error \(String(describing: responce.result.error))")
            }
        }
    }
    
    func loadInfo(json: JSON, parameters: [String:String]){
        if let imageURL = json["image_url"].string{
            loadImage(url: imageURL, imageView: userImageView)
        }
        if let email = json["email"].string {
            emailLable.text = email
        }
        if let name = json["displayname"].string {
            nameLable.text = name
        }
        if let login = json["login"].string{
            loginLable.text = login
        }
        if let correction = json["correction_point"].int{
            corectionLable.text = String(correction)
        }
        if let wallet = json["wallet"].int{
            walletLable.text = String(wallet)+"₳"
        }
        if let location = json["location"].string {
            locationLable.text = "Available\n" + location
        }else{
            locationLable.text = "Unavailable\n - "
        }
        if let userID = json["languages_users"][0]["user_id"].int {
            Alamofire.request("https://api.intra.42.fr/v2/users/\(userID)/coalitions", method: .get, parameters: parameters).responseJSON { (responce) in
                if responce.result.isSuccess {
                    let coalitionJSON: JSON = JSON(responce.result.value!)
                    print(coalitionJSON)
                    self.loadImage(url: coalitionJSON[0]["cover_url"].string!, imageView: self.coalitionImageView)
                }else{
                    print("Error \(String(describing: responce.result.error))")
                }
            }
        }
        else{
            nameLable.text = "NOT FOUND"
        }
        
    }
    
    func loadImage(url: String, imageView: UIImageView){
        let imageURL = URL(string: url)
        let data = try? Data(contentsOf: imageURL!)
        if let imageData = data{
            let image = UIImage(data: imageData)
            imageView.image = image
        }
    }
    
    
}
//URL for background coalition image
//https://cdn.intra.42.fr/coalition/cover/7/empire_background.jpg
//https://cdn.intra.42.fr/coalition/cover/6/union_background.jpg
//https://cdn.intra.42.fr/coalition/cover/5/alliance_background.jpg
//https://cdn.intra.42.fr/coalition/cover/8/hive_background.jpg

//"https://api.intra.42.fr/v2/users/33744/coalitions"

//[
//    {
//        "slug" : "42-kyiv-the-empire",
//        "cover_url" : "https:\/\/cdn.intra.42.fr\/coalition\/cover\/7\/empire_background.jpg",
//        "user_id" : 32603,
//        "image_url" : "https:\/\/cdn.intra.42.fr\/coalition\/image\/7\/Empire_vec.svg",
//        "id" : 7,
//        "score" : 26212,
//        "color" : "#f44336",
//        "name" : "The Empire"
//    }
//]
