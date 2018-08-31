//
//  LoginPageViewController.swift
//  FTPtester
//
//  Created by Jingyi LI on 30/8/18.
//  Copyright © 2018 Jingyi LI. All rights reserved.
//

import UIKit
import FilesProvider



class LoginPageViewController: UIViewController, FileProviderDelegate {
    
    var ftpFileProvider: FTPFileProvider?
    

    
    
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

            MainBoardVC.ftpFileProvider = ftpFileProvider
            MainBoardVC.customView = customCheckbox.isChecked
            
        }
    }
    
    @IBAction func customCheckbox(_ sender: Checkbox) {
//        print("checkbox value change: \(sender.isChecked)")
    }
    
    @IBAction func loginToCradle(_ sender: Any) {
        
        logInToCradle()
        
        performSegue(withIdentifier: "loginToMainBoard", sender: self)
        
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
//        print(ftpCredential)
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
//        print(Thread.callStackSymbols)
        //need to print a confirm alert to show it already login
    }
    
   
    
//    checkbox layout
    func customCheckboxLayout (checkbox: Checkbox){
        checkbox.checkboxBackgroundColor = .clear
//        checkbox.uncheckedBorderColor = .clear
//        checkbox.checkedBorderColor = .clear
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
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
