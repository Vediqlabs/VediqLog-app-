class MetricConfig {
  final String unit;
  final double? min;
  final double? max;

  const MetricConfig({
    required this.unit,
    this.min,
    this.max,
  });
}

const Map<String, MetricConfig> metricConfigs = {
  "Weight": MetricConfig(unit: "kg", min: 45, max: 85),
  "Heart Rate": MetricConfig(unit: "bpm", min: 60, max: 100),
  "Blood Pressure": MetricConfig(unit: "mmHg", min: 90, max: 120),
  "Blood Sugar": MetricConfig(unit: "mg/dL", min: 70, max: 140),
  "HbA1c": MetricConfig(unit: "%", min: 4, max: 5.6),
  "Hemoglobin": MetricConfig(unit: "g/dL", min: 12, max: 17),
  "Cholesterol": MetricConfig(unit: "mg/dL", min: 125, max: 200),
  "Vitamin D": MetricConfig(unit: "ng/mL", min: 20, max: 50),
  "TSH": MetricConfig(unit: "mIU/L", min: 0.4, max: 4.0),
  "Steps": MetricConfig(unit: "steps", min: 6000, max: 10000),
  "Sleep Hours": MetricConfig(unit: "hrs", min: 6, max: 9),
};
