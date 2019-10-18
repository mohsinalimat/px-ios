//
//  PXOpenPrefInitDTO.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 18/10/19.
//  Copyright © 2019 MercadoPago. All rights reserved.
//

import Foundation
/// :nodoc:
open class PXOpenPrefInitDTO: NSObject, Decodable {
    open var preference: PXCheckoutPreference?
    open var oneTap: [PXOneTapDto]?
    open var currency: PXCurrency
    open var site: PXSite?
    open var generalCoupon: String
    open var coupons: [String: PXDiscountConfiguration]
    open var groups: [PXPaymentMethodSearchItem] = []
    open var payerPaymentMethods: [PXCustomOptionSearchItem] = []
    open var availablePaymentMethods: [PXPaymentMethod] = []
    open var selectedDiscountConfiguration: PXDiscountConfiguration?

    public init(preference: PXCheckoutPreference?, oneTap: [PXOneTapDto]?, currency: PXCurrency, site: PXSite?, generalCoupon: String, coupons: [String: PXDiscountConfiguration], groups: [PXPaymentMethodSearchItem], payerPaymentMethods: [PXCustomOptionSearchItem], availablePaymentMethods: [PXPaymentMethod]) {
        self.preference = preference
        self.oneTap = oneTap
        self.currency = currency
        self.site = site
        self.generalCoupon = generalCoupon
        self.coupons = coupons
        self.groups = groups
        self.payerPaymentMethods = payerPaymentMethods
        self.availablePaymentMethods = availablePaymentMethods

        if let selectedDiscountConfiguration = coupons[generalCoupon] {
            self.selectedDiscountConfiguration = selectedDiscountConfiguration
        }
    }

    enum CodingKeys: String, CodingKey {
        case preference
        case oneTap = "one_tap"
        case currency
        case site
        case generalCoupon = "general_coupon"
        case coupons
        case groups = "groups"
        case payerPaymentMethods = "payer_payment_methods"
        case availablePaymentMethods = "available_payment_methods"
    }

    open class func fromJSON(data: Data) throws -> PXOpenPrefInitDTO {
        return try JSONDecoder().decode(PXOpenPrefInitDTO.self, from: data)
    }

    func getPaymentOptionsCount() -> Int {
        let payerOptionsCount = payerPaymentMethods.count
        let groupsOptionsCount = groups.count
        return payerOptionsCount + groupsOptionsCount
    }

    func hasCheckoutDefaultOption() -> Bool {
        return oneTap != nil
    }

    func deleteCheckoutDefaultOption() {
        oneTap = nil
    }

    func getPaymentMethodInExpressCheckout(targetId: String) -> (found: Bool, expressNode: PXOneTapDto?) {
        guard let expressResponse = oneTap else { return (false, nil) }
        for expressNode in expressResponse {
            let cardCaseCondition = expressNode.oneTapCard != nil && expressNode.oneTapCard?.cardId == targetId
            let creditsCaseCondition = PXPaymentTypes(rawValue:expressNode.paymentMethodId) == PXPaymentTypes.CONSUMER_CREDITS
            if cardCaseCondition || creditsCaseCondition {
                return (true, expressNode)
            }
        }
        return (false, nil)
    }
}
