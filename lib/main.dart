import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const SculpTApp());
}

class SculpTApp extends StatelessWidget {
  const SculpTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SculpT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF14B8A6),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

class ExerciseItem {
  final String name;
  final String targetMuscle;
  final String setsReps;
  final String purpose;
  final String category;

  const ExerciseItem({
    required this.name,
    required this.targetMuscle,
    required this.setsReps,
    required this.purpose,
    required this.category,
  });
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool highlighted;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = highlighted
        ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: isDark ? 0.52 : 0.72)
        : (isDark
            ? const Color(0xFF071012).withValues(alpha: 0.62)
            : Colors.white.withValues(alpha: 0.76));
    final borderColor = highlighted
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.55)
        : (isDark
            ? const Color(0xFF2DD4BF).withValues(alpha: 0.22)
            : const Color(0xFF0F766E).withValues(alpha: 0.22));

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  File? _selectedImage;
  double _shoulderMarker = 0.72;
  double _waistMarker = 0.52;
  double _postureSlouch = 0.40;
  double _lowerBodyBalance = 0.50;
  String _selectedOccupation = 'Desk & Computer Work';

  final Map<String, Map<String, dynamic>> _occupations = {
    'Desk & Computer Work': {
      'icon': Icons.computer,
      'summary':
          'Counters prolonged sitting, rounded shoulders ("tech neck"), tight hip flexors, and underactive glutes.',
      'focusMuscles': ['Rear Deltoids & Rhomboids', 'Thoracic Extensors', 'Glutes & Hip Flexors', 'Forearm Extensors'],
      'exercises': [
        const ExerciseItem(
          name: 'Face Pulls or Band Pull-Aparts',
          targetMuscle: 'Rear Delts & Rhomboids',
          setsReps: '3 sets × 15 reps',
          purpose: 'Pulls rolled-forward shoulders back into neutral alignment.',
          category: 'Occupational',
        ),
        const ExerciseItem(
          name: 'Glute Bridges / Hip Thrusts',
          targetMuscle: 'Glutes & Lower Back Support',
          setsReps: '3 sets × 12-15 reps',
          purpose: 'Reverses prolonged sitting inhibition and relieves lumbar strain.',
          category: 'Occupational',
        ),
        const ExerciseItem(
          name: 'Prone Cobra / Y-T-W Raises',
          targetMuscle: 'Lower Traps & Neck Stabilizers',
          setsReps: '3 sets × 10 slow reps',
          purpose: 'Strengthens postural endurance for long screen sessions.',
          category: 'Occupational',
        ),
      ],
    },
    'Standing & Walking (Teachers / Retail)': {
      'icon': Icons.directions_walk,
      'summary':
          'Builds lower-leg circulatory endurance, arch/ankle resilience, and hip stability to prevent fatigue.',
      'focusMuscles': ['Calves & Tibialis Anterior', 'Glute Medius (Hip Stability)', 'Core Bracing', 'Hamstrings'],
      'exercises': [
        const ExerciseItem(
          name: 'Standing & Seated Calf Raises',
          targetMuscle: 'Gastrocnemius & Soleus',
          setsReps: '4 sets × 15-20 reps',
          purpose: 'Builds all-day standing endurance and venous blood return.',
          category: 'Occupational',
        ),
        const ExerciseItem(
          name: 'Tibialis Wall Raises',
          targetMuscle: 'Shin / Front Lower Leg',
          setsReps: '3 sets × 15 reps',
          purpose: 'Protects knees and ankles during hours on hard floors.',
          category: 'Occupational',
        ),
        const ExerciseItem(
          name: 'Single-Leg Glute Bridge / Step-Ups',
          targetMuscle: 'Glute Medius & Quads',
          setsReps: '3 sets × 10 each leg',
          purpose: 'Prevents hip drop and lower-back ache from prolonged standing.',
          category: 'Occupational',
        ),
      ],
    },
    'Driving & Field Commuting': {
      'icon': Icons.directions_car,
      'summary':
          'Relieves spinal compression, unlocks stiff thoracic rotation, and activates dormant hamstrings.',
      'focusMuscles': ['Thoracic Spine Mobility', 'Hamstrings & Glutes', 'Deep Core', 'Upper Back'],
      'exercises': [
        const ExerciseItem(
          name: 'Romanian Deadlifts (Dumbbell/Bodyweight)',
          targetMuscle: 'Hamstrings & Posterior Chain',
          setsReps: '3 sets × 12 reps',
          purpose: 'Strengthens the back of the legs cramped during driving.',
          category: 'Occupational',
        ),
        const ExerciseItem(
          name: 'Dead Bugs / Bird-Dogs',
          targetMuscle: 'Deep Core & Spinal Stabilizers',
          setsReps: '3 sets × 10 per side',
          purpose: 'Decompresses and stabilizes the lumbar spine.',
          category: 'Occupational',
        ),
      ],
    },
    'Heavy Lifting & Physical Labor': {
      'icon': Icons.fitness_center,
      'summary':
          'Protects joints under load through rotator cuff stability, anti-rotation core, and grip endurance.',
      'focusMuscles': ['Rotator Cuff', 'Obliques (Anti-Rotation)', 'Forearms & Grip', 'Quads & Traps'],
      'exercises': [
        const ExerciseItem(
          name: 'Farmer Carries',
          targetMuscle: 'Grip, Traps & Core Bracing',
          setsReps: '4 walks × 30-40 meters',
          purpose: 'Builds real-world carrying stability and shoulder packing.',
          category: 'Occupational',
        ),
        const ExerciseItem(
          name: 'Pallof Press (Anti-Rotation)',
          targetMuscle: 'Obliques & Transverse Abdominis',
          setsReps: '3 sets × 12 per side',
          purpose: 'Protects the spine during uneven lifting and twisting.',
          category: 'Occupational',
        ),
      ],
    },
  };
  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1080);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  List<ExerciseItem> _computeAestheticExercises() {
    final List<ExerciseItem> list = [];
    final double vTaperRatio = _shoulderMarker / (_waistMarker < 0.2 ? 0.2 : _waistMarker);

    if (vTaperRatio < 1.45) {
      list.add(const ExerciseItem(
        name: 'Lateral Raises (Dumbbell or Cable)',
        targetMuscle: 'Side Deltoids',
        setsReps: '4 sets × 12-15 reps',
        purpose: 'Broadens shoulder width to enhance the V-taper silhouette.',
        category: 'Aesthetic',
      ));
      list.add(const ExerciseItem(
        name: 'Lat Pulldowns or Pull-Ups',
        targetMuscle: 'Latissimus Dorsi (Upper Back Width)',
        setsReps: '3 sets × 8-12 reps',
        purpose: 'Creates upper-back taper relative to the waist.',
        category: 'Aesthetic',
      ));
    } else {
      list.add(const ExerciseItem(
        name: 'Incline Dumbbell Press',
        targetMuscle: 'Upper Chest & Front Delts',
        setsReps: '3 sets × 10-12 reps',
        purpose: 'Adds balanced upper-torso fullness to match wide shoulders.',
        category: 'Aesthetic',
      ));
    }

    if (_postureSlouch > 0.45) {
      list.add(const ExerciseItem(
        name: 'Chest-Supported Rows',
        targetMuscle: 'Mid-Back & Traps',
        setsReps: '3 sets × 12 reps',
        purpose: 'Corrects forward shoulder rounding for a taller, open stance.',
        category: 'Aesthetic',
      ));
    }

    if (_lowerBodyBalance < 0.55) {
      list.add(const ExerciseItem(
        name: 'Bulgarian Split Squats or Goblet Squats',
        targetMuscle: 'Quads & Glutes',
        setsReps: '3 sets × 10-12 reps',
        purpose: 'Builds lower-body symmetry to match upper-body proportions.',
        category: 'Aesthetic',
      ));
    }

    if (_waistMarker > 0.60) {
      list.add(const ExerciseItem(
        name: 'Stomach Vacuums & Hanging Knee Raises',
        targetMuscle: 'Transverse Abdominis (Waist Tightness)',
        setsReps: '3 sets × 20 sec / 12 reps',
        purpose: 'Tightens the deep abdominal wall to trim waist profile.',
        category: 'Aesthetic',
      ));
    }

    return list;
  }

  String _getPhysiqueInsight() {
    final double ratio = _shoulderMarker / (_waistMarker < 0.2 ? 0.2 : _waistMarker);
    final List<String> notes = [];

    if (ratio < 1.35) {
      notes.add('• Upper Frame: Prioritizing side delts and lats will create stronger shoulder-to-waist contrast.');
    } else if (ratio < 1.55) {
      notes.add('• Upper Frame: Balanced shoulder-to-waist ratio; focus on upper-chest and rear-delt detail.');
    } else {
      notes.add('• Upper Frame: Strong natural V-taper; maintain symmetry with lower body.');
    }

    if (_postureSlouch > 0.45) {
      notes.add('• Posture Alignment: Slight forward shoulder/head tendency detected—upper-back pulling will visibly improve stance.');
    }

    if (_lowerBodyBalance < 0.50) {
      notes.add('• Lower-to-Upper Symmetry: Adding targeted quad/glute volume will balance overall physique proportions.');
    }

    return notes.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pages = [
      _buildPhysiqueTab(),
      _buildOccupationTab(),
      _buildCombinedPlanTab(),
    ];

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: isDark ? Colors.black : const Color(0xFFF0FDFA),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: isDark
                  ? Image.asset(
                      'assets/sculpt_icon.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    )
                  : ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        -0.85, 0,     0,     0, 240,
                        0,     -0.45, 0,     0, 253,
                        0,     0,     -0.48, 0, 250,
                        0,     0,     0,     0.35, 0,
                      ]),
                      child: Image.asset(
                        'assets/sculpt_icon.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    ),
            ),
          ),
        ),
        if (isDark)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.25),
            ),
          ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: isDark
                ? Colors.black.withValues(alpha: 0.65)
                : Colors.white.withValues(alpha: 0.75),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Row(
              children: [
                Text('SculpT', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Text('• Sculpt to the T', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400)),
              ],
            ),
            centerTitle: false,
          ),
          body: pages[_currentIndex],
          bottomNavigationBar: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: NavigationBar(
                backgroundColor: isDark
                    ? Colors.black.withValues(alpha: 0.72)
                    : Colors.white.withValues(alpha: 0.80),
                selectedIndex: _currentIndex,
                onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.accessibility_new_outlined),
                    selectedIcon: Icon(Icons.accessibility_new),
                    label: 'Physique',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.work_outline),
                    selectedIcon: Icon(Icons.work),
                    label: 'Work Role',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.checklist_outlined),
                    selectedIcon: Icon(Icons.checklist),
                    label: 'My Routine',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildPhysiqueTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '1. Visual Physique Check (On-Device)',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Load a front-facing photo (stays 100% private on your phone) or adjust the proportion sliders below.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              if (_selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.file(_selectedImage!, height: 260, width: double.infinity, fit: BoxFit.cover),
                      Positioned(
                        top: 65,
                        left: 30,
                        right: 30,
                        child: Container(height: 2, color: Colors.tealAccent.withValues(alpha: 0.85)),
                      ),
                      Positioned(
                        top: 145,
                        left: 60,
                        right: 60,
                        child: Container(height: 2, color: Colors.amberAccent.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search, size: 34),
                      SizedBox(height: 6),
                      Text('No photo loaded — using proportion sliders below', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickPhoto(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickPhoto(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '2. Fine-Tune Proportion & Posture Markers',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildSlider('Shoulder Width', _shoulderMarker, (v) => setState(() => _shoulderMarker = v)),
              _buildSlider('Waist Width', _waistMarker, (v) => setState(() => _waistMarker = v)),
              _buildSlider('Forward Slouch / Tech Neck', _postureSlouch, (v) => setState(() => _postureSlouch = v)),
              _buildSlider('Lower-Body Development', _lowerBodyBalance, (v) => setState(() => _lowerBodyBalance = v)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          highlighted: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Physique Assessment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_getPhysiqueInsight()),
            ],
          ),
        ),
        const SizedBox(height: 160),
      ],
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text('${(value * 100).round()}%', style: const TextStyle(fontSize: 12)),
          ],
        ),
        Slider(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildOccupationTab() {
    final currentData = _occupations[_selectedOccupation]!;
    final List<String> muscles = List<String>.from(currentData['focusMuscles']);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Your Primary Daily Work', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                'We target muscles that either carry heavy daily fatigue or become weak from your work posture.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._occupations.entries.map((entry) {
          final isSelected = entry.key == _selectedOccupation;
          return GlassCard(
            highlighted: isSelected,
            padding: EdgeInsets.zero,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Icon(entry.value['icon'] as IconData),
              title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(entry.value['summary'] as String, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: isSelected ? const Icon(Icons.check_circle) : null,
              onTap: () => setState(() => _selectedOccupation = entry.key),
            ),
          );
        }),
        const SizedBox(height: 4),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Priority Functional Muscles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: muscles.map((m) => Chip(label: Text(m))).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 160),
      ],
    );
  }

  Widget _buildCombinedPlanTab() {
    final aestheticExercises = _computeAestheticExercises();
    final occupationalExercises = List<ExerciseItem>.from(_occupations[_selectedOccupation]!['exercises']);
    final allExercises = [...aestheticExercises, ...occupationalExercises];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Tailored Plan (${allExercises.length} Exercises)',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Combines physique symmetry + $_selectedOccupation endurance.',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...allExercises.map((ex) {
          final isAesthetic = ex.category == 'Aesthetic';
          return GlassCard(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isAesthetic
                            ? Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.85)
                            : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isAesthetic ? 'Physique & Aesthetics' : 'Work Endurance',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    Text(ex.setsReps, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(ex.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Target: ${ex.targetMuscle}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text(ex.purpose, style: const TextStyle(fontSize: 13)),
              ],
            ),
          );
        }),
        const SizedBox(height: 160),
      ],
    );
  }
}
