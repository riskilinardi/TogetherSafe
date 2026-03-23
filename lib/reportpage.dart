// =============================================================================
// reportpage.dart - Community Flood Reporting Page
// This page allows users to report flood sightings in their area.
//
// Features:
// - Take photo of flood using device camera
// - Add description of the situation
// - Capture location
// - View recent reports from the community
//
// =============================================================================

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'db.dart';

// ReportPage Widget
class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool _isLoading = true;

  // List of flood reports from database
  List<FloodReport> _reports = [];

 @override
  void initState() {
    super.initState();
    _loadReports();
  }

  // Load Reports from Database
  Future<void> _loadReports() async {
    try {
      List<FloodReport> reports = await DatabaseHelper.instance.getAllFloodReports();
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading reports: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B263B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        title: const Text(
          'Flood Reports',
          style: TextStyle(
            color: Color(0xFFE0E0E0),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Info button
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFF778DA9)),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
        onRefresh: _loadReports,
        color: const Color(0xFF4FC3F7),
        backgroundColor: const Color(0xFF0D1B2A),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header card explaining the feature
            _buildHeaderCard(),

            const SizedBox(height: 20),

            // Report button
            _buildReportButton(),

            const SizedBox(height: 24),

            // Recent reports section
            _buildSectionTitle('Recent Reports', '${_reports.length} reports'),

            const SizedBox(height: 12),

            // Reports list or empty state
            if (_reports.isEmpty)
              _buildEmptyState()
            else
              ...List.generate(_reports.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildReportCard(_reports[index]),
                );
              }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading reports...',
            style: TextStyle(
              color: Color(0xFF778DA9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Header Card
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1976D2).withOpacity(0.3),
            const Color(0xFF1976D2).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.5)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('📸', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Help Your Community',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE0E0E0),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Spotted a flood in your area? Report it to help others stay '
                'safe. Your reports contribute to real-time community awareness.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF778DA9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Report Button
  Widget _buildReportButton() {
    return GestureDetector(
      onTap: () => _openCreateReport(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF4FC3F7),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4FC3F7).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: Colors.black, size: 24),
            SizedBox(width: 12),
            Text(
              'Report a Flood',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE0E0E0),
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF778DA9),
          ),
        ),
      ],
    );
  }

  // Empty State
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF415A77)),
      ),
      child: const Column(
        children: [
          Text('🌤️', style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          Text(
            'No Reports Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE0E0E0),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Good news! There are no flood reports in your area. '
                'Be the first to report if you see flooding.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF778DA9),
            ),
          ),
        ],
      ),
    );
  }

  // Report Card
  Widget _buildReportCard(FloodReport report) {
    return GestureDetector(
      onTap: () => _viewReportDetail(report),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF415A77)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo (if available)
            if (report.photo != null && report.photo!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                child: Image.memory(
                  base64Decode(report.photo!),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      color: const Color(0xFF415A77),
                      child: const Center(
                        child: Icon(Icons.image_not_supported, color: Color(0xFF778DA9)),
                      ),
                    );
                  },
                ),
              ),

            // Report details
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location and time row
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF4FC3F7), size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          report.location,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(report.reportedAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF778DA9),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    report.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF778DA9),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Format Time
  String _formatTime(DateTime dateTime) {
    Duration diff = DateTime.now().difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  // Info Dialog
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Text('ℹ️', style: TextStyle(fontSize: 24)),
            SizedBox(width: 12),
            Text(
              'About Reports',
              style: TextStyle(
                color: Color(0xFFE0E0E0),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Community flood reports help everyone stay informed about '
              'real-time conditions in different areas.\n\n'
              '• Reports are stored locally on your device\n'
              '• Take clear photos showing flood levels\n'
              '• Include specific location details\n'
              '• Report responsibly and accurately\n\n'
              'In emergencies, always call 995 for SCDF assistance.',
          style: TextStyle(
            color: Color(0xFF778DA9),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(color: Color(0xFF4FC3F7)),
            ),
          ),
        ],
      ),
    );
  }

  // Open Create Report
  void _openCreateReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateReportPage()),
    ).then((_) {
      // Refresh reports when returning
      _loadReports();
    });
  }

  // View Report Detail
  void _viewReportDetail(FloodReport report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildReportDetailSheet(report),
    );
  }

  Widget _buildReportDetailSheet(FloodReport report) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1B263B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF415A77),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Photo
          if (report.photo != null && report.photo!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(report.photo!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Details
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF4FC3F7), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        report.location,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Time
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Color(0xFF778DA9), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Reported ${_formatTime(report.reportedAt)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF778DA9),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE0E0E0),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  report.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF778DA9),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                // Delete button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => _confirmDeleteReport(report),
                    child: const Text(
                      'Delete Report',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Confirm Delete Report
  void _confirmDeleteReport(FloodReport report) {
    Navigator.pop(context); // Close bottom sheet first

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Report?',
          style: TextStyle(
            color: Color(0xFFE0E0E0),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this flood report? '
              'This action cannot be undone.',
          style: TextStyle(
            color: Color(0xFF778DA9),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF778DA9)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseHelper.instance.deleteFloodReport(report.id!);
              _loadReports();
              _showSnackBar('Report deleted');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF415A77),
      ),
    );
  }
}


