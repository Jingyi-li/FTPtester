//
//  LoginPageViewController.swift
//  FTPtester
//
//  Created by Jingyi LI on 30/8/18.
//  Copyright © 2018 Jingyi LI. All rights reserved.
//

import UIKit



class LoginPageViewController: UIViewController {
    

    
    
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
            
            MainBoardVC.cradle["userName"] = userNameInput.text ?? "pi"
            MainBoardVC.cradle["password"] = passwordInput.text ?? "Mba287xd!"
            MainBoardVC.cradle["url"] = urlInput.text ?? "ftp://192.168.50.10:21"
            MainBoardVC.customView = customCheckbox.isChecked
            
        }
    }
    
    @IBAction func customCheckbox(_ sender: Checkbox) {
//        print("checkbox value change: \(sender.isChecked)")
    }
    
    @IBAction func loginToCradle(_ sender: Any) {
        
        performSegue(withIdentifier: "loginToMainBoard", sender: self)
        
    }
    
    func initLoginPage(){
        userNameInput.text = "pi"
        passwordInput.text = "Mba287xd!"
        urlInput.text = "ftp://192.168.50.10:21"
        customCheckbox.isChecked = true
        
    }
    
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
