//
//  ViewController.swift
//  Swifty Companion
//
//  Created by MacBook Pro on 8/9/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class SearchProfileViewController: UIViewController {
    
    let TOKEN_URL = "https://api.intra.42.fr/oauth/token"
    let UID = "640c7a697757240df8a0e79bc5ca8c2b31dbb80019e1356b8eb91c399dd7c85d"
    let SECRET = "ee1847ec27f5994201c3ec54e325c662b5f20b5068de3f5e849e1d61d6649d12"
    var token = ""

    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getToken()
    }
    
    func getToken(){
        let parameters: Parameters = ["grant_type": "client_credentials", "client_id": UID, "client_secret": SECRET]
        Alamofire.request(TOKEN_URL, method: .post, parameters: parameters).responseJSON { (responce) in
            if responce.result.isSuccess{
                let tokenJSON = JSON(responce.result.value!)
                self.token = tokenJSON["access_token"].string!
            }else{
                print("Error \(String(describing: responce.result.error))")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProfileInfo"{
            let destinationVC = segue.destination as! ProfileViewController
            destinationVC.getUserData(login: searchTextField.text!, token: token)
            searchTextField.text = ""
//            print(token)
        }
    }
}
//{
//    "scope" : "public",
//    "token_type" : "bearer",
//    "expires_in" : 6966,
//    "access_token" : "7b244b473992a358638e71f90f50184e6ca4e11e7ad84c468d4645eb5f8cc3c8",
//    "created_at" : 1566057597
//}