// CreateReportPage - Create New Flood Report
class CreateReportPage extends StatefulWidget {
  const CreateReportPage({Key? key}) : super(key: key);

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  // ===========================================================================
  // STATE VARIABLES
  // ===========================================================================

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _photoBase64;
  File? _photoFile;
  bool _isSubmitting = false;

  // Predefined locations in Singapore (common flood areas)
  final List<String> _suggestedLocations = [
    'Bukit Timah',
    'Bedok',
    'Queenstown',
    'Tampines',
    'Woodlands',
    'Jurong West',
    'Ang Mo Kio',
    'Bishan',
    'Clementi',
    'Yishun',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // PHOTO METHODS
  // Pick Photo
  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (image != null) {
        // Read file and convert to base64
        File file = File(image.path);
        List<int> bytes = await file.readAsBytes();
        String base64Image = base64Encode(bytes);

        setState(() {
          _photoFile = file;
          _photoBase64 = base64Image;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      _showSnackBar('Error selecting image. Please try again.');
    }
  }

  // Show Photo Source Dialog
  void _showPhotoSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B263B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE0E0E0),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Camera option
                _buildPhotoOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickPhoto(ImageSource.camera);
                  },
                ),
                // Gallery option
                _buildPhotoOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickPhoto(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF415A77),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF4FC3F7), size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFE0E0E0),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // SUBMIT REPORT

  Future<void> _submitReport() async {
    // Validate inputs
    if (_locationController.text.trim().isEmpty) {
      _showSnackBar('Please enter a location');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showSnackBar('Please enter a description');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create flood report
      FloodReport report = FloodReport(
        photo: _photoBase64,
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
      );

      // Save to database
      await DatabaseHelper.instance.insertFloodReport(report);

      // Show success and go back
      _showSnackBar('🎉 Report submitted! Thank you for helping!');
      Navigator.pop(context);

    } catch (e) {
      debugPrint('Error submitting report: $e');
      _showSnackBar('Error submitting report. Please try again.');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF415A77),
      ),
    );
  }

  // BUILD METHOD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B263B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        title: const Text(
          'Report Flood',
          style: TextStyle(
            color: Color(0xFFE0E0E0),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF778DA9)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo section
            _buildPhotoSection(),

            const SizedBox(height: 24),

            // Location section
            _buildLocationSection(),

            const SizedBox(height: 24),

            // Description section
            _buildDescriptionSection(),

            const SizedBox(height: 32),

            // Submit button
            _buildSubmitButton(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Photo Section
  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE0E0E0),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Add a photo of the flood (optional but helpful)',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF778DA9),
          ),
        ),
        const SizedBox(height: 12),

        // Photo display or add button
        GestureDetector(
          onTap: _showPhotoSourceDialog,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF415A77),
                style: BorderStyle.solid,
              ),
            ),
            child: _photoFile != null
                ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.file(
                    _photoFile!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Remove photo button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _photoFile = null;
                        _photoBase64 = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            )
                : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo,
                  color: Color(0xFF778DA9),
                  size: 40,
                ),
                SizedBox(height: 8),
                Text(
                  'Tap to add photo',
                  style: TextStyle(
                    color: Color(0xFF778DA9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Location Section
  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Location',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE0E0E0),
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Where did you see the flood?',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF778DA9),
          ),
        ),
        const SizedBox(height: 12),

        // Location text field
        TextField(
          controller: _locationController,
          style: const TextStyle(color: Color(0xFFE0E0E0)),
          decoration: InputDecoration(
            hintText: 'Enter location (e.g., Bukit Timah Road)',
            hintStyle: const TextStyle(color: Color(0xFF415A77)),
            filled: true,
            fillColor: const Color(0xFF0D1B2A),
            prefixIcon: const Icon(Icons.location_on, color: Color(0xFF778DA9)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF415A77)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF415A77)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Suggested locations
        const Text(
          'Quick select:',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF778DA9),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestedLocations.map((location) {
            bool isSelected = _locationController.text == location;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _locationController.text = location;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4FC3F7).withOpacity(0.2)
                      : const Color(0xFF0D1B2A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4FC3F7)
                        : const Color(0xFF415A77),
                  ),
                ),
                child: Text(
                  location,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? const Color(0xFF4FC3F7)
                        : const Color(0xFF778DA9),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Description Section
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Description',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE0E0E0),
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Describe the flood situation',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF778DA9),
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _descriptionController,
          style: const TextStyle(color: Color(0xFFE0E0E0)),
          maxLines: 4,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'e.g., Water level reaching knee height, roads impassable...',
            hintStyle: const TextStyle(color: Color(0xFF415A77)),
            filled: true,
            fillColor: const Color(0xFF0D1B2A),
            counterStyle: const TextStyle(color: Color(0xFF778DA9)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF415A77)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF415A77)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // Submit Button
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4FC3F7),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: const Color(0xFF4FC3F7).withOpacity(0.5),
        ),
        child: _isSubmitting
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        )
            : const Text(
          'Submit Report',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}