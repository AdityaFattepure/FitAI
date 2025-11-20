class UserProfile {
  final String name;
  final int age;
  final double weight;
  final double height;
  final String fitnessGoal;
  final String experienceLevel;

  UserProfile({
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.fitnessGoal,
    required this.experienceLevel,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'weight': weight,
    'height': height,
    'fitnessGoal': fitnessGoal,
    'experienceLevel': experienceLevel,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? '',
    age: json['age'] ?? 0,
    weight: json['weight'] ?? 0.0,
    height: json['height'] ?? 0.0,
    fitnessGoal: json['fitnessGoal'] ?? 'General Fitness',
    experienceLevel: json['experienceLevel'] ?? 'Beginner',
  );

  double get bmi => weight / ((height / 100) * (height / 100));
  
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}