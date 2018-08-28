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
    @IBOutlet weak var copyProgress: UIProgressView!
    
    
    var fileList = [FileObject]()
    var filesNameArray = [String]()
    var filesSelected : Int?
//    flagTableView = 1 means Cradle 2 means Local
    var flagTableView = 0
    

    
//    Initialization FilesProvider
    var ftpFileProvider : FTPFileProvider!
    let documentsProvider = LocalFileProvider(baseURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)

    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        filesListTableView.delegate = self
        filesListTableView.dataSource = self
        documentsProvider.delegate = self as FileProviderDelegate
//        ftpFileProvider.delegate = self as FileProviderDelegate
        initTextField()
//        filesListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        filesListTableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        
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
        ftpFileProvider.delegate = self as FileProviderDelegate
        
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
    
    @IBAction func fileSaveToLocal(_ sender: Any) {
        if flagTableView == 1 {
            let nameString = "\(fileList[filesSelected!].name)"
            print(nameString)
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(nameString)
            var path = directoryPath.text ?? "/"
            path.append(nameString)
            print(path)
            copyProgress.observedProgress = ftpFileProvider.copyItem(path: path, toLocalURL: fileURL, completionHandler: nil)
            
            
        } else {
            print("Please into Cradle view")
        }
    }

    
    @IBAction func fileDeletInLocal(_ sender: Any) {
        if flagTableView == 2{
            let nameString = "\(fileList[filesSelected!].name)"
            documentsProvider.removeItem(path: nameString, completionHandler: nil)
        } else {
            print("Cannot remove items in Cradle")
        }
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
                
                self.fileList.removeAll()
                self.filesNameArray.removeAll()
              
                for file in contents {
                    if file.isDirectory || (file.isRegularFile && file.name.hasPrefix("mdm") && file.name.hasSuffix(".bin")) {
                        self.fileList.append(file)
                        self.filesNameArray.append("\(file.name)")
                    }
                    
                }
               
                DispatchQueue.main.async {
                    self.filesListTableView.reloadData()
                }
                
            })
        } else if flagTableView == 2 {
            print("Local")
            documentsProvider.contentsOfDirectory(path: dirCurrentPath, completionHandler: { (contents, error) in
                print(error)
                
                self.filesNameArray.removeAll()
                self.fileList.removeAll()
                
                for file in contents {
                    if file.isDirectory || file.isRegularFile {
                        self.fileList.append(file)
                        self.filesNameArray.append("\(file.name)")
                    }
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
        
        let file = fileList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
        cell.setFileCell(file: file)
        
//        let cell : UITableViewCell = self.filesListTableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
//        cell.textLabel?.text = filesNameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(fileList[indexPath.row].isDirectory)
        if fileList[indexPath.row].isDirectory{
            directoryPath.text = directoryPath.text! + filesNameArray[indexPath.row] + "/"
            getFielsInDirectiry(directoryPath: directoryPath.text ?? "/" )
        } else if fileList[indexPath.row].isRegularFile{
            filesSelected = indexPath.row
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

