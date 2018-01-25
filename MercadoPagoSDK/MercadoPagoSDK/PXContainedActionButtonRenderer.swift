//
//  PXContainedActionButtonRenderer.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 23/1/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class PXContainedActionButtonRenderer: NSObject {
    
    let BUTTON_WIDTH_PERCENT_OF_SCREEN : CGFloat = 84.0
    let BUTTON_HEIGHT : CGFloat = 50.0
    
    func render(_ containedButton: PXContainedActionButtonComponent) -> PXContainedActionButtonView {
        let containedButtonView =  PXContainedActionButtonView()
        containedButtonView.translatesAutoresizingMaskIntoConstraints = false
        let button = self.buildButton(with: containedButton.props.action, title: containedButton.props.title, backgroundColor: containedButton.props.buttonColor, textColor: containedButton.props.textColor)
        containedButtonView.addSubview(button)
        containedButtonView.button = button
        PXLayout.centerHorizontally(view: button).isActive = true
        PXLayout.centerVertically(view: button).isActive = true
        PXLayout.setHeight(owner: button, height: BUTTON_HEIGHT ).isActive = true
        PXLayout.matchWidth(ofView: button, withPercentage: BUTTON_WIDTH_PERCENT_OF_SCREEN).isActive = true
        
        return containedButtonView
    }
    
    func buildButton(with action:@escaping (() -> Void), title: String, backgroundColor: UIColor, textColor: UIColor) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 3
        button.backgroundColor = backgroundColor
        button.setTitle(title, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.add(for: .touchUpInside, action)
        return button
    }
}


class PXContainedActionButtonView: UIView {
    public var button: UIButton?
}
