//
//  InitFlowModel.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 27/6/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

internal typealias InitFlowProperties = (paymentData: PXPaymentData, checkoutPreference: PXCheckoutPreference, paymentPlugin: PXSplitPaymentProcessor?, paymentMethodPlugins: [PXPaymentMethodPlugin], paymentMethodSearchResult: PXPaymentMethodSearch?, chargeRules: [PXPaymentTypeChargeRule]?, serviceAdapter: MercadoPagoServicesAdapter, advancedConfig: PXAdvancedConfiguration, paymentConfigurationService: PXPaymentConfigurationServices, privateKey: String?)
internal typealias InitFlowError = (errorStep: InitFlowModel.Steps, shouldRetry: Bool, requestOrigin: ApiUtil.RequestOrigin?, apiException: ApiException?)

internal protocol InitFlowProtocol: NSObjectProtocol {
    func didFinishInitFlow()
    func didFailInitFlow(flowError: InitFlowError)
}

final class InitFlowModel: NSObject, PXFlowModel {
    enum Steps: String {
        case ERROR = "Error"
        case SERVICE_GET_PREFERENCE = "Obtener datos de preferencia"
        case ACTION_VALIDATE_PREFERENCE = "Validación de preferencia"
        case SERVICE_GET_PAYMENT_METHODS = "Obtener medios de pago"
        case SERVICE_PAYMENT_METHOD_PLUGIN_INIT = "Iniciando plugin de pago"
        case FINISH = "Finish step"
    }

    private var preferenceValidated: Bool = false
    private var needPaymentMethodPluginInit = true
    private var loadPreferenceStatus: Bool
    private var directDiscountSearchStatus: Bool
    private var flowError: InitFlowError?
    private var pendingRetryStep: Steps?

    var properties: InitFlowProperties

    var amountHelper: PXAmountHelper {
        get {
            return PXAmountHelper(preference: self.properties.checkoutPreference, paymentData: self.properties.paymentData, chargeRules: self.properties.chargeRules, paymentConfigurationService: self.properties.paymentConfigurationService, splitAccountMoney: nil)
        }
    }

    init(flowProperties: InitFlowProperties) {
        self.properties = flowProperties
        self.loadPreferenceStatus = !String.isNullOrEmpty(flowProperties.checkoutPreference.id)
        self.directDiscountSearchStatus = flowProperties.paymentData.isComplete()
        super.init()
    }

    func update(paymentPlugin: PXSplitPaymentProcessor?, paymentMethodPlugins: [PXPaymentMethodPlugin], chargeRules: [PXPaymentTypeChargeRule]?) {
        properties.paymentPlugin = paymentPlugin
        properties.paymentMethodPlugins = paymentMethodPlugins
        properties.chargeRules = chargeRules
    }
}

// MARK: Public methods
extension InitFlowModel {
    func getService() -> MercadoPagoServicesAdapter {
        return properties.serviceAdapter
    }

    func getError() -> InitFlowError {
        if let error = flowError {
            return error
        }
        return InitFlowError(errorStep: .ERROR, shouldRetry: false, requestOrigin: nil, apiException: nil)
    }

    func setError(error: InitFlowError) {
        if error.errorStep != .SERVICE_PAYMENT_METHOD_PLUGIN_INIT {
            flowError = error
        }
    }

    func resetError() {
        flowError = nil
    }

    func setPendingRetry(forStep: Steps) {
        pendingRetryStep = forStep
    }

    func removePendingRetry() {
        pendingRetryStep = nil
    }

    func paymentMethodPluginDidLoaded() {
        needPaymentMethodPluginInit = false
    }

    func getExcludedPaymentTypesIds() -> [String] {
        if properties.checkoutPreference.siteId == "MLC" || properties.checkoutPreference.siteId == "MCO" ||
            properties.checkoutPreference.siteId == "MLV" {
            properties.checkoutPreference.addExcludedPaymentType("atm")
            properties.checkoutPreference.addExcludedPaymentType("bank_transfer")
            properties.checkoutPreference.addExcludedPaymentType("ticket")
        }
        return properties.checkoutPreference.getExcludedPaymentTypesIds()
    }

    func getDefaultPaymentMethodId() -> String? {
        return properties.checkoutPreference.getDefaultPaymentMethodId()
    }

    func getExcludedPaymentMethodsIds() -> [String] {
        return properties.checkoutPreference.getExcludedPaymentMethodsIds()
    }

    func updateInitModel(paymentMethodsResponse: PXPaymentMethodSearch?) {
        properties.paymentMethodSearchResult = paymentMethodsResponse
    }

    func getPaymentMethodSearch() -> PXPaymentMethodSearch? {
        return properties.paymentMethodSearchResult
    }

    func populateCheckoutStore() {
        PXCheckoutStore.sharedInstance.paymentDatas = [self.properties.paymentData]
        if let splitAccountMoney = amountHelper.splitAccountMoney {
            PXCheckoutStore.sharedInstance.paymentDatas.append(splitAccountMoney)
        }
        PXCheckoutStore.sharedInstance.checkoutPreference = self.properties.checkoutPreference
    }
}

// MARK: nextStep - State machine
extension InitFlowModel {
    func nextStep() -> Steps {
        if let retryStep = pendingRetryStep {
            pendingRetryStep = nil
            return retryStep
        }

        if hasError() {
            return .ERROR
        }

        if needLoadPreference() {
            loadPreferenceStatus = false
            return .SERVICE_GET_PREFERENCE
        }

        if needValidatePreference() {
            preferenceValidated = true
            return .ACTION_VALIDATE_PREFERENCE
        }

        if needToInitPaymentMethodPlugins() {
            return .SERVICE_PAYMENT_METHOD_PLUGIN_INIT
        }

        if needSearch() {
            return .SERVICE_GET_PAYMENT_METHODS
        }

        return .FINISH
    }
}

// MARK: Needs methods
extension InitFlowModel {
    private func needLoadPreference() -> Bool {
        return loadPreferenceStatus
    }

    private func needValidatePreference() -> Bool {
        return !loadPreferenceStatus && !preferenceValidated
    }

    private func needToInitPaymentMethodPlugins() -> Bool {
        if properties.paymentMethodPlugins.isEmpty {
            return false
        }
        return needPaymentMethodPluginInit
    }

    private func needSearch() -> Bool {
        return properties.paymentMethodSearchResult == nil
    }

    private func hasError() -> Bool {
        return flowError != nil
    }

    private func filterCampaignsByCodeType(campaigns: [PXCampaign]?, _ codeType: String) -> [PXCampaign]? {
        if let campaigns = campaigns {
            let filteredCampaigns = campaigns.filter { (campaign: PXCampaign) -> Bool in
                return campaign.codeType == codeType
            }
            if filteredCampaigns.isEmpty {
                return nil
            }
            return filteredCampaigns
        }
        return nil
    }
}
