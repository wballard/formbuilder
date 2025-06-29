import 'package:flutter/material.dart';
import '../models/survey_model.dart';

class SurveyNavigator extends StatelessWidget {
  final List<SurveyPage> pages;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const SurveyNavigator({
    super.key,
    required this.pages,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final isActive = index == currentPage;
          final isCompleted = index < currentPage;
          
          return Padding(
            padding: const EdgeInsets.all(8),
            child: AspectRatio(
              aspectRatio: 1,
              child: InkWell(
                onTap: () => onPageChanged(index),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isActive
                        ? Theme.of(context).primaryColor
                        : isCompleted
                            ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).dividerColor,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isActive ? Colors.white : null,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pages[index].title,
                        style: TextStyle(
                          color: isActive ? Colors.white : null,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}