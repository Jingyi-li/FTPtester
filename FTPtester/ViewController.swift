//
//  ViewController.swift
//  FTPtester
//
//  Created by Jingyi LI on 22/8/18.
//  Copyright © 2018 Jingyi LI. All rights reserved.
//

import UIKit
import FilesProvider


class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    
    

    @IBOutlet weak var userNameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var urlInput: UITextField!
    @IBOutlet weak var directoryPath: UITextField!
    @IBOutlet weak var filesListTableView: UITableView!
    
    
//    var filesCount : Int = 0
    var filesNameArray = [String]()
    var filesFolderBool = [Bool]()

    
//    Initialization FilesProvider
    var ftpFileProvider : FTPFileProvider!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        filesListTableView.delegate = self
        filesListTableView.dataSource = self
        initTextField()
        filesListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//   press the login button
    @IBAction func filesListShowButton(_ sender: Any) {
        let ftpCredential = getCredential()
        print(ftpCredential)
        initFTP(ftpCredential.userName, ftpCredential.passWord, ftpCredential.urlPath)
        
    }
//    Press the Dir Button to get the FileList from the directory
    @IBAction func dirGetButton(_ sender: Any) {
        print(directoryPath.text)
        getFielsInDirectiry(directoryPath: directoryPath.text ?? "/")

    }

    @IBAction func dirBackButton(_ sender: Any) {
        directoryPath.text = dirBackToUpFolder(dirCurrentPath: directoryPath.text ?? "/")
        getFielsInDirectiry(directoryPath: directoryPath.text ?? "/")
    }
    
    
    
// functions
    func getCredential() -> (userName: String, passWord: String, urlPath: String){
        let userName : String = userNameInput.text ?? "pi"
        let passWord : String = passwordInput.text ?? "Mba287xd!"
        let urlPath : String = urlInput.text ?? "ftp://192.168.50.10:21"
        return (userName, passWord, urlPath)
    }
    
    func initTextField(){
        userNameInput.text = "pi"
        passwordInput.text = "Mba287xd!"
        urlInput.text = "ftp://192.168.50.10:21"
        directoryPath.text = "/"
    }
    
    func initFTP(_ userName : String, _ passWord : String, _ urlPath : String){
        let credential = URLCredential(user: userName, password: passWord, persistence: .permanent)
        ftpFileProvider = FTPFileProvider(baseURL: URL(string: urlPath)!, credential: credential)
    }
    
    func getFielsInDirectiry(directoryPath dirPath: String){
        let dirCurrentPath : String = dirPath

            ftpFileProvider?.contentsOfDirectory(path: dirCurrentPath, completionHandler: { (contents, error) in
                print(error)
                
                self.filesNameArray.removeAll()
              
                for file in contents {
                    self.filesNameArray.append("\(file.name)")
                    self.filesFolderBool.append(file.isDirectory)
                    print("Name: \(file.name)")
                    print("Folder or not : \(file.isDirectory)")
//                    print("Type: \(file.type)")
//                    print("Size: \(file.size)")
//                    print("Creation Date: \(file.creationDate ?? Date())")
//                    print("Modification Date: \(file.modifiedDate ?? Date())")
                }
               
                print(self.filesNameArray)
                DispatchQueue.main.async {
                    self.filesListTableView.reloadData()
                }
                
            })
       
        
    }
    
    func dirBackToUpFolder(dirCurrentPath directoryPath: String)-> String{
        var dirTemPath = directoryPath.split(separator: "/")
        dirTemPath.popLast()
        var dirReturnPath = "/"
        for item in dirTemPath {
            dirReturnPath = dirReturnPath + item + "/"
        }
        return dirReturnPath
    }
//    filesListTableView UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = self.filesListTableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
        cell.textLabel?.text = filesNameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filesFolderBool[indexPath.row]{
            directoryPath.text = directoryPath.text! + filesNameArray[indexPath.row] + "/"
            getFielsInDirectiry(directoryPath: directoryPath.text ?? "/" )
        }
        
        
    }


    
    
}

