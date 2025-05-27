import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/erp_instance_provider.dart'; // To get the base URL

class ErpNextApiService {
  final ErpInstanceProvider _erpInstanceProvider;

  ErpNextApiService(this._erpInstanceProvider);

  String get _baseUrl {
    final url = _erpInstanceProvider.erpInstanceUrl;
    if (url == null || url.isEmpty) {
      throw Exception("ERPNext instance URL is not configured.");
    }
    return url;
  }

  // --- LOGIN ---
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/api/method/login"),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'usr': username, 'pwd': password},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['message'] == 'Logged In' || (responseData['message'] != null && responseData['message']['message'] == 'Logged In')) { // ERPNext response can vary slightly
        String? sid = _extractSidFromCookie(response.headers['set-cookie']);
        if (sid == null) {
          throw Exception('Failed to extract session ID (sid) from cookie.');
        }
        return {
          'sid': sid,
          'full_name': responseData['full_name'],
          'user_id': username, // Login endpoint itself doesn't return user_id, it's the input `usr`
        };
      } else if (responseData['message'] == 'Invalid login credentials' || responseData['exc_type'] == 'AuthenticationError') {
         throw Exception('Invalid login credentials.');
      }
      else {
        throw Exception('Login failed: ${responseData['message'] ?? 'Unknown error'}');
      }
    } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Invalid login credentials.');
    }
    else {
      throw Exception('Login request failed: ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  String? _extractSidFromCookie(String? cookieHeader) {
    if (cookieHeader == null) return null;
    // Example cookieHeader: "sid=your_sid_value; Path=/; HttpOnly; SameSite=Lax, system_user=yes; Path=/; HttpOnly; SameSite=Lax"
    // We need to extract the 'sid' value.
    final cookies = cookieHeader.split(',');
    for (String cookieString in cookies) {
        final parts = cookieString.split(';');
        final cookiePair = parts[0].trim(); // e.g., "sid=your_sid_value"
        if (cookiePair.startsWith('sid=')) {
            return cookiePair.substring(4); // Remove "sid="
        }
    }
    return null;
  }

  // --- FETCH EMPLOYEE DETAILS for User ---
  Future<Map<String, dynamic>?> fetchEmployeeForUser(String userIdEmail, String sid) async {
    // Note: The filter might need adjustment based on your ERPNext setup.
    // Common link field from User to Employee is 'user_id' on Employee doctype.
    final filters = jsonEncode([["user_id", "=", userIdEmail]]);
    final fields = jsonEncode(["name", "employee_name", "company", "department", "designation", "image"]); // 'name' is the internal ID

    final response = await http.get(
      Uri.parse("$_baseUrl/api/resource/Employee?filters=$filters&fields=$fields"),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid', // Send SID as a cookie
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['data'] != null && (responseData['data'] as List).isNotEmpty) {
        final employeeData = (responseData['data'] as List)[0];
        // We want 'name' which is the Employee ID (e.g., EMP/0001), not 'employee_name' which is the person's name.
        // Let's ensure we map correctly based on typical ERPNext behavior
        return {
          'employee_id_internal': employeeData['name'], // This is the actual ID like EMP/0001
          'employee_name': employeeData['employee_name'], // This is the person's name field
          'company': employeeData['company'],
          // ... other fields you fetched
        };
      } else {
        return null; // No employee found for this user
      }
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception("Session expired or unauthorized to fetch employee details.");
    }
    else {
      throw Exception('Failed to fetch employee details: ${response.statusCode} - ${response.body}');
    }
  }


  // --- Placeholder for other API methods ---
  // Future<void> applyForLeave(Map<String, dynamic> leaveData, String sid) async { ... }
  // Future<List<dynamic>> getLeaveApplications(String employeeId, String sid) async { ... }
}
