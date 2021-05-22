//
//  TutorialSummaryUITableViewCell.swift
//  Assignment3
//
//  Created by mobiledev on 22/5/21.
//

import UIKit

class TutorialSummaryUITableViewCell: UITableViewCell {

    @IBOutlet var weekLabel: UILabel!
    @IBOutlet var schemeTypeLabel: UILabel!
    @IBOutlet var schameTypeDetailLabel: UILabel!
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
