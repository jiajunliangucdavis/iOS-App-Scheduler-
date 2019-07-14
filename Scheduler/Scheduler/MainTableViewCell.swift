//
//  MainTableViewCell.swift
//  Scheduler
//
//  Created by JIAJUN LIANG on 11/19/18.
//  Copyright © 2018 JIAJUN LIANG. All rights reserved.
//

import UIKit
import Foundation


protocol MainTableViewCellDelegate: class {
    func MainTableViewCellDidTapEdit(_ sender: MainTableViewCell)
}

/* define each cell */
class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var dueDayLabel: UILabel!
    @IBOutlet weak var daysLeftLabel: UILabel!
    
    
    weak var delegate: MainTableViewCellDelegate?
    
    @IBAction func editOnTap(_ sender: UIButton) {
        delegate?.MainTableViewCellDidTapEdit(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
