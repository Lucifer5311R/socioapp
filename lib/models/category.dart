// lib/models/category.dart

import 'package:flutter/material.dart'; // For IconData

class Category {
  // If fetching from DB later, add id, etc.
  final String title;
  final String subtitle; // e.g., "30+ events"
  final IconData icon;

  Category({required this.title, required this.subtitle, required this.icon});

  // Add fromJson/toJson if fetching from Supabase table later
}
