import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// A helper class for parsing dates in various formats
class DateParserHelper {
  
  /// Parse a date string in various formats
  /// 
  /// Supports:
  /// - "April22025", "april22025" (month name + day + year)
  /// - "Apr22025", "apr22025" (abbreviated month + day + year)
  /// - "04022025", "040220205" (numeric: MM/DD/YYYY no separators)
  /// - "04/02/2025" (slash-delimited date)
  static DateTime? parseDate(String dateStr) {
    if (kDebugMode) {
      print('Attempting to parse date: $dateStr');
    }
    
    // Try to parse each format
    DateTime? result;
    
    // 1. Try month name formats (April22025, apr22025)
    result = _parseMonthNameFormat(dateStr);
    if (result != null) return result;
    
    // 2. Try numeric format with slashes (04/02/2025)
    result = _parseSlashFormat(dateStr);
    if (result != null) return result;
    
    // 3. Try numeric format without slashes (04022025)
    result = _parseNumericFormat(dateStr);
    if (result != null) return result;
    
    if (kDebugMode) {
      print('Failed to parse date: $dateStr');
    }
    
    return null;
  }
  
  /// Parse month name format like "April22025" or "apr22025"
  static DateTime? _parseMonthNameFormat(String dateStr) {
    try {
      // Match both full and abbreviated month names
      // Examples: April22025, april22025, Apr22025, apr22025
      final monthNameMatch = RegExp(r'^([A-Za-z]+)(\d{1,2})(\d{4})$', caseSensitive: false)
          .firstMatch(dateStr);
      
      if (monthNameMatch != null) {
        final monthStr = monthNameMatch.group(1)!;
        final day = monthNameMatch.group(2)!;
        final year = monthNameMatch.group(3)!;
        
        // Create a properly spaced string for the DateFormat parser
        final spacedDate = '$monthStr $day $year';
        
        if (kDebugMode) {
          print('Trying to parse "$spacedDate" with month name formats');
        }
        
        // Try different month name formats
        for (final format in ['MMMM d yyyy', 'MMM d yyyy']) {
          try {
            return DateFormat(format, 'en_US').parseStrict(spacedDate);
          } catch (e) {
            // Continue to next format
          }
        }
        
        // If strict parsing fails, try more flexible parsing with month mapping
        return _parseWithMonthMapping(monthStr, int.parse(day), int.parse(year));
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error in _parseMonthNameFormat: $e');
      }
      return null;
    }
  }
  
  /// Parse date with slashes like "04/02/2025"
  static DateTime? _parseSlashFormat(String dateStr) {
    try {
      // Check if the string contains slashes
      if (dateStr.contains('/')) {
        if (kDebugMode) {
          print('Trying slash format for: $dateStr');
        }
        
        // Try different date formats with slashes
        for (final format in ['MM/dd/yyyy', 'M/d/yyyy', 'dd/MM/yyyy', 'yyyy/MM/dd']) {
          try {
            return DateFormat(format).parseStrict(dateStr);
          } catch (e) {
            // Continue to next format
          }
        }
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error in _parseSlashFormat: $e');
      }
      return null;
    }
  }
  
  /// Parse numeric format like "04022025"
  static DateTime? _parseNumericFormat(String dateStr) {
    try {
      // Match numeric formats: 04022025 (MM/DD/YYYY)
      final numericMatch = RegExp(r'^(\d{2})(\d{2})(\d{4})$').firstMatch(dateStr);
      
      if (numericMatch != null) {
        final month = numericMatch.group(1)!;
        final day = numericMatch.group(2)!;
        final year = numericMatch.group(3)!;
        
        final formattedDate = '$month/$day/$year';
        
        if (kDebugMode) {
          print('Trying numeric format: $formattedDate');
        }
        
        return DateFormat('MM/dd/yyyy').parseStrict(formattedDate);
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error in _parseNumericFormat: $e');
      }
      return null;
    }
  }
  
  /// Manual month name to number mapping for flexibility
  static DateTime? _parseWithMonthMapping(String monthStr, int day, int year) {
    // Map of month names (full and abbreviated) to month numbers
    final monthMap = {
      'january': 1, 'jan': 1,
      'february': 2, 'feb': 2,
      'march': 3, 'mar': 3,
      'april': 4, 'apr': 4,
      'may': 5,
      'june': 6, 'jun': 6,
      'july': 7, 'jul': 7,
      'august': 8, 'aug': 8,
      'september': 9, 'sep': 9, 'sept': 9,
      'october': 10, 'oct': 10,
      'november': 11, 'nov': 11,
      'december': 12, 'dec': 12,
    };
    
    final monthLower = monthStr.toLowerCase();
    final monthNum = monthMap[monthLower];
    
    if (monthNum != null) {
      try {
        if (kDebugMode) {
          print('Mapped month "$monthStr" to number $monthNum');
        }
        
        // Check for valid day range (1-31)
        if (day < 1 || day > 31) {
          return null;
        }
        
        // Check for valid month (some months have fewer days)
        if ((monthNum == 4 || monthNum == 6 || monthNum == 9 || monthNum == 11) && day > 30) {
          return null;
        }
        
        // Special case for February
        if (monthNum == 2) {
          final bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
          if ((isLeapYear && day > 29) || (!isLeapYear && day > 28)) {
            return null;
          }
        }
        
        return DateTime(year, monthNum, day);
      } catch (e) {
        if (kDebugMode) {
          print('Error in month mapping: $e');
        }
      }
    }
    
    return null;
  }
}
