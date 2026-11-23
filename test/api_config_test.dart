import 'package:flutter_test/flutter_test.dart';
import 'package:tamajiwa/constants/api_config.dart';

void main() {
  test('defaults to the local backend instead of a hard-coded host', () {
    expect(ApiConfig.currentBaseUrl, anyOf('http://127.0.0.1:8000/api', 'http://10.0.2.2:8000/api'));
    expect(ApiConfig.currentBaseUrl, isNot(contains('bilcode')));
  });

  test('endpoint helpers build the expected paths', () {
    expect(ApiConfig.formReviewEndpoint('5'), '/forms/5/review');
    expect(ApiConfig.formGeneratePdfEndpoint('5'), '/forms/5/generate-pdf');
  });
}
