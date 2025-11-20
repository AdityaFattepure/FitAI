import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:fitai_posture_app/models/user_profile.dart';

class AiCoachService {
  static const String apiKey = 'AIzaSyAUXYDUy_VaMPH6eefk-KX37BnPE0p7JME';
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  AiCoachService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
  }

  /// Initialize chat session with user profile context
  void initializeChat(UserProfile userProfile) {
    final systemPrompt = _buildSystemPrompt(userProfile);
    
    _chatSession = _model.startChat(
      history: [
        Content.text(systemPrompt),
        Content.model([TextPart(
          'I understand. I\'m your personalized AI fitness coach. '
          'I will provide advice tailored to your profile: '
          '${userProfile.name}, ${userProfile.age} years old, '
          '${userProfile.weight}kg, ${userProfile.height}cm tall, '
          'with a goal of ${userProfile.fitnessGoal}. '
          'Your experience level is ${userProfile.experienceLevel}. '
          'Your BMI is ${userProfile.bmi.toStringAsFixed(1)} (${userProfile.bmiCategory}). '
          'How can I help you today?'
        )])
      ],
    );
  }

  /// Build a comprehensive system prompt with user context
  String _buildSystemPrompt(UserProfile userProfile) {
    return '''You are an expert, personalized AI fitness coach. You have the following information about your client:

**Client Profile:**
- Name: ${userProfile.name}
- Age: ${userProfile.age} years old
- Weight: ${userProfile.weight} kg
- Height: ${userProfile.height} cm
- BMI: ${userProfile.bmi.toStringAsFixed(1)} (${userProfile.bmiCategory})
- Fitness Goal: ${userProfile.fitnessGoal}
- Experience Level: ${userProfile.experienceLevel}

**Your Role:**
You are a knowledgeable, supportive, and encouraging fitness coach. For every question or request the client makes, provide personalized advice that:
1. Takes into account their specific age, weight, height, and BMI
2. Aligns with their stated fitness goal (${userProfile.fitnessGoal})
3. Matches their experience level (${userProfile.experienceLevel})
4. Includes practical, actionable recommendations
5. Prioritizes safety and sustainable habits
6. Is motivating and supportive in tone

**Guidelines:**
- Provide specific exercises, nutrition tips, or training advice tailored to their profile
- Consider their BMI category (${userProfile.bmiCategory}) when making recommendations
- Adapt intensity and volume recommendations based on their experience level
- Always remind them to consult a healthcare professional for medical concerns
- Give realistic timelines and expectations
- Encourage consistency and progressive improvement

Now, help ${userProfile.name} achieve their fitness goals!''';
  }

  /// Send a message to the AI coach and get a response
  Future<String> sendMessage(String userMessage) async {
    try {
      final response = await _chatSession.sendMessage(
        Content.text(userMessage),
      );
      
      if (response.text != null) {
        return response.text!;
      } else {
        return 'Sorry, I couldn\'t generate a response. Please try again.';
      }
    } catch (e) {
      return 'Error: Unable to reach AI coach. Please check your connection and try again. ($e)';
    }
  }

  /// Get chat history
  List<Content> getChatHistory() {
    return _chatSession.history.toList();
  }

  /// Reinitialize chat session (creates a new one)
  void resetChat(UserProfile userProfile) {
    initializeChat(userProfile);
  }
}
