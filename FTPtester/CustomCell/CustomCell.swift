//
//  CustomCell.swift
//  FTPtester
//
//  Created by Jingyi LI on 27/8/18.
//  Copyright © 2018 Jingyi LI. All rights reserved.
//

import UIKit
import FilesProvider

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var fileSize: UILabel!
    @IBOutlet weak var fileProcess: UIProgressView!
    @IBOutlet weak var fileImage: UIImageView!
    
    func setFileCell(file: FileObject, flag: Int){
        fileName.text = file.name
        fileProcess.progress = 0
        if file.isDirectory{
            fileSize.text = "Directory"
            fileImage.image = UIImage(named: "folder")
            fileProcess.isHidden = true
        }else {
            fileSize.text = "Size: \(file.size)"
            if flag == 1{
                fileImage.image = UIImage(named: "fileB")
                fileProcess.isHidden = false
            } else {
                fileImage.image = UIImage(named: "fileR")
                fileProcess.isHidden = false
            }
        }
        
    }
    
  
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
}
