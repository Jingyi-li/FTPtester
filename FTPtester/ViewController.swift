//
//  ViewController.swift
//  FTPtester
//
//  Created by Jingyi LI on 22/8/18.
//  Copyright © 2018 Jingyi LI. All rights reserved.
//

import UIKit
import FilesProvider


class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, FileProviderDelegate{


    @IBOutlet weak var userNameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var urlInput: UITextField!
    @IBOutlet weak var directoryPath: UITextField!
    @IBOutlet weak var filesListTableView: UITableView!
    
    
//    var filesCount : Int = 0
    var filesNameArray = [String]()
//    var fileList = [FileObject]()
    var filesFolderBool = [Bool]()
//    flagTableView = 1 means Cradle 2 means Local
    var flagTableView = 0
    

    
//    Initialization FilesProvider
    var ftpFileProvider : FTPFileProvider!
    let documentsProvider = LocalFileProvider(baseURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
//    let initLocalPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        filesListTableView.delegate = self
        filesListTableView.dataSource = self
//        documentsProvider.delegate = self as FileProviderDelegate
        initTextField()
        filesListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//   press the login button
    @IBAction func loginToCradleButton(_ sender: Any) {
        let ftpCredential = getCredential()
        print(ftpCredential)
        initFTP(ftpCredential.userName, ftpCredential.passWord, ftpCredential.urlPath)
        
    }
//    Press the Dir Button to get the FileList from the directory
    @IBAction func dirCradleGetButton(_ sender: Any) {
        flagTableView = 1
//        directoryPath.text = "/"
//        print(directoryPath.text)
//        let dirPath = directoryPath.text
        let dirPath = "/"
        directoryPath.text = dirPath
        getFielsInDirectiry(directoryPath: dirPath)

    }

    @IBAction func dirLocalGetButton(_ sender: Any) {
        flagTableView = 2
        let dirPath = "/"
        directoryPath.text = dirPath
        print(FileManager.default.urls)
        getFielsInDirectiry(directoryPath: dirPath)
        
    }
    
    @IBAction func dirBackButton(_ sender: Any) {
        directoryPath.text = dirBackToUpFolder(dirCurrentPath: directoryPath.text ?? "/")
        getFielsInDirectiry(directoryPath: directoryPath.text ?? "/")
    }
    
    @IBAction func fileSaveOrDelet(_ sender: Any) {
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
        
        //need to print a confirm alert to show it already login
    }

    
    func getFielsInDirectiry(directoryPath dirPath: String){
        let dirCurrentPath : String = dirPath
        
        if flagTableView == 1 {

            ftpFileProvider?.contentsOfDirectory(path: dirCurrentPath, completionHandler: { (contents, error) in
                print(error)
                
                self.filesNameArray.removeAll()
                self.filesFolderBool.removeAll()
                self.fileList.removeAll()
              
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
        } else if flagTableView == 2 {
            print("Local")
            documentsProvider.contentsOfDirectory(path: dirCurrentPath, completionHandler: { (contents, error) in
                print(error)
                
                self.filesNameArray.removeAll()
                self.filesFolderBool.removeAll()
                
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
//    filesListTableView UITableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = self.filesListTableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
        cell.textLabel?.text = filesNameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(filesFolderBool[indexPath.row])
        if filesFolderBool[indexPath.row]{
            directoryPath.text = directoryPath.text! + filesNameArray[indexPath.row] + "/"
            getFielsInDirectiry(directoryPath: directoryPath.text ?? "/" )
        }
        
        
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


    
    
}

