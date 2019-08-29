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
    
    var profileData = ProfileDataModel()
    let API_URL = "https://api.intra.42.fr/v2/users/"

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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        profileData = ProfileDataModel()
        getUserData(login: searchTextField.text!, token: token)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProfileInfo"{
            let destinationVC = segue.destination as! ProfileViewController
            destinationVC.profileData = profileData
            searchTextField.text = ""
        }
    }
    
    
    func getUserData(login: String, token: String){
        SVProgressHUD.show()
        self.token = token
        let parameters = ["access_token": token]
        Alamofire.request(API_URL + login, method: .get, parameters: parameters).responseJSON { (responce) in
            if responce.result.isSuccess{
                let userJSON = JSON(responce.result.value!)
                self.updateUserData(json: userJSON)
            }else{
                print("Error \(String(describing: responce.result.error))")
                self.loadOrNot()
            }
        }
    }
    
    func updateUserData(json: JSON){
        print(json)
        if let imageURL = json["image_url"].string{
            profileData.imagrURL = imageURL
        }
        if let name = json["displayname"].string{
            profileData.name = name
        }
        if let login = json["login"].string{
            profileData.login = login
        }
        if let location = json["location"].string {
            profileData.location = "Available\n" + location
        }else{
            profileData.location = "Unavailable\n - "
        }
        if let level = json["cursus_users"][0]["level"].double{
            profileData.level = level
        }
        if let correction = json["correction_point"].int{
            profileData.evaluationPoints = correction
        }
        if let wallet = json["wallet"].int{
            profileData.wallet = wallet
        }
        if let grade = json["cursus_users"][0]["grade"].string{
            profileData.grade = grade
        }
        if let email = json["email"].string {
            profileData.email = email
        }
        if let campusCity = json["campus"][0]["city"].string{
            if let campusCountry = json["campus"][0]["country"].string{
                profileData.campus = campusCity + "/" + campusCountry
            }
        }
        if let skills = json["cursus_users"][0]["skills"].array{
            profileData.skills = skills
        }
        if let projects = json["projects_users"].array{
            for arrayItem in projects{
                if arrayItem["cursus_ids"][0].int! == 1{
                    print(arrayItem["project"]["name"].string!)
                    profileData.projects.append(arrayItem)
                }
            }
            profileData.projects.reverse()
        }
        if let userID = json["languages_users"][0]["user_id"].int {
            getCoalitionData(userID: userID)
        }else{
            loadOrNot()
        }
    }
    
    func getCoalitionData(userID: Int){
        
        let parameters = ["access_token": token]
        Alamofire.request("https://api.intra.42.fr/v2/users/\(userID)/coalitions", method: .get, parameters: parameters).responseJSON { (responce) in
            if responce.result.isSuccess {
                let coalitionJSON: JSON = JSON(responce.result.value!)
                self.updateCoalitionData(json: coalitionJSON)
            }else{
                print("Error \(String(describing: responce.result.error))")
            }
            DispatchQueue.main.async {
                self.loadOrNot()
            }
        }
    }
    
    func loadOrNot(){
        SVProgressHUD.dismiss()
        if profileData.login == "" {
            let alert = UIAlertController(title: "Wrong login", message: "User \(searchTextField.text!) not found", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cencel", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            searchTextField.text = ""
        }else{
            performSegue(withIdentifier: "goToProfileInfo", sender: self)
        }
    }
    
    func updateCoalitionData(json: JSON){
        if let cover = json[0]["cover_url"].string{
            profileData.coalitionCoverURL = cover
        }
        if let backgroundColor = json[0]["color"].string{
            profileData.backgroundColor = UIColor(hex: backgroundColor)
        }
    }
    
}

extension UIColor {
    
    // MARK: - Initialization
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt32 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
