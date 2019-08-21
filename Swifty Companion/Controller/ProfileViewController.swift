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

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let API_URL = "https://api.intra.42.fr/v2/users/"
    var skillData : JSON = []
    var projectData : JSON = []
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var loginLable: UILabel!
    @IBOutlet weak var emailLable: UILabel!
    @IBOutlet weak var corectionLable: UILabel!
    @IBOutlet weak var walletLable: UILabel!
    @IBOutlet weak var locationLable: UILabel!
    @IBOutlet weak var coalitionImageView: UIImageView!
    @IBOutlet weak var gradeLable: UILabel!
    @IBOutlet weak var levelLable: UILabel!
    @IBOutlet weak var levelProgressBar: UIView!
    @IBOutlet weak var skillTableView: UITableView!
    @IBOutlet weak var projectTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skillTableView.delegate = self
        projectTableView.delegate = self
        skillTableView.dataSource = self
        projectTableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRow = 1
        switch tableView {
        case skillTableView:
            numberOfRow = skillData.count
        case projectTableView:
            numberOfRow = projectData.count
        default:
            print("Error : Some problem in numberOfRowInSection")
        }
        print(skillData)
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!\(numberOfRow)")
        return numberOfRow
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch tableView {
        case skillTableView:
            cell = tableView.dequeueReusableCell(withIdentifier: "skillCell", for: indexPath)
            cell.textLabel?.text = skillData[indexPath.row]["name"].string!
//            print(skillData[indexPath.row]["name"].string!)
        case projectTableView:
            cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath)
            cell.textLabel?.text = projectData[indexPath.row]["project"]["name"].string!
        default:
            print("Error : Some problem in cellForRowAt indexPath")
        }
        return cell
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
                self.skillData = userJSON["cursus_users"][0]["skills"]
                self.projectData = userJSON["projects_users"]
                print(userJSON["cursus_users"][0]["skills"].count)
//                print(self.skillData)
                self.loadInfo(json: userJSON, parameters: parameters)
            }else{
                print("Error \(String(describing: responce.result.error))")
            }
        }
    }
    
    func loadInfo(json: JSON, parameters: [String:String]){
        var lvl = 0.0
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
        if let grade = json["cursus_users"][0]["grade"].string{
            gradeLable.text = grade
        }
        if let level = json["cursus_users"][0]["level"].double{
            levelLable.text = "level \(level)"
            lvl = level
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
//                    print(coalitionJSON)
                    self.loadImage(url: coalitionJSON[0]["cover_url"].string!, imageView: self.coalitionImageView)
                    self.levelProgressBar.backgroundColor = UIColor(hex: coalitionJSON[0]["color"].string!)
                    self.levelProgressBar.frame.size.width = (self.view.frame.size.width / 100) * CGFloat(Int(lvl*100) % 100)
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
