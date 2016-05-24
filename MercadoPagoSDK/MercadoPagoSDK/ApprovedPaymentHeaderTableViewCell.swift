//
//  ApprovedPaymentTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 9/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class ApprovedPaymentHeaderTableViewCell: UITableViewCell, CongratsFillmentDelegate {

    static let ROW_HEIGHT = CGFloat(210)
    
    @IBOutlet weak var subtitle: MPLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.shadowOffset = CGSizeMake(0, 1)
        self.layer.shadowColor = UIColor(red: 153, green: 153, blue: 153).CGColor
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.6

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillCell(payment: Payment, callback : (Void -> Void)?) -> UITableViewCell {
        let email : String
        if (payment.payer != nil) {
            email = payment.payer!.email ?? ""
        } else {
            email = "tu mail".localized
        }
        
        self.subtitle.text = "Te enviaremos los datos a ".localized + email
        return self
    }
    
}