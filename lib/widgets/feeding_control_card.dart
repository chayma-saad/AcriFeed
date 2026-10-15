import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/feeding_schedule.dart';
import '../services/database_service.dart';

class FeedingControlCard extends StatefulWidget {
  final void Function(FeedingSchedule schedule)? onScheduleUpdated;

  const FeedingControlCard({super.key, this.onScheduleUpdated});

  @override
  State<FeedingControlCard> createState() => _FeedingControlCardState();
}

class _FeedingControlCardState extends State<FeedingControlCard> {
  late DatabaseService _databaseService;
  List<FeedingSchedule> _schedules = [];
  bool _isLoading = true;
  bool _hydrationPaused = false;
  TimeOfDay _hydrationTime = const TimeOfDay(hour: 12, minute: 0);
  double _hydrationVolume = 150;

  @override
  void initState() {
    super.initState();
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final schedules = await _databaseService.getFeedingSchedules();
    await _loadHydrationPreferences();
    if (!mounted) return;
    setState(() {
      _schedules = schedules;
      _isLoading = false;
    });
  }

  Future<void> _loadHydrationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('hydration_hour') ?? _hydrationTime.hour;
    final minute = prefs.getInt('hydration_minute') ?? _hydrationTime.minute;
    final volume = prefs.getDouble('hydration_volume') ?? _hydrationVolume;
    final paused = prefs.getBool('hydration_paused') ?? false;
    _hydrationTime = TimeOfDay(hour: hour, minute: minute);
    _hydrationVolume = volume;
    _hydrationPaused = paused;
  }

  Future<void> _saveHydrationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hydration_hour', _hydrationTime.hour);
    await prefs.setInt('hydration_minute', _hydrationTime.minute);
    await prefs.setDouble('hydration_volume', _hydrationVolume);
    await prefs.setBool('hydration_paused', _hydrationPaused);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _toggleSchedule(FeedingSchedule schedule, bool isActive) async {
    final updated = schedule.copyWith(isActive: isActive);
    await _databaseService.saveFeedingSchedule(updated);
    widget.onScheduleUpdated?.call(updated);
    await _loadData();
  }

  Future<void> _deleteSchedule(String id) async {
    await _databaseService.deleteFeedingSchedule(id);
    await _loadData();
  }

  Future<void> _showScheduleEditor({FeedingSchedule? schedule}) async {
    final nameController = TextEditingController(text: schedule?.name ?? 'Auto Feeding');
    TimeOfDay selectedTime = schedule?.time ?? TimeOfDay.now();
    double amount = schedule?.foodAmount ?? 40;
    bool isActive = schedule?.isActive ?? true;
    final days = schedule?.days.toSet() ?? {1, 2, 3, 4, 5};

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final navigator = Navigator.of(sheetContext);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 48,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Schedule name',
                      prefixIcon: Icon(Icons.restaurant),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time),
                    title: const Text('Feeding time'),
                    subtitle: Text(selectedTime.format(sheetContext)),
                    trailing: TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: sheetContext,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setModalState(() => selectedTime = picked);
                        }
                      },
                      child: const Text('Change'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Food quantity'),
                          Text('${amount.toStringAsFixed(0)} g'),
                        ],
                      ),
                      Slider(
                        min: 10,
                        max: 150,
                        divisions: 14,
                        label: '${amount.toStringAsFixed(0)} g',
                        value: amount,
                        onChanged: (value) => setModalState(() => amount = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      children: List.generate(7, (index) {
                        const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final weekDay = index + 1;
                        final isSelected = days.contains(weekDay);
                        return FilterChip(
                          selected: isSelected,
                          label: Text(dayLabels[index]),
                          onSelected: (value) {
                            setModalState(() {
                              if (value) {
                                days.add(weekDay);
                              } else {
                                days.remove(weekDay);
                              }
                            });
                          },
                        );
                      }),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(isActive ? 'Schedule active' : 'Schedule paused'),
                    value: isActive,
                    onChanged: (value) => setModalState(() => isActive = value),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final newSchedule = FeedingSchedule(
                          id: schedule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text.trim().isEmpty ? 'Auto Feeding' : nameController.text.trim(),
                          time: selectedTime,
                          foodAmount: amount,
                          isActive: isActive,
                          days: days.toList()..sort(),
                        );
                        await _databaseService.saveFeedingSchedule(newSchedule);
                        widget.onScheduleUpdated?.call(newSchedule);
                        navigator.pop();
                        await _loadData();
                      },
                      icon: const Icon(Icons.save),
                      label: Text(schedule == null ? 'Create schedule' : 'Update schedule'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _handleHydrationTime() async {
    final picked = await showTimePicker(context: context, initialTime: _hydrationTime);
    if (picked != null) {
      setState(() => _hydrationTime = picked);
      await _saveHydrationPreferences();
    }
  }

  Widget _buildScheduleTile(FeedingSchedule schedule) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: Icon(schedule.isActive ? Icons.play_arrow : Icons.pause, color: Colors.green),
        title: Text(schedule.name),
        subtitle: Text(
          '${schedule.getFormattedTime12Hour()} • ${schedule.foodAmount.toStringAsFixed(0)} g • ${schedule.getDaysString()}',
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            Switch(
              value: schedule.isActive,
              onChanged: (value) => _toggleSchedule(schedule, value),
            ),
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showScheduleEditor(schedule: schedule),
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteSchedule(schedule.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHydrationControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.lightBlue.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.lightBlue.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.opacity, color: Colors.lightBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hydration cycle',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Switch.adaptive(
                value: !_hydrationPaused,
                onChanged: (value) async {
                  setState(() => _hydrationPaused = !value);
                  await _saveHydrationPreferences();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _hydrationPaused ? 'Paused' : 'Next spray at ${_hydrationTime.format(context)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Volume: ${_hydrationVolume.toStringAsFixed(0)} ml'),
              TextButton(
                onPressed: _hydrationPaused ? null : _handleHydrationTime,
                child: const Text('Change time'),
              ),
            ],
          ),
          Slider(
            min: 50,
            max: 400,
            divisions: 14,
            label: '${_hydrationVolume.toStringAsFixed(0)} ml',
            value: _hydrationVolume,
            onChanged: _hydrationPaused
                ? null
                : (value) async {
                    setState(() => _hydrationVolume = value);
                    await _saveHydrationPreferences();
                  },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule_send, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Feeding & Hydration Control',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Add schedule',
                  onPressed: () => _showScheduleEditor(),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (_schedules.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.orange.withAlpha(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.orange),
                    const SizedBox(height: 8),
                    Text(
                      'No feeding schedule yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Tap + to create automated feeding cycles.'),
                  ],
                ),
              )
            else
              Column(
                children: _schedules.map(_buildScheduleTile).toList(),
              ),
            const SizedBox(height: 16),
            _buildHydrationControls(),
          ],
        ),
      ),
    );
  }
}

