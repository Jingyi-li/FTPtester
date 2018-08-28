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
//    @IBOutlet weak var fileProcess: UIProgressView!
    @IBOutlet weak var fileImage: UIImageView!
    
    func setFileCell(file: FileObject){
        fileName.text = file.name
        if file.isDirectory{
            fileSize.text = "Directory"
        }else {
            fileSize.text = "Size: \(file.size)"
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
