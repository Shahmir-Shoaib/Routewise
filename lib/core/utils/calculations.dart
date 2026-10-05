class CostCalculator {
  static double calculateFuelCost({
    required double distance,
    required double fuelAvg,
    required double fuelPrice,
  }) {
    return (distance / fuelAvg) * fuelPrice;
  }

  static double calculateTimeCost({
    required double distance,
    required double speed,
  }) {
    return distance / speed;
  }
}
