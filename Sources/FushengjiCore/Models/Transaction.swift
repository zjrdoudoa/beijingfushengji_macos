import Foundation

public enum TransactionKind: String, Codable, Equatable, Hashable {
    case buy
    case sell
    case travel
    case debtPayment
    case debtBorrow
}

public struct Transaction: Codable, Hashable, Identifiable {
    public var id: UUID
    public var day: Int
    public var kind: TransactionKind
    public var productID: String?
    public var quantity: Int
    public var unitPrice: Int
    public var total: Int
    public var locationID: String
    public var timestamp: Date

    public init(
        id: UUID = UUID(),
        day: Int,
        kind: TransactionKind,
        productID: String? = nil,
        quantity: Int = 0,
        unitPrice: Int = 0,
        total: Int,
        locationID: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.day = day
        self.kind = kind
        self.productID = productID
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.total = total
        self.locationID = locationID
        self.timestamp = timestamp
    }

    public static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.id == rhs.id
            && lhs.day == rhs.day
            && lhs.kind == rhs.kind
            && lhs.productID == rhs.productID
            && lhs.quantity == rhs.quantity
            && lhs.unitPrice == rhs.unitPrice
            && lhs.total == rhs.total
            && lhs.locationID == rhs.locationID
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(day)
        hasher.combine(kind)
        hasher.combine(productID)
        hasher.combine(quantity)
        hasher.combine(unitPrice)
        hasher.combine(total)
        hasher.combine(locationID)
    }
}
