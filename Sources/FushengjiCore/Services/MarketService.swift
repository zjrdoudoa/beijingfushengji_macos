import Foundation

public final class MarketService {
    public init() {}

    public func generateMarket(
        location: Location,
        products: [Product],
        rng: inout SeededRandomNumberGenerator
    ) -> [MarketPrice] {
        products.map { product in
            let modifier = location.marketModifiers[product.id] ?? 1.0
            let adjustedMin = max(1, Int((Double(product.minPrice) * modifier).rounded()))
            let adjustedMax = max(adjustedMin, Int((Double(product.maxPrice) * modifier).rounded()))
            let price = rng.nextInt(in: adjustedMin...adjustedMax)

            return MarketPrice(
                productID: product.id,
                locationID: location.id,
                price: price,
                trendKey: trendKey(for: price, product: product)
            )
        }
    }

    public func price(for productID: String, in market: [MarketPrice]) -> MarketPrice? {
        market.first(where: { $0.productID == productID })
    }

    private func trendKey(for price: Int, product: Product) -> String? {
        if price <= product.minPrice {
            return "trend.low"
        }
        if price >= product.maxPrice {
            return "trend.high"
        }
        return "trend.normal"
    }
}
