import 'package:flutter/material.dart';
import 'job_details.dart';
import 'models/job_model.dart';
import 'services/job_service.dart';
import 'services/saved_jobs_service.dart';
import 'services/api_config.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  late Future<List<Job>> _jobsFuture;
  List<Job> _allJobs = [];
  List<Job> _filteredJobs = [];
  String _searchQuery = '';
  String _selectedJobType = 'All';
  String _selectedLocation = '';
  double _minSalary = 0;
  double _maxSalary = 100000;
  List<String> _jobTypes = ['All', 'Full Time', 'Part Time'];
  Set<String> _savedJobIds = {};

  @override
  void initState() {
    super.initState();
    _jobsFuture = JobService.fetchAllJobs();
    _loadSavedJobs();
  }

  Future<void> _loadSavedJobs() async {
    final savedJobs = await SavedJobsService.getSavedJobs();
    if (!mounted) return;
    setState(() {
      _savedJobIds = savedJobs.map((job) => job.id).toSet();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredJobs = _allJobs;

      // Filter by job type
      if (_selectedJobType != 'All') {
        _filteredJobs = _filteredJobs
            .where((job) => job.jobType == _selectedJobType)
            .toList();
      }

      // Filter by location
      if (_selectedLocation.isNotEmpty) {
        final lowerLocation = _selectedLocation.toLowerCase();
        _filteredJobs = _filteredJobs
            .where((job) => job.location.toLowerCase().contains(lowerLocation))
            .toList();
      }

      // Filter by salary range
      _filteredJobs = _filteredJobs
          .where((job) {
            try {
              final salary = double.parse(job.salary ?? '0');
              return salary >= _minSalary && salary <= _maxSalary;
            } catch (e) {
              return true;
            }
          })
          .toList();

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final lowerQuery = _searchQuery.toLowerCase();
        _filteredJobs = _filteredJobs
            .where((job) =>
                job.title.toLowerCase().contains(lowerQuery) ||
                job.company.toLowerCase().contains(lowerQuery))
            .toList();
      }
    });
  }

  void _filterJobs(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _openFilterModal() {
    String tempSelectedJobType = _selectedJobType;
    String tempSelectedLocation = _selectedLocation;
    double tempMinSalary = _minSalary;
    double tempMaxSalary = _maxSalary;
    final locationController = TextEditingController(text: tempSelectedLocation);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Location filter
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: locationController,
                      onChanged: (value) {
                        setModalState(() {
                          tempSelectedLocation = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter location or area',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Salary range filter
                    Text(
                      'Salary Range: €${tempMinSalary.toStringAsFixed(0)} - €${tempMaxSalary.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RangeSlider(
                      values: RangeValues(tempMinSalary, tempMaxSalary),
                      min: 0,
                      max: 200000,
                      divisions: 100,
                      labels: RangeLabels(
                        '€${tempMinSalary.toStringAsFixed(0)}',
                        '€${tempMaxSalary.toStringAsFixed(0)}',
                      ),
                      activeColor: const Color(0xFF5E8E73),
                      inactiveColor: Colors.grey.shade300,
                      onChanged: (RangeValues values) {
                        setModalState(() {
                          tempMinSalary = values.start;
                          tempMaxSalary = values.end;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Job type filter
                    const Text(
                      'Job Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: _jobTypes.map((type) {
                        final isSelected = tempSelectedJobType == type;
                        return FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            setModalState(() {
                              tempSelectedJobType = selected ? type : 'All';
                            });
                          },
                          backgroundColor: Colors.grey.shade100,
                          selectedColor: const Color(0xFF5E8E73),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF5E8E73)
                                : Colors.grey.shade300,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF5E8E73),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF5E8E73),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedLocation = tempSelectedLocation;
                                _minSalary = tempMinSalary;
                                _maxSalary = tempMaxSalary;
                                _selectedJobType = tempSelectedJobType;
                              });
                              _applyFilters();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5E8E73),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Apply',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset(
            'assets/images/left-arrow.png',
            height: 22,
            width: 22,
            color: Colors.black,
          ),
        ),
        title: const Text(
          "Jobs",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔍 Search bar + filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _filterJobs,
                    decoration: InputDecoration(
                      hintText: "Search Jobs",
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/images/search.png',
                          height: 20,
                          width: 20,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Image.asset(
                      'assets/images/sort.png',
                      height: 22,
                      width: 22,
                    ),
                    onPressed: _openFilterModal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 📋 Job list with API data
            Expanded(
              child: FutureBuilder<List<Job>>(
                future: _jobsFuture,
                builder: (context, snapshot) {
                  // Loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF5E8E73),
                        ),
                      ),
                    );
                  }

                  // Error state
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _jobsFuture = JobService.fetchAllJobs();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5E8E73),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Success state
                  if (snapshot.hasData) {
                    _allJobs = snapshot.data!;
                    if (_filteredJobs.isEmpty && _searchQuery.isEmpty) {
                      _filteredJobs = _allJobs;
                    }

                    if (_filteredJobs.isEmpty) {
                      return const Center(
                        child: Text('No jobs found'),
                      );
                    }

                    return ListView.builder(
                      itemCount: _filteredJobs.length,
                      itemBuilder: (context, index) {
                        return JobCard(
                          job: _filteredJobs[index],
                          isSaved: _savedJobIds.contains(_filteredJobs[index].id),
                          onSaveToggle: (isSaved) async {
                            if (isSaved) {
                              await SavedJobsService.saveJob(_filteredJobs[index]);
                            } else {
                              await SavedJobsService.unsaveJob(_filteredJobs[index]);
                            }
                            await _loadSavedJobs();
                          },
                        );
                      },
                    );
                  }

                  return const Center(child: Text('No jobs available'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JobCard extends StatefulWidget {
  final Job job;
  final bool isSaved;
  final Function(bool) onSaveToggle;

  const JobCard({
    super.key,
    required this.job,
    required this.isSaved,
    required this.onSaveToggle,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  late bool _isSaved;

  Widget _companyLogo(Job job) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade200,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset('assets/images/google.png', fit: BoxFit.contain),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JobDetailsPage(job: widget.job),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Company Logo
            _companyLogo(widget.job),
            const SizedBox(width: 12),

            /// Job details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.job.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/location.png',
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.job.location,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF5F1),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.job.jobType,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        '€${widget.job.salary}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// Bookmark icon
            GestureDetector(
              onTap: () async {
                setState(() {
                  _isSaved = !_isSaved;
                });
                widget.onSaveToggle(_isSaved);
              },
              child: Icon(
                _isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: _isSaved ? const Color(0xFF5E8E73) : Colors.grey,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
