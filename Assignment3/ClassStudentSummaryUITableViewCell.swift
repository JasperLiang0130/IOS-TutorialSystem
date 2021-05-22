//
//  ClassStudentSummaryUIViewCellTableViewCell.swift
//  Assignment3
//
//  Created by mobiledev on 22/5/21.
//

import UIKit

class ClassStudentSummaryUITableViewCell: UITableViewCell {

    @IBOutlet var displayImg: UIImageView!
    @IBOutlet var studentName: UILabel!
    @IBOutlet var studentID: UILabel!
    @IBOutlet var gradelabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
