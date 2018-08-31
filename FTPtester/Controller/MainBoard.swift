//
//  ViewController.swift
//  FTPtester
//
//  Created by Jingyi LI on 22/8/18.
//  Copyright © 2018 Jingyi LI. All rights reserved.
//

import UIKit
import FilesProvider


class MainBoard: UIViewController , UITableViewDelegate, UITableViewDataSource, FileProviderDelegate{
    


    @IBOutlet weak var directoryPath: UITextField!
    @IBOutlet weak var filesListTableView: UITableView!

    
    
    var fileList = [FileObject]()
    var filesNameArray = [String]()
    var filesSelected : Int?
//    flagTableView = 1 means Cradle 2 means Local
    var flagTableView = 1
    let customView : Bool = true
    var cradle = ["userName" : "", "password": "", "url": ""]
    
    

    
//    Initialization FilesProvider
    var ftpFileProvider : FTPFileProvider!
    let documentsProvider = LocalFileProvider(baseURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)

    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        filesListTableView.delegate = self
        filesListTableView.dataSource = self
        documentsProvider.delegate = self as FileProviderDelegate
//        initTextField()
        filesListTableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        setupKeyboardDismissRecognizer()
        
        if customView {
            directoryPath.isHidden = true
        }
        logInToCradle()
        getDirectory()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
   
//    Press the Dir Button to get the FileList from the directory
    @IBAction func dirCradleGetButton(_ sender: Any) {
        flagTableView = 1
        getDirectory()
        
    }

    @IBAction func dirLocalGetButton(_ sender: Any) {
        flagTableView = 2
        getDirectory()
    }
    
    @IBAction func dirBackButton(_ sender: Any) {
        directoryPath.text = dirBackToUpFolder(dirCurrentPath: directoryPath.text ?? "/")
        getFielsInDirectiry(directoryPath: directoryPath.text ?? "/")
    }
    
    @IBAction func fileSaveToLocal(_ sender: Any) {
        if flagTableView == 1 {
            if let row = filesSelected {
                let nameString = "\(fileList[row].name)"
                print(nameString)
                let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(nameString)
                var path = directoryPath.text ?? "/"
                path.append(nameString)
                print(path)

                let cell = self.filesListTableView.cellForRow(at: IndexPath(row: filesSelected!, section: 0)) as? CustomCell
                cell?.fileProcess.observedProgress = ftpFileProvider.copyItem(path: path, toLocalURL: fileURL, completionHandler: nil)
            } else {
                let alert = UIAlertController(title: "Alert", message: "No BinFile Chosen in Cradle", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            
        } else {
            print("Please into Cradle view")
        }
        filesSelected = nil
    }

    
    @IBAction func fileDeletInLocal(_ sender: Any) {
        if flagTableView == 2{
            if let row = filesSelected {
                let nameString = "\(fileList[row].name)"
                documentsProvider.removeItem(path: nameString, completionHandler: nil)
            } else {
                let alert = UIAlertController(title: "Alert", message: "No BinFile Chosen in Local", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            print("Cannot remove items in Cradle")
        }
        filesSelected = nil
        getDirectory()
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
// functions
    func getCredential() -> (userName: String, passWord: String, urlPath: String){
        let userName : String = cradle["userName"]!
        let passWord : String = cradle["password"]!
        let urlPath : String = cradle["url"]!
        return (userName, passWord, urlPath)
    }
    
    
    func initFTP(_ userName : String, _ passWord : String, _ urlPath : String){
        let credential = URLCredential(user: userName, password: passWord, persistence: .permanent)
        ftpFileProvider = FTPFileProvider(baseURL: URL(string: urlPath)!, credential: credential)
        
        //need to print a confirm alert to show it already login
    }
    
    func logInToCradle() {
        let ftpCredential = getCredential()
        print(ftpCredential)
        initFTP(ftpCredential.userName, ftpCredential.passWord, ftpCredential.urlPath)
        ftpFileProvider.delegate = self as FileProviderDelegate

    }
    
    func getDirectory() {
        let dirPath = "/"
        directoryPath.text = dirPath
        getFielsInDirectiry(directoryPath: dirPath)
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
    
    func setupKeyboardDismissRecognizer(){
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(MainBoard.dismissKeyboard))
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
    }

    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }


//    filesListTableView UITableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let file = fileList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
        cell.setFileCell(file: file, flag: flagTableView)
        
//        cell.backgroundColor = UIColor.groupTableViewBackground
        
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

