//
//  PXHookComponent.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 11/28/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

@objc
public protocol PXHookComponent: PXComponentizable {
    func hookForStep() -> PXHookStep
    func render() -> UIView
    @objc optional func shouldSkipHook(hookStore: PXCheckoutStore) -> Bool
    @objc optional func didReceive(hookStore: PXCheckoutStore)
    @objc optional func navigationHandlerForHook(navigationHandler: PXHookNavigationHandler)
    @objc optional func renderDidFinish()
    @objc optional func titleForNavigationBar() -> String?
    @objc optional func colorForNavigationBar() -> UIColor?
    @objc optional func shouldShowBackArrow() -> Bool
    @objc optional func shouldShowNavigationBar() -> Bool
}
