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

protocol SearchProfileDelegate{
    func getUserData(login: String, token: String)
}

class SearchProfileViewController: UIViewController {
    
    var delegate: SearchProfileDelegate?

    let TOKEN_URL = "https://api.intra.42.fr/oauth/token"
    let UID = "640c7a697757240df8a0e79bc5ca8c2b31dbb80019e1356b8eb91c399dd7c85d"
    let SECRET = "ee1847ec27f5994201c3ec54e325c662b5f20b5068de3f5e849e1d61d6649d12"
    var token = ""

    @IBOutlet weak var unitLableImageView: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.placeholder = "Enter login"
        searchButton.layer.cornerRadius = 5
        unitLableImageView.image = UIImage(named: "Combined Shape")
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
//        delegate?.getUserData(login: searchTextField.text!, token: token)
        performSegue(withIdentifier: "goToProfileInfo", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare")
        if segue.identifier == "goToProfileInfo"{
            let destinationVC = segue.destination as! ProfileViewController
            destinationVC.getUserData(login: searchTextField.text!, token: token)
            searchTextField.text = ""
        }
    }
    
    
}
