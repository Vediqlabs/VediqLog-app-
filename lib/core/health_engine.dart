class HealthRange {
  final double min;
  final double max;

  HealthRange(this.min, this.max);
}

HealthRange getHealthyWeightRange(double heightCm) {
  final heightM = heightCm / 100;

  final minWeight = 18.5 * heightM * heightM;
  final maxWeight = 24.9 * heightM * heightM;

  return HealthRange(minWeight, maxWeight);
}

HealthRange getSugarRange({
  required bool isDiabetic,
  required bool isFasting,
}) {
  if (isDiabetic) {
    if (isFasting) {
      return HealthRange(80, 130);
    } else {
      return HealthRange(100, 180);
    }
  } else {
    if (isFasting) {
      return HealthRange(70, 99);
    } else {
      return HealthRange(70, 140);
    }
  }
}

HealthRange getHemoglobinRange(String gender) {
  if (gender.toLowerCase() == "male") {
    return HealthRange(13.5, 17.5);
  } else {
    return HealthRange(12.0, 15.5);
  }
}

HealthRange getHeartRateRange(int age) {
  if (age < 18) {
    return HealthRange(70, 110);
  } else if (age < 60) {
    return HealthRange(60, 100);
  } else {
    return HealthRange(60, 95);
  }
}

HealthRange? resolveHealthRange({
  required String metric,
  required double? height,
  required int age,
  required String gender,
  required bool isDiabetic,
  bool isFasting = false,
}) {
  switch (metric.toLowerCase()) {
    case "weight":
      if (height != null) {
        return getHealthyWeightRange(height);
      }
      break;

    case "blood sugar":
      return getSugarRange(
        isDiabetic: isDiabetic,
        isFasting: isFasting,
      );

    case "hemoglobin":
      return getHemoglobinRange(gender);

    case "heart rate":
      return getHeartRateRange(age);

    case "blood pressure":
      return HealthRange(90, 120); // systolic normal

    case "Cholesterol":
      return HealthRange(125, 200);

    case "TSH":
      return HealthRange(0.4, 4.0);
  }

  return null;
}

double? calculateBMI({
  required double? heightCm,
  required double weightKg,
}) {
  if (heightCm == null || heightCm == 0) return null;

  final heightM = heightCm / 100;
  return weightKg / (heightM * heightM);
}

String getBMICategory(double bmi) {
  if (bmi < 18.5) return "Underweight";
  if (bmi < 25) return "Normal";
  if (bmi < 30) return "Overweight";
  return "Obese";
}

String getCholesterolCategory(double value) {
  if (value < 200) {
    return "Normal";
  } else if (value < 240) {
    return "Borderline";
  } else {
    return "High";
  }
}

String getHbA1cCategory(double value) {
  if (value < 5.7) {
    return "Normal";
  } else if (value < 6.5) {
    return "Prediabetes";
  } else {
    return "Diabetes";
  }
}

String getTSHCategory(double value) {
  if (value < 0.4) {
    return "Low";
  } else if (value <= 4.0) {
    return "Normal";
  } else {
    return "High";
  }
}

String getHeartRateCategory(double value, int age) {
  double min;
  double max;

  if (age < 18) {
    min = 70;
    max = 110;
  } else if (age <= 60) {
    min = 60;
    max = 100;
  } else {
    min = 60;
    max = 95;
  }

  if (value < min) return "Low";
  if (value > max) return "High";
  return "Normal";
}

String getMetricStatus({
  required String title,
  required double value,
  double? systolic,
  double? diastolic,
  double? heightCm,
  int age = 30,
  String gender = "Male",
  bool isDiabetic = false,
}) {
  // ✅ Sleep
  if (title == "Sleep Hours") {
    if (value < 5) return "CRITICAL_LOW";
    if (value < 6) return "LOW";
    if (value <= 8) return "OPTIMAL";
    if (value <= 9) return "SLIGHTLY_HIGH";
    return "HIGH";
  }

  // ✅ Steps
  if (title == "Steps") {
    if (value < 3000) return "SEDENTARY";
    if (value < 6000) return "LOW_ACTIVITY";
    if (value <= 10000) return "MODERATE";
    return "ACTIVE";
  }

  // ✅ TSH
  if (title == "TSH") {
    if (value < 0.4) return "LOW";
    if (value > 4.0) return "HIGH";
    return "NORMAL";
  }

  // ✅ Cholesterol
  if (title == "Cholesterol") {
    if (value >= 240) return "HIGH";
    if (value >= 200) return "BORDERLINE";
    return "NORMAL";
  }

  // ✅ Hemoglobin
  if (title == "Hemoglobin") {
    if (gender == "Female") {
      if (value < 12.0) return "LOW";
      if (value > 15.5) return "HIGH";
    } else {
      if (value < 13.5) return "LOW";
      if (value > 17.5) return "HIGH";
    }
    return "NORMAL";
  }

  // ✅ HbA1c
  if (title == "HbA1c") {
    if (value >= 6.5) return "HIGH";
    if (value >= 5.7) return "PREDIABETES";
    return "NORMAL";
  }

  // ✅ Heart Rate
  if (title == "Heart Rate") {
    double min = age < 18 ? 70 : 60;
    double max = age <= 60 ? 100 : 95;

    if (value < min) return "LOW";
    if (value > max) return "HIGH";
    return "NORMAL";
  }

  // ✅ Blood Sugar
  if (title == "Blood Sugar") {
    if (isDiabetic) {
      if (value < 80) return "LOW";
      if (value > 180) return "HIGH";
    } else {
      if (value < 70) return "LOW";
      if (value > 140) return "HIGH";
    }
    return "NORMAL";
  }

  // ✅ Blood Pressure (real logic)
  if (title == "Blood Pressure" && systolic != null && diastolic != null) {
    if (systolic < 120 && diastolic < 80) return "NORMAL";
    if (systolic < 130 && diastolic < 80) return "ELEVATED";
    if (systolic < 140 || diastolic < 90) return "HIGH_STAGE_1";
    return "HIGH_STAGE_2";
  }

  // ✅ Weight (BMI based)
  if (title == "Weight" && heightCm != null) {
    final bmi = value / ((heightCm / 100) * (heightCm / 100));

    if (bmi < 18.5) return "LOW";
    if (bmi < 25) return "NORMAL";
    if (bmi < 30) return "OVERWEIGHT";
    return "OBESE";
  }

  // ✅ Vitamin D
  if (title == "Vitamin D") {
    if (value < 20) return "DEFICIENT";
    if (value < 30) return "INSUFFICIENT";
    if (value <= 100) return "NORMAL";
    return "HIGH";
  }
  return "NORMAL";
}
