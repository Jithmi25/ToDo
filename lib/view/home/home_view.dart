import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

import '../../data/hive_data_store.dart';
import '../../main.dart';
import '../../models/task.dart';
import '../../utils/colors.dart';
import '../../utils/constanst.dart';
import '../../utils/strings.dart';
import '../tasks/task_view.dart';
import 'widgets/task_widget.dart';

enum TaskListFilter { all, completed, pending }

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<SliderDrawerState> _drawerKey =
      GlobalKey<SliderDrawerState>();
  late Future<FirebaseConnectionStatus> _firebaseConnectionFuture;
  bool _didInitConnectionCheck = false;
  String _searchQuery = '';
  TaskListFilter _taskListFilter = TaskListFilter.all;
  String _selectedCategory = 'All';

  late ScrollController _scrollController;
  bool _showScrollToTop = false;
  late VoidCallback _scrollListener;

  static const List<String> _categoryFilters = [
    'All',
    'General',
    'Work',
    'Personal',
    'Study',
    'Shopping',
    'Health',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitConnectionCheck) {
      _firebaseConnectionFuture = BaseWidget.of(
        context,
      ).dataStore.checkFirebaseConnection();
      _didInitConnectionCheck = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollListener = () {
      final shouldShow = _scrollController.offset > 240;
      if (shouldShow != _showScrollToTop) {
        setState(() {
          _showScrollToTop = shouldShow;
        });
      }
    };
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshConnectionStatus(BaseWidget base) async {
    setState(() {
      _firebaseConnectionFuture = base.dataStore.checkFirebaseConnection();
    });
    await _firebaseConnectionFuture;
  }

  int _countDoneTasks(List<Task> tasks) {
    return tasks.where((t) => t.isCompleted).length;
  }

  List<Task> _filterTasks(List<Task> tasks) {
    var filtered = tasks.where((t) {
      if (_taskListFilter == TaskListFilter.completed) return t.isCompleted;
      if (_taskListFilter == TaskListFilter.pending) return !t.isCompleted;
      return true;
    }).toList();

    if (_selectedCategory != 'All') {
      filtered = filtered
          .where(
            (t) => t.category.toLowerCase() == _selectedCategory.toLowerCase(),
          )
          .toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      filtered = filtered.where((t) {
        return t.title.toLowerCase().contains(q) ||
            t.subtitle.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q);
      }).toList();
    }

    return filtered;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    final user = base.dataStore.getCurrentUser();

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: _showScrollToTop ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: FloatingActionButton.small(
                heroTag: 'scrollTop',
                backgroundColor: Colors.white,
                foregroundColor: MyColors.primaryColor,
                elevation: 4,
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                  );
                },
                child: const Icon(Icons.arrow_upward),
              ),
            ),
          ),
          const _HomeFAB(),
        ],
      ),
      body: SliderDrawer(
        isDraggable: false,
        key: _drawerKey,
        animationDuration: 400,
        appBar: _HomeAppBar(drawerKey: _drawerKey),
        slider: _DrawerSlider(drawerKey: _drawerKey),
        child: SafeArea(
          child: StreamBuilder<List<Task>>(
            stream: base.dataStore.listenToTask(),
            builder: (context, snapshot) {
              final allTasks = snapshot.data ?? [];
              final doneCount = _countDoneTasks(allTasks);
              final visibleTasks = _filterTasks(allTasks);

              return RefreshIndicator(
                onRefresh: () => _refreshConnectionStatus(base),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // Header Card
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: MyColors.primaryGradientColor,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: MyColors.primaryColor.withValues(
                                alpha: 0.28,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Progress Circle
                            SizedBox(
                              width: 66,
                              height: 66,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: allTasks.isEmpty
                                        ? 0
                                        : doneCount / allTasks.length,
                                    strokeWidth: 5,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.3,
                                    ),
                                    valueColor: const AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                  Text(
                                    allTasks.isEmpty
                                        ? '0%'
                                        : '${((doneCount / allTasks.length) * 100).round()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Greeting & status text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_getGreeting()}, ${user?.fullName.split(' ').first ?? 'Friend'} 👋',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    allTasks.isEmpty
                                        ? 'No tasks for today. Tap + to create one!'
                                        : (doneCount == allTasks.length
                                              ? 'All tasks completed! Great job! 🎉'
                                              : '$doneCount of ${allTasks.length} tasks completed'),
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Firebase Status Banner
                    SliverToBoxAdapter(
                      child: _FirebaseStatusBanner(
                        statusFuture: _firebaseConnectionFuture,
                        onRetry: () => _refreshConnectionStatus(base),
                      ),
                    ),

                    // Search Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                        child: TextField(
                          onChanged: (val) {
                            setState(() => _searchQuery = val);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search tasks, notes, or categories...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Status Filters (All / Pending / Completed)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            _buildFilterChip('All', TaskListFilter.all),
                            const SizedBox(width: 8),
                            _buildFilterChip('Pending', TaskListFilter.pending),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Completed',
                              TaskListFilter.completed,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Category Pill Filter Bar
                    SliverToBoxAdapter(
                      child: Container(
                        height: 38,
                        margin: const EdgeInsets.only(top: 6, bottom: 8),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: _categoryFilters.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final cat = _categoryFilters[i];
                            final isSelected = _selectedCategory == cat;
                            return ChoiceChip(
                              label: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: MyColors.primaryColor,
                              backgroundColor: Colors.grey.shade100,
                              onSelected: (_) {
                                setState(() => _selectedCategory = cat);
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // Task List or Empty State
                    if (visibleTasks.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 90),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final task = visibleTasks[index];
                            return Dismissible(
                              key: Key(task.id),
                              background: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  CupertinoIcons.trash,
                                  color: Colors.red,
                                ),
                              ),
                              onDismissed: (_) {
                                base.dataStore.deleteTask(task: task);
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: const Text('Task deleted'),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        onPressed: () {
                                          base.dataStore.addTask(task: task);
                                        },
                                      ),
                                    ),
                                  );
                              },
                              child: TaskWidget(task: task),
                            );
                          }, childCount: visibleTasks.length),
                        ),
                      )
                    else
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 40,
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 170,
                                height: 170,
                                child: Lottie.asset(
                                  lottieURL,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.done_all,
                                    size: 90,
                                    color: MyColors.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                allTasks.isEmpty
                                    ? MyString.doneAllTask
                                    : 'No tasks found',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                allTasks.isEmpty
                                    ? 'Tap the button below to add your first task!'
                                    : 'Try searching with a different keyword or resetting filters.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, TaskListFilter filter) {
    final isSelected = _taskListFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: MyColors.primaryColor.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? MyColors.primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) {
        setState(() => _taskListFilter = filter);
      },
    );
  }
}

