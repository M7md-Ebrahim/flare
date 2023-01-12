//
// Flare
// Copyright © 2023 Space Code. All rights reserved.
//

import StoreKit

public typealias ProductHandler = (_ result: Result<[SKProduct], IAPError>) -> Void
public typealias PaymentHandler = (_ queue: PaymentQueue, _ result: Result<SKPaymentTransaction, IAPError>) -> Void
public typealias RestoreHandler = (_ queue: SKPaymentQueue, _ error: IAPError?) -> Void
public typealias ShouldAddStorePaymentHandler = (_ queue: SKPaymentQueue, _ payment: SKPayment, _ product: SKProduct) -> Bool
public typealias ReceiptRefreshHandler = (Result<Void, IAPError>) -> Void

// MARK: - IProductProvider

public protocol IProductProvider {
    typealias ProductsHandler = Closure<Result<[SKProduct], IAPError>>

    func fetch(productIds: Set<String>, requestId: String, completion: @escaping ProductsHandler)
}
