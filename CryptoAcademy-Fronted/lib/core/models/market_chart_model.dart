class ChartDataPoint {
  final DateTime date;
  final double price;

  ChartDataPoint({required this.date, required this.price});

}

class MarketChartData {
  final List<ChartDataPoint> prices;

  MarketChartData({
    required this.prices,
  });

  factory MarketChartData.fromJson(Map<String, dynamic> json) {
    List<ChartDataPoint> parsedPrices = [];
    if (json['prices'] != null && json['prices'] is List) {
      for (var item in (json['prices'] as List)) {
        if (item is List && item.length == 2 && item[0] is num && item[1] is num) {
          // El timestamp de CoinGecko viene en milisegundos
          parsedPrices.add(ChartDataPoint(
            date: DateTime.fromMillisecondsSinceEpoch((item[0] as num).toInt(), isUtc: true),
            price: (item[1] as num).toDouble(),
          ));
        }
      }
    }

    return MarketChartData(
      prices: parsedPrices,
    );
  }
}
