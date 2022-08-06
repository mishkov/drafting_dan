List<List<double>> multiplyMatrix(
    List<List<double>> m1, List<List<double>> m2) {
  List<List<double>> result = [];
  for (int j = 0; j < m1.length; j++) {
    result.insert(j, []);
    for (int k = 0; k < m2[0].length; k++) {
      double sum = 0.0;
      for (int i = 0; i < m2.length; i++) {
        sum += m2[i][k] * m1[j][i];
      }
      result[j].add(sum);
    }
  }
  return result;
}
