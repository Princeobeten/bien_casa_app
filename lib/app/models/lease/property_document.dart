/// PropertyDocument Model - Document management
/// Represents documents related to properties, leases, and applications
class PropertyDocument {
  final String id;
  final String? houseLeaseId; // For property ownership documents
  final String? leaseApplicationId; // For tenant application documents
  final String documentType; // 'ownership_proof', 'realtor_license', 'tenant_id', 'tenant_income_proof', 'lease_agreement'
  final String documentUrl;
  final String uploadedBy; // User ID who uploaded
  final String verificationStatus; // 'Pending', 'Verified', 'Rejected'
  final String? verifiedBy; // Admin ID who verified
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields
  final String? documentName;
  final String? rejectionReason;
  final int? fileSize; // in bytes
  final String? mimeType;

  PropertyDocument({
    required this.id,
    this.houseLeaseId,
    this.leaseApplicationId,
    required this.documentType,
    required this.documentUrl,
    required this.uploadedBy,
    required this.verificationStatus,
    this.verifiedBy,
    this.verifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.documentName,
    this.rejectionReason,
    this.fileSize,
    this.mimeType,
  });

  /// Create PropertyDocument from JSON
  factory PropertyDocument.fromJson(Map<String, dynamic> json) {
    return PropertyDocument(
      id: json['id'] as String,
      houseLeaseId: json['houseLeaseId'] as String?,
      leaseApplicationId: json['leaseApplicationId'] as String?,
      documentType: json['documentType'] as String,
      documentUrl: json['documentUrl'] as String,
      uploadedBy: json['uploadedBy'] as String,
      verificationStatus: json['verificationStatus'] as String,
      verifiedBy: json['verifiedBy'] as String?,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      documentName: json['documentName'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      fileSize: json['fileSize'] as int?,
      mimeType: json['mimeType'] as String?,
    );
  }

  /// Convert PropertyDocument to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'houseLeaseId': houseLeaseId,
      'leaseApplicationId': leaseApplicationId,
      'documentType': documentType,
      'documentUrl': documentUrl,
      'uploadedBy': uploadedBy,
      'verificationStatus': verificationStatus,
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'documentName': documentName,
      'rejectionReason': rejectionReason,
      'fileSize': fileSize,
      'mimeType': mimeType,
    };
  }

  /// Create a copy with updated fields
  PropertyDocument copyWith({
    String? id,
    String? houseLeaseId,
    String? leaseApplicationId,
    String? documentType,
    String? documentUrl,
    String? uploadedBy,
    String? verificationStatus,
    String? verifiedBy,
    DateTime? verifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? documentName,
    String? rejectionReason,
    int? fileSize,
    String? mimeType,
  }) {
    return PropertyDocument(
      id: id ?? this.id,
      houseLeaseId: houseLeaseId ?? this.houseLeaseId,
      leaseApplicationId: leaseApplicationId ?? this.leaseApplicationId,
      documentType: documentType ?? this.documentType,
      documentUrl: documentUrl ?? this.documentUrl,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      documentName: documentName ?? this.documentName,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
    );
  }

  /// Check if document is pending verification
  bool get isPending => verificationStatus == 'Pending';

  /// Check if document is verified
  bool get isVerified => verificationStatus == 'Verified';

  /// Check if document is rejected
  bool get isRejected => verificationStatus == 'Rejected';

  /// Check if document is for property ownership
  bool get isOwnershipDocument =>
      documentType == 'ownership_proof' || documentType == 'realtor_license';

  /// Check if document is for tenant application
  bool get isTenantDocument =>
      documentType == 'tenant_id' || documentType == 'tenant_income_proof';

  /// Check if document is lease agreement
  bool get isLeaseAgreement => documentType == 'lease_agreement';

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSize == null) return 'Unknown size';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get document type display name
  String get documentTypeDisplay {
    switch (documentType) {
      case 'ownership_proof':
        return 'Ownership Proof';
      case 'realtor_license':
        return 'Realtor License';
      case 'tenant_id':
        return 'Tenant ID';
      case 'tenant_income_proof':
        return 'Income Proof';
      case 'lease_agreement':
        return 'Lease Agreement';
      default:
        return documentType;
    }
  }

  /// Get verification status color
  String get statusColor {
    if (isPending) return 'orange';
    if (isVerified) return 'green';
    if (isRejected) return 'red';
    return 'grey';
  }
}

/// Enum for document type
enum DocumentType {
  ownershipProof,
  realtorLicense,
  tenantId,
  tenantIncomeProof,
  leaseAgreement;

  String get value {
    switch (this) {
      case DocumentType.ownershipProof:
        return 'ownership_proof';
      case DocumentType.realtorLicense:
        return 'realtor_license';
      case DocumentType.tenantId:
        return 'tenant_id';
      case DocumentType.tenantIncomeProof:
        return 'tenant_income_proof';
      case DocumentType.leaseAgreement:
        return 'lease_agreement';
    }
  }

  String get displayName {
    switch (this) {
      case DocumentType.ownershipProof:
        return 'Ownership Proof';
      case DocumentType.realtorLicense:
        return 'Realtor License';
      case DocumentType.tenantId:
        return 'Tenant ID';
      case DocumentType.tenantIncomeProof:
        return 'Income Proof';
      case DocumentType.leaseAgreement:
        return 'Lease Agreement';
    }
  }
}

/// Enum for verification status
enum VerificationStatus {
  pending,
  verified,
  rejected;

  String get value {
    switch (this) {
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
    }
  }
}
