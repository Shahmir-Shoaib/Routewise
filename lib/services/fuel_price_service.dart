import 'dart:convert';
import 'package:http/http.dart' as http;

class FuelApiService {
  Future<double> getFuelPrice() async {
    final response =
        await http.get(Uri.parse("https://mock-fuel-api.com/petrol"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["price"];
    }

    return 280; // fallback mock price
  }
}
