// lib/models/club_centre.dart

class ClubCentre {
  final String name;
  final String abbreviation;
  final String description;
  final String? logoAsset; // Path to a local asset (optional)

  const ClubCentre({
    required this.name,
    required this.abbreviation,
    required this.description,
    this.logoAsset,
  });
}
