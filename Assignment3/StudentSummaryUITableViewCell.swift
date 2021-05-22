//
//  StudentSummaryUITableViewCell.swift
//  Assignment3
//
//  Created by mobiledev on 14/5/21.
//

import UIKit

class StudentSummaryUITableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var stuId: UILabel!
    @IBOutlet var gradeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
