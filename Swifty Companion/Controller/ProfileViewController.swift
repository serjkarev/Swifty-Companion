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
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emailLable: UILabel!
    @IBOutlet weak var nameLable: UILabel!
    
    
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
                //                print(userJSON)
                self.loadInfo(json: userJSON)
            }else{
                print("Error \(String(describing: responce.result.error))")
            }
        }
    }
    
    func loadInfo(json: JSON){
        if let imageURL = json["image_url"].string{
            let url = URL(string: imageURL)
            let data = try? Data(contentsOf: url!)
            if let imageData = data{
                let image = UIImage(data: imageData)
                imageView.image = image
            }
        }
        if let email = json["email"].string {
            emailLable.text = email
        }
        if let name = json["displayname"].string {
            nameLable.text = name
        }else{
            nameLable.text = "NOT FOUND 404"
        }
        
    }
    
    
}
//URL for background coalition image
//https://cdn.intra.42.fr/coalition/cover/7/empire_background.jpg
//https://cdn.intra.42.fr/coalition/cover/6/union_background.jpg
//https://cdn.intra.42.fr/coalition/cover/5/alliance_background.jpg
//https://cdn.intra.42.fr/coalition/cover/8/hive_background.jpg
