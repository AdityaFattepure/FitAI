class Workout {
  final String id;
  final String name;
  final String description;
  final String targetMuscle;
  final String difficulty;
  final int duration; // in seconds
  final String iconEmoji;

  Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.targetMuscle,
    required this.difficulty,
    required this.duration,
    required this.iconEmoji,
  });
}

class WorkoutSession {
  final String workoutName;
  final int reps;
  final DateTime timestamp;
  final int duration;
  final double accuracy;

  WorkoutSession({
    required this.workoutName,
    required this.reps,
    required this.timestamp,
    required this.duration,
    required this.accuracy,
  });

  Map<String, dynamic> toJson() => {
    'workoutName': workoutName,
    'reps': reps,
    'timestamp': timestamp.toIso8601String(),
    'duration': duration,
    'accuracy': accuracy,
  };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
    workoutName: json['workoutName'] ?? '',
    reps: json['reps'] ?? 0,
    timestamp: DateTime.parse(json['timestamp']),
    duration: json['duration'] ?? 0,
    accuracy: json['accuracy'] ?? 0.0,
  );
}

// Predefined workouts
final List<Workout> availableWorkouts = [
  Workout(
    id: 'squat',
    name: 'Squats',
    description: 'Lower body strength exercise',
    targetMuscle: 'Legs & Glutes',
    difficulty: 'Beginner',
    duration: 300,
    iconEmoji: '🦵',
  ),
  Workout(
    id: 'pushup',
    name: 'Push-ups',
    description: 'Upper body and core strength',
    targetMuscle: 'Chest & Arms',
    difficulty: 'Intermediate',
    duration: 300,
    iconEmoji: '💪',
  ),
  Workout(
    id: 'plank',
    name: 'Plank Hold',
    description: 'Core stability exercise',
    targetMuscle: 'Core & Abs',
    difficulty: 'Beginner',
    duration: 180,
    iconEmoji: '🧘',
  ),
  Workout(
    id: 'lunge',
    name: 'Lunges',
    description: 'Single leg strength',
    targetMuscle: 'Legs & Balance',
    difficulty: 'Intermediate',
    duration: 300,
    iconEmoji: '🏃',
  ),
];