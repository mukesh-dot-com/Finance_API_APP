import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Stock Data Viewer',
      debugShowCheckedModeBanner: false,
      home: StockDataScreen(),
    );
  }
}

class StockDataScreen extends StatefulWidget {
  const StockDataScreen({Key? key}) : super(key: key);

  @override
  _StockDataScreenState createState() => _StockDataScreenState();
}

class _StockDataScreenState extends State<StockDataScreen> {
  final TextEditingController _controller = TextEditingController();
  late Future<YahooFinanceResponse> _futureData;

  @override
  void initState() {
    super.initState();
    loadStockData('GOOG'); // Load initial data for "GOOG"
  }

  Future<void> loadStockData(String companyCode) async {
    _futureData = YahooFinanceDailyReader().getDailyDTOs(companyCode);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Data Viewer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter Company Code',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    loadStockData(_controller.text);
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder(
                future: _futureData,
                builder: (BuildContext context,
                    AsyncSnapshot<YahooFinanceResponse> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    final YahooFinanceResponse response = snapshot.data!;
                    return ListView.builder(
                      itemCount: response.candlesData.length,
                      itemBuilder: (BuildContext context, int index) {
                        final YahooFinanceCandleData candle =
                            response.candlesData[index];
                        return _buildCandleCard(candle);
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('No data found'),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandleCard(YahooFinanceCandleData candle) {
    final String date = DateFormat.yMMMd().format(candle.date);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: $date'),
            const SizedBox(height: 8),
            Text('Open: ${candle.open.toStringAsFixed(2)}'),
            Text('Close: ${candle.close.toStringAsFixed(2)}'),
            Text('Low: ${candle.low.toStringAsFixed(2)}'),
            Text('High: ${candle.high.toStringAsFixed(2)}'),
            Text('Volume: ${candle.volume}'),
            Text('Adj Close: ${candle.adjClose.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
