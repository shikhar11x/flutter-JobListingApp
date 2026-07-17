import 'dart:convert';
import 'package:intl/intl.dart';

class Job {
  final int id;
  final String name;
  final String companyName;
  final String briefing;
  final int? minExperience;
  final int? maxExperience;
  final int? minSalary;
  final int? maxSalary;
  final int? noOfPositions;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool hideCompanyName;
  final int? referralAmount;

  Job({
    required this.id,
    required this.name,
    required this.companyName,
    required this.briefing,
    this.minExperience,
    this.maxExperience,
    this.minSalary,
    this.maxSalary,
    this.noOfPositions,
    this.createdDate,
    this.updatedDate,
    this.startDate,
    this.endDate,
    this.hideCompanyName = false,
    this.referralAmount,
  });

  /// The API sometimes double-encodes the `briefing` HTML — the string
  /// itself is wrapped in an extra pair of quotes and its inner quotes
  /// are backslash-escaped, e.g.:
  ///   "\"<p class=\\\"mb-2\\\">...\""
  /// Once Dart's json.decode parses the outer JSON, what's left in
  /// `briefing` is a string that STILL looks like a JSON string literal.
  /// This strips that extra layer so we're left with clean HTML.
  static String _cleanBriefing(String raw) {
    var cleaned = raw.trim();
    if (cleaned.isEmpty) return cleaned;

    // Case 1: the whole thing decodes cleanly as a JSON string literal.
    if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
      try {
        final decoded = json.decode(cleaned);
        if (decoded is String) {
          cleaned = decoded;
        }
      } catch (_) {
        // Case 2: not valid JSON (e.g. unbalanced quotes) — fall back to
        // manually stripping the wrapping quotes and unescaping.
        cleaned = cleaned.substring(1, cleaned.length - 1);
      }
    }

    // Belt-and-braces: unescape any remaining escaped quotes/backslashes
    // that survive either path above (handles inconsistent double/triple
    // escaping from the backend).
    cleaned = cleaned
        .replaceAll(r'\\"', '"')
        .replaceAll(r'\"', '"')
        .replaceAll(r'\\', r'\');

    return cleaned.trim();
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    // 1. Helper to safely parse DateTimes
    DateTime? _parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    // 2. Helper to safely convert incoming types (double, int, or String) into clean ints
    int? _parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt(); // Truncates decimal parts safely
      if (value is String) {
        return int.tryParse(value) ?? double.tryParse(value)?.toInt();
      }
      return null;
    }

    return Job(
      id: _parseInt(json['id']) ?? 0,
      name: (json['name'] ?? 'Untitled Role').toString(),
      companyName: (json['CompanyName'] ?? 'Company not disclosed').toString(),
      briefing: _cleanBriefing((json['briefing'] ?? '').toString()),

      // Numerical keys wrapped using type safety parser
      minExperience: _parseInt(json['min_experience']),
      maxExperience: _parseInt(json['max_experience']),
      minSalary: _parseInt(json['min_salary']),
      maxSalary: _parseInt(json['max_salary']),
      noOfPositions: _parseInt(json['no_of_positions']),
      referralAmount: _parseInt(json['referral_amount']),

      createdDate: _parseDate(json['created_date']),
      updatedDate: _parseDate(json['updated_date']),
      startDate: _parseDate(json['start_date']),
      endDate: _parseDate(json['end_date']),
      hideCompanyName: json['hide_company_name'] ?? false,
    );
  }

  // ---- COMPATIBILITY GETTERS FOR YOUR UI SCREEN ----

  /// Maps `descriptionHtml` to `briefing` since it holds the HTML description content
  String? get descriptionHtml => briefing;

  /// Maps `positions` to `noOfPositions` for the UI opening badge
  int? get positions => noOfPositions;

  /// Exposes a key-value map for the metadata card in the UI.
  /// This aggregates model parameters cleanly so `_buildDetailsCard()` works dynamically.
  Map<String, dynamic> get rawFields {
    final fields = <String, dynamic>{};
    if (startDate != null) {
      fields['Start Date'] = DateFormat('dd MMM yyyy').format(startDate!);
    }
    if (endDate != null) {
      fields['End Date'] = DateFormat('dd MMM yyyy').format(endDate!);
    }
    if (referralAmount != null && referralAmount! > 0) {
      fields['Referral Bonus'] = '₹$referralAmount';
    }
    return fields;
  }

  // ---- Existing derived / display helpers ----

  String get displayCompany =>
      hideCompanyName ? 'Confidential Company' : companyName;

  String get postedDateFormatted {
    if (createdDate == null) return 'Date not available';
    return DateFormat('dd MMM yyyy').format(createdDate!);
  }

  String get experienceRange {
    if (minExperience == null && maxExperience == null) return 'Not specified';
    return '${minExperience ?? 0}-${maxExperience ?? '?'} yrs';
  }

  String get salaryRange {
    if (minSalary == null || maxSalary == null) return 'Not disclosed';
    final formatter = NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹');
    return '${formatter.format(minSalary)} - ${formatter.format(maxSalary)}';
  }

  /// Location isn't a first-class field in this API — try to sniff it out
  /// of the briefing text as a best-effort. Returns null if not found.
  String? get parsedLocation {
    final regex = RegExp(
      r'Location[:\s]*<\/?[a-z]*>?\s*([A-Za-z,\s\-]{3,40})',
      caseSensitive: false,
    );
    final match = regex.firstMatch(briefing);
    if (match != null) {
      return match.group(1)?.trim().split('<').first.trim();
    }
    return null;
  }
}