class _FirebaseStatusBanner extends StatelessWidget {
  const _FirebaseStatusBanner({
    required this.statusFuture,
    required this.onRetry,
  });

  final Future<FirebaseConnectionStatus> statusFuture;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseConnectionStatus>(
      future: statusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final status = snapshot.data;
        if (status != null && status.isConnected) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.cloud_off, color: Colors.red, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  status?.message ?? 'Connecting to Firebase server...',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18, color: Colors.red),
                onPressed: onRetry,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({required this.drawerKey});

  final GlobalKey<SliderDrawerState> drawerKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: MyColors.primaryColor,
              size: 28,
            ),
            onPressed: () {
              if (drawerKey.currentState?.isDrawerOpen ?? false) {
                drawerKey.currentState?.closeSlider();
              } else {
                drawerKey.currentState?.openSlider();
              }
            },
          ),
          const Text(
            'Task Master',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerSlider extends StatelessWidget {
  const _DrawerSlider({required this.drawerKey});

  final GlobalKey<SliderDrawerState> drawerKey;

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    final user = base.dataStore.getCurrentUser();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: MyColors.primaryGradientColor,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Icon(
                  CupertinoIcons.person_fill,
                  size: 32,
                  color: MyColors.primaryColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'User',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Menu items
          _buildDrawerItem(
            icon: CupertinoIcons.home,
            title: 'Home',
            onTap: () {
              drawerKey.currentState?.closeSlider();
            },
          ),
          _buildDrawerItem(
            icon: CupertinoIcons.person_fill,
            title: 'Profile & Stats',
            onTap: () {
              drawerKey.currentState?.closeSlider();
              Navigator.pushNamed(context, '/profile');
            },
          ),
          _buildDrawerItem(
            icon: CupertinoIcons.settings,
            title: 'Settings',
            onTap: () {
              drawerKey.currentState?.closeSlider();
              Navigator.pushNamed(context, '/settings');
            },
          ),
          _buildDrawerItem(
            icon: CupertinoIcons.info_circle_fill,
            title: 'About & Tips',
            onTap: () {
              drawerKey.currentState?.closeSlider();
              Navigator.pushNamed(context, '/about');
            },
          ),

          const Spacer(),

          // Logout button
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: Colors.red.withValues(alpha: 0.2),
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              drawerKey.currentState?.closeSlider();
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                await base.dataStore.logoutUser();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (_) => false);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: Colors.white.withValues(alpha: 0.12),
        leading: Icon(icon, color: Colors.white, size: 22),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white70,
          size: 14,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _HomeFAB extends StatelessWidget {
  const _HomeFAB();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'addTask',
      backgroundColor: MyColors.primaryColor,
      elevation: 6,
      onPressed: () {
        Navigator.of(
          context,
        ).push(CupertinoPageRoute(builder: (context) => const TaskView()));
      },
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }
}
