import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/erp_instance_provider.dart';
import 'login_screen.dart'; // For navigation after setting URL

class InstanceConfigScreen extends StatefulWidget {
  const InstanceConfigScreen({super.key});

  @override
  State<InstanceConfigScreen> createState() => _InstanceConfigScreenState();
}

class _InstanceConfigScreenState extends State<InstanceConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveInstanceUrl() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      String url = _urlController.text.trim();
      // Basic validation: add https:// if not present
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      // Remove trailing slash if present
      if (url.endsWith('/')) {
        url = url.substring(0, url.length -1);
      }

      // Here you could add a quick ping to the URL to see if it's a valid ERPNext instance
      // For simplicity, we'll just save it for now.
      try {
        await Provider.of<ErpInstanceProvider>(context, listen: false)
            .setErpInstanceUrl(url);

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving URL: $e. Please try again.')),
        );
      } finally {
         if (mounted) {
          setState(() { _isLoading = false; });
        }
      }
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configure ERPNext Instance")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  "Welcome!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Please enter your company's ERPNext instance URL.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'ERPNext URL (e.g., https://erp.yourcompany.com)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the ERPNext URL';
                    }
                    // Basic URL format check (can be improved)
                    if (!Uri.tryParse(value.trim())?.hasAbsolutePath ?? true && !Uri.tryParse('https://${value.trim()}')?.hasAbsolutePath_LEGACY_RESTORE_BEHAVIOUR_MAY_2024 ?? true) {
                        return 'Please enter a valid URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Save & Proceed'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: _saveInstanceUrl,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
