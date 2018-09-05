//
//  LoginPageViewController.swift
//  FTPtester
//
//  Created by Jingyi LI on 30/8/18.
//  Copyright © 2018 Jingyi LI. All rights reserved.
//

import UIKit
import FilesProvider
import Foundation



class LoginPageViewController: UIViewController, FileProviderDelegate {
    
    var ftpFileProvider: FTPFileProvider?
    var loginCradle = false
    

    
    
    @IBOutlet weak var userNameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var urlInput: UITextField!
    @IBOutlet weak var customCheckbox: Checkbox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLoginPage()
        setupKeyboardDismissRecognizer()
        customCheckboxLayout(checkbox: customCheckbox)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginToMainBoard" {
            let MainBoardVC = segue.destination as! MainBoard
            
            if loginCradle {
                MainBoardVC.ftpFileProvider = ftpFileProvider
                MainBoardVC.customView = customCheckbox.isChecked
                MainBoardVC.loginCradle = loginCradle
            } else {
                MainBoardVC.loginCradle = loginCradle
            }

           
            
        }
    }
    
    @IBAction func customCheckbox(_ sender: Checkbox) {
//        print("checkbox value change: \(sender.isChecked)")
    }
    
    @IBAction func loginToLocal(_ sender: Any) {
        let message = "Go Local Folder. If you want to reach Cradle please Login!"
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            print("login to local with out login to cradle")
            self.loginCradle = false
            self.performSegue(withIdentifier: "loginToMainBoard", sender: self)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginToCradle(_ sender: Any) {
        
        logInToCradle()
        ftpFileProvider?.loginToFtp(completionHandler: { (error) in
            let message = self.errorDeclar(error.debugDescription)
//            let message = error.debugDescription
            if error != nil {
                
                let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else {
                DispatchQueue.main.async {
                    self.loginCradle = true
                    self.performSegue(withIdentifier: "loginToMainBoard", sender: self)
                }
            }
        })
//        performSegue(withIdentifier: "loginToMainBoard", sender: self)
        
    }
    
    func initLoginPage(){
        userNameInput.text = "pi"
        passwordInput.text = "Mba287xd!"
        urlInput.text = "ftp://192.168.50.10:21"
        customCheckbox.isChecked = true
        
    }
    
//    Login to Cradle
    func logInToCradle() {
        let ftpCredential = getCredential()
        initFTP(ftpCredential.userName, ftpCredential.passWord, ftpCredential.urlPath)
        ftpFileProvider?.delegate = self as FileProviderDelegate
        
    }
    
    func getCredential() -> (userName: String, passWord: String, urlPath: String){
        let userName : String = userNameInput.text ?? "pi"
        let passWord : String = passwordInput.text ?? "Mba287xd!"
        let urlPath : String = urlInput.text ?? "ftp://192.168.50.10:21"
        return (userName, passWord, urlPath)
    }
    

    func initFTP(_ userName : String, _ passWord : String, _ urlPath : String){
        
        let credential = URLCredential(user: userName, password: passWord, persistence: .permanent)

        ftpFileProvider = FTPFileProvider(baseURL: URL(string: urlPath)!, credential: credential)

        //need to print a confirm alert to show it already login
    }
    
   
    
//    checkbox layout
    func customCheckboxLayout (checkbox: Checkbox){
        checkbox.checkboxBackgroundColor = .clear
        checkbox.borderStyle = .circle
        checkbox.checkmarkStyle = .tick
        
    }
    
    func setupKeyboardDismissRecognizer(){
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(LoginPageViewController.dismissKeyboard))
        
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    
    
    
    //    fileProviderDelegate
    func fileproviderSucceed(_ fileProvider: FileProviderOperations, operation: FileOperationType) {
        switch operation {
        case .copy(source: let source, destination: let dest):
            print("\(source) copied to \(dest).")
        case .remove(path: let path):
            print("\(path) has been deleted.")
        default:
            print("\(operation.actionDescription) from \(operation.source) to \(operation.destination) succeed")
        }
    }
    
    func fileproviderFailed(_ fileProvider: FileProviderOperations, operation: FileOperationType, error: Error) {
        switch operation {
        case .copy(source: let source, destination: let dest):
            print("copy of \(source) failed.")
        case .remove:
            print("file can't be deleted.")
        default:
            print("\(operation.actionDescription) from \(operation.source) to \(operation.destination) failed")
        }
    }
    
    func fileproviderProgress(_ fileProvider: FileProviderOperations, operation: FileOperationType, progress: Float) {
        switch operation {
        case .copy(source: let source, destination: let dest):
            print("Copy\(source) to \(dest): \(progress * 100) completed.")
        default:
            break
        }
    }
//    make error readable to user
    func errorDeclar(_ error: String)-> String {
        var message: String?
        if error.contains("Login authentication failed") {
            message = "Username or Password is wrong!"
        } else if error.contains("NSErrorFailingURLKey") {
            message = "Disconnect with Cradle"
        } else {
            message = error
        }
        return message!
    }
   
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
