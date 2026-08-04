class SurveyModel {
  final String id;
  final String title;
  final String? description;
  final String type; // "USER_SATISFACTION" or "SUS"
  final String status;
  final bool isActive;
  final bool hasSubmitted;
  final int questionCount;
  final List<SurveyQuestionModel> questions;

  const SurveyModel({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    required this.isActive,
    this.hasSubmitted = false,
    required this.questionCount,
    this.questions = const [],
  });

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    var rawQs = json['questions'] as List<dynamic>? ?? [];
    List<SurveyQuestionModel> parsedQs = rawQs
        .map((e) => SurveyQuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return SurveyModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'USER_SATISFACTION',
      status: json['status'] as String? ?? 'published',
      isActive: json['is_active'] as bool? ?? false,
      hasSubmitted: json['has_submitted'] as bool? ?? false,
      questionCount: (json['question_count'] as num?)?.toInt() ?? parsedQs.length,
      questions: parsedQs,
    );
  }

  bool get isSUS => type == 'SUS';
}

class SurveyQuestionModel {
  final String id;
  final String surveyId;
  final String questionText;
  final String? description;
  final String? imageUrl;
  final String? svgIllustration;
  final List<String> likertLabels;
  final bool isRequired;
  final int displayOrder;

  const SurveyQuestionModel({
    required this.id,
    required this.surveyId,
    required this.questionText,
    this.description,
    this.imageUrl,
    this.svgIllustration,
    this.likertLabels = const [
      'Sangat Tidak Setuju',
      'Tidak Setuju',
      'Netral',
      'Setuju',
      'Sangat Setuju',
    ],
    this.isRequired = true,
    required this.displayOrder,
  });

  factory SurveyQuestionModel.fromJson(Map<String, dynamic> json) {
    var rawLabels = json['likert_labels'] as List<dynamic>? ?? [];
    List<String> parsedLabels = rawLabels.map((e) => e.toString()).toList();
    if (parsedLabels.isEmpty) {
      parsedLabels = [
        'Sangat Tidak Setuju',
        'Tidak Setuju',
        'Netral',
        'Setuju',
        'Sangat Setuju',
      ];
    }

    return SurveyQuestionModel(
      id: json['id'] as String? ?? '',
      surveyId: json['survey_id'] as String? ?? '',
      questionText: json['question_text'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      svgIllustration: json['svg_illustration'] as String?,
      likertLabels: parsedLabels,
      isRequired: json['is_required'] as bool? ?? true,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
    );
  }
}
