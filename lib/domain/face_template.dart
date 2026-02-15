/// A stored face identity used for verification.
///
/// Contains a normalized feature vector extracted from face contours
/// and metadata for identification.
class FaceTemplate {
  FaceTemplate({
    required this.id,
    required this.label,
    required this.features,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Unique identifier for this template.
  final String id;

  /// Human-readable label (e.g. a person's name).
  final String label;

  /// Normalized contour feature vector used for matching.
  final List<double> features;

  /// When this template was created.
  final DateTime createdAt;

  /// Serialize to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'features': features,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Deserialize from a JSON map.
  factory FaceTemplate.fromJson(Map<String, dynamic> json) => FaceTemplate(
        id: json['id'] as String,
        label: json['label'] as String,
        features: (json['features'] as List).cast<double>(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

/// Result of a face verification attempt.
class FaceVerificationResult {
  const FaceVerificationResult({
    required this.isMatch,
    required this.confidence,
    this.matchedTemplateId,
  });

  /// Whether the face matched an enrolled template.
  final bool isMatch;

  /// Similarity score between 0.0 and 1.0.
  final double confidence;

  /// ID of the matched template, or null if no match.
  final String? matchedTemplateId;
}

/// Result of a liveness check.
class LivenessResult {
  const LivenessResult({
    required this.isLive,
    this.reason,
  });

  /// Whether the face belongs to a live person.
  final bool isLive;

  /// Human-readable reason when [isLive] is false.
  final String? reason;
}

/// Policy for handling multiple detected faces.
enum MultiFacePolicy {
  /// Lock if more than one face is visible (most secure).
  lockIfMultiple,

  /// Unlock if any detected face matches an enrolled template.
  unlockIfAnyMatch,

  /// Only unlock if ALL detected faces match enrolled templates.
  unlockIfAllMatch,
}
