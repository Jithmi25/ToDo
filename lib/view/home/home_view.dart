// ignore_for_file: must_be_immutable

import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

///
import '../../data/hive_data_store.dart';
import '../../main.dart';
import '../../models/task.dart';
import '../../utils/colors.dart';
import '../../utils/constanst.dart';
import '../../view/home/widgets/task_widget.dart';
import '../../view/tasks/task_view.dart';
import '../../utils/strings.dart';

enum TaskListFilter { all, completed, pending }

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  GlobalKey<SliderDrawerState> dKey = GlobalKey<SliderDrawerState>();
  late Future<FirebaseConnectionStatus> _firebaseConnectionFuture;
  bool _didInitConnectionCheck = false;
  String _searchQuery = '';
  TaskListFilter _taskListFilter = TaskListFilter.all;
  late ScrollController _scrollController;
  bool _showScrollToTop = false;

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
    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 300;
      if (shouldShow != _showScrollToTop) {
        setState(() {
          _showScrollToTop = shouldShow;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(() {});
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshConnectionStatus(BaseWidget base) async {
    setState(() {
      _firebaseConnectionFuture = base.dataStore.checkFirebaseConnection();
    });
    await _firebaseConnectionFuture;
  }

  Future<void> _handleRefresh(BaseWidget base) async {
    await _refreshConnectionStatus(base);
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  /// Checking Done Tasks
  int checkDoneTask(List<Task> task) {
                          child: TaskWidget(task: task),
    for (Task doneTasks in task) {
      if (doneTasks.isCompleted) {
        i++;
      }
    }
    return i;
  }

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.45,
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  /// Lottie animation
                                  FadeIn(
                                    child: SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: Lottie.asset(
                                        lottieURL,
                                        animate: tasks.isNotEmpty
                                            ? false
                                            : true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  /// Empty state copy
                                  FadeInUp(
                                    from: 30,
                                    child: Column(
                                      children: [
                                        Text(
                                          tasks.isEmpty
                                              ? MyString.doneAllTask
                                              : 'No tasks match your search or filter.',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          tasks.isEmpty
                                              ? 'Time to add new tasks or take a break! ☕'
                                              : 'Try a different keyword or clear the filter chips.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
        var tasks = snapshot.data ?? <Task>[];

        /// Sort Task List
        tasks.sort(((a, b) => a.createdAtDate.compareTo(b.createdAtDate)));
        final visibleTasks = _filterTasks(tasks);

        return Scaffold(
          backgroundColor: Colors.white,

          /// Floating Action Button
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: _showScrollToTop ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 180),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: FloatingActionButton(
                    heroTag: 'scrollTop',
                    mini: true,
                    onPressed: () {
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Icon(Icons.arrow_upward),
                  ),
                ),
              ),
              const FAB(),
            ],
          ),

          /// Body
          body: SliderDrawer(
            isDraggable: false,
            key: dKey,
            animationDuration: 1000,

            /// My AppBar
            appBar: MyAppBar(drawerKey: dKey),

            /// My Drawer Slider
            slider: MySlider(),

            /// Main Body
            child: _buildBody(tasks, visibleTasks, base, textTheme),
          ),
        );
      },
    );
  }

  /// Main Body
  Widget _buildBody(
    List<Task> tasks,
    List<Task> visibleTasks,
    BaseWidget base,
    TextTheme textTheme,
  ) {
    return SafeArea(
      child: Column(
        children: [
          /// Top Section Of Home page : Text, Progress Indicator
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: MyColors.primaryGradientColor,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: MyColors.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                /// Larger CircularProgressIndicator
                SizedBox(
                  width: 70,
                  height: 70,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        strokeWidth: 5,
                        value:
                            checkDoneTask(tasks) / valueOfTheIndicator(tasks),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${checkDoneTask(tasks)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "of ${tasks.length}",

                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                        child: TextField(
                          onChanged: _updateSearchQuery,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Search tasks, notes, or category',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchQuery.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    onPressed: () => _updateSearchQuery(''),
                                    icon: const Icon(Icons.clear),
                                  ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.black.withValues(alpha: 0.06),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: MyColors.primaryColor,
                                width: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilterChip(
                              label: const Text('All'),
                              selected: _taskListFilter == TaskListFilter.all,
                              onSelected: (_) => _updateFilter(TaskListFilter.all),
                            ),
                            FilterChip(
                              label: const Text('Completed'),
                              selected: _taskListFilter == TaskListFilter.completed,
                              onSelected: (_) => _updateFilter(TaskListFilter.completed),
                            ),
                            FilterChip(
                              label: const Text('Pending'),
                              selected: _taskListFilter == TaskListFilter.pending,
                              onSelected: (_) => _updateFilter(TaskListFilter.pending),
                            ),
                          ],
                        ),
                      ),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                /// Texts with better visual hierarchy
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MyString.mainTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tasks.isEmpty
                            ? "All tasks completed! 🎉"
                            : checkDoneTask(tasks) == tasks.length
                            ? "Great job! Keep it up! 🚀"
                            : "${tasks.length - checkDoneTask(tasks)} task${tasks.length - checkDoneTask(tasks) == 1 ? '' : 's'} remaining",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/img/logo.jpeg',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 52,
                        height: 52,
                        color: Colors.white.withValues(alpha: 0.2),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          _ProgressAnalysisCard(
            totalCount: tasks.length,
            completedCount: checkDoneTask(tasks),
          ),

          _FirebaseStatusCard(
            statusFuture: _firebaseConnectionFuture,
            onRetry: () => _refreshConnectionStatus(base),
          ),

          /// Tasks List or Empty State
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _handleRefresh(base),
              child: visibleTasks.isNotEmpty
                    ? ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 16, bottom: 80),
                      itemCount: visibleTasks.length,
                      itemBuilder: (BuildContext context, int index) {
                        final task = visibleTasks[index];

                        return Dismissible(
                          key: Key(task.id),
                          background: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.4),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  MyString.deletedTask,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onDismissed: (direction) {
                            base.dataStore.dalateTask(task: task);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: const Text('Task deleted'),
                                  duration: const Duration(seconds: 3),
                                  backgroundColor: Colors.red.withValues(
                                    alpha: 0.7,
                                  ),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      base.dataStore.addTask(task: task);
                                    },
                                  ),
                                ),
                              );
                          },
                          child: TaskWidget(task: task),
                        );
                      },
                    )
                  : tasks.isNotEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      controller: _scrollController,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.45,
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.search_off,
                                    size: 76,
                                    color: MyColors.primaryColor,
                                  ),
                                  const SizedBox(height: 18),
                                  const Text(
                                    'No tasks match your search or filter.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try a different keyword or clear the filter chips.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      controller: _scrollController,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.45,
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  /// Lottie animation
                                  FadeIn(
                                    child: SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: Lottie.asset(
                                        lottieURL,
                                        animate: tasks.isNotEmpty
                                            ? false
                                            : true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  /// Celebration text
                                  FadeInUp(
                                    from: 30,
                                    child: Column(
                                      children: [
                                        const Text(
                                          MyString.doneAllTask,
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Time to add new tasks or take a break! ☕',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FirebaseStatusCard extends StatelessWidget {
  const _FirebaseStatusCard({
    required this.statusFuture,
    required this.onRetry,
  });

  final Future<FirebaseConnectionStatus> statusFuture;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseConnectionStatus>(
      future: statusFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final status = snapshot.data;
        final hasError = snapshot.hasError || (status?.isConnected == false);

        final Color iconColor;
        final IconData iconData;
        final String title;
        final String subtitle;

        if (isLoading) {
          iconColor = Colors.orange;
          iconData = Icons.sync;
          title = 'Checking Firebase connection...';
          subtitle = 'Please wait a moment';
        } else if (hasError) {
          iconColor = Colors.red;
          iconData = Icons.cloud_off;
          title = 'Firebase not reachable';
          subtitle = status?.message ?? 'Check internet and Firebase setup';
        } else {
          iconColor = Colors.green;
          iconData = Icons.cloud_done;
          title = 'Firebase connected';
          subtitle = status?.message ?? 'Server connection is healthy';
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: iconColor.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(iconData, color: iconColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Recheck connection',
                onPressed: isLoading ? null : () => onRetry(),
                icon: const Icon(Icons.refresh, size: 20),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressAnalysisCard extends StatelessWidget {
  const _ProgressAnalysisCard({
    required this.totalCount,
    required this.completedCount,
  });

  final int totalCount;
  final int completedCount;

  int get pendingCount => totalCount - completedCount;

  double get completionRate {
    if (totalCount == 0) return 0;
    return completedCount / totalCount;
  }

  @override
  Widget build(BuildContext context) {
    final int maxCount = totalCount == 0 ? 1 : totalCount;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Analysis',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${(completionRate * 100).round()}% completion rate',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.6),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          _AnalysisBar(
            label: 'Completed',
            value: completedCount,
            maxValue: maxCount,
            barColor: MyColors.primaryColor,
          ),
          const SizedBox(height: 10),
          _AnalysisBar(
            label: 'Pending',
            value: pendingCount,
            maxValue: maxCount,
            barColor: MyColors.primaryColor.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}

class _AnalysisBar extends StatelessWidget {
  const _AnalysisBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.barColor,
  });

  final String label;
  final int value;
  final int maxValue;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    final double ratio = maxValue == 0 ? 0 : value / maxValue;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.75),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$value',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.65),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio.clamp(0, 1),
            minHeight: 10,
            backgroundColor: Colors.black.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}

/// My Drawer Slider
class MySlider extends StatelessWidget {
  const MySlider({super.key});

  /// Icons
  static const List<IconData> icons = [
    CupertinoIcons.home,
    CupertinoIcons.person_fill,
    CupertinoIcons.settings,
    CupertinoIcons.info_circle_fill,
  ];

  /// Texts
  static const List<String> texts = ["Home", "Profile", "Settings", "Details"];

  @override
  Widget build(BuildContext context) {
    final currentUser = BaseWidget.of(context).dataStore.getCurrentUser();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: MyColors.primaryGradientColor,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          /// Profile Avatar with shadow
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(
                CupertinoIcons.person_fill,
                size: 48,
                color: MyColors.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),

          /// User info with better styling
          Text(
            currentUser?.fullName ?? "User",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentUser?.email ?? "user@example.com",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),

          /// Menu items
          Container(
            margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
            width: double.infinity,
            child: ListView.builder(
              itemCount: icons.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, i) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => print("$i Selected"),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              icons[i],
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            texts[i],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// Logout Button
          Container(
            margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            child: const Text('Logout'),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldLogout == true) {
                    if (context.mounted) {
                      await BaseWidget.of(context).dataStore.logoutUser();
                      if (context.mounted) {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/login', (_) => false);
                      }
                    }
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          CupertinoIcons.arrow_right_arrow_left,
                          color: Colors.red,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// My App Bar
class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  MyAppBar({super.key, required this.drawerKey});
  GlobalKey<SliderDrawerState> drawerKey;

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _MyAppBarState extends State<MyAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  bool isDrawerOpen = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// toggle for drawer and icon aniamtion
  void toggle() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
      if (isDrawerOpen) {
        controller.forward();
        widget.drawerKey.currentState!.openSlider();
      } else {
        controller.reverse();
        widget.drawerKey.currentState!.closeSlider();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Animated Icon - Menu & Close
              Material(
                color: Colors.transparent,
                child: Tooltip(
                  message: 'Menu',
                  child: IconButton(
                    splashColor: MyColors.primaryColor.withValues(alpha: 0.2),
                    highlightColor: Colors.transparent,
                    icon: AnimatedIcon(
                      icon: AnimatedIcons.menu_close,
                      progress: controller,
                      size: 28,
                      color: MyColors.primaryColor,
                    ),
                    onPressed: toggle,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                ),
              ),

              /// Delete Icon
              Material(
                color: Colors.transparent,
                child: Tooltip(
                  message: 'Delete all tasks',
                  child: GestureDetector(
                    onTap: () {
                      deleteAllTask(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        CupertinoIcons.trash,
                        size: 24,
                        color: Colors.red.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Floating Action Button
class FAB extends StatefulWidget {
  const FAB({super.key});

  @override
  State<FAB> createState() => _FABState();
}

class _FABState extends State<FAB> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => TaskView(
              taskControllerForSubtitle: null,
              taskControllerForTitle: null,
              task: null,
            ),
          ),
        );
      },
      onTapDown: (_) {
        _animationController.forward();
      },
      onTapCancel: () {
        _animationController.reverse();
      },
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.85).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        ),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          elevation: 12,
          shadowColor: MyColors.primaryColor.withValues(alpha: 0.4),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: MyColors.primaryGradientColor,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: MyColors.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.add, color: Colors.white, size: 32),
            ),
          ),
        ),
      ),
    );
  }
}
