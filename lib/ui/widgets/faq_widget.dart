import 'package:flutter/material.dart';

/// FAQ widget for frequently asked questions
class FaqWidget extends StatelessWidget {
  const FaqWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Frequently Asked Questions', style: Theme.of(context).textTheme.headlineLarge),

          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              children: [
                _buildFaqItem(
                  context,
                  question: 'How do I search for characters?',
                  answer:
                      'Use the search bar at the top to enter Chinese characters, pinyin, or English words. The app will show related characters and their connections.',
                ),

                _buildFaqItem(
                  context,
                  question: 'What does the graph show?',
                  answer:
                      'The graph visualizes relationships between Chinese characters based on shared components, radicals, and semantic connections.',
                ),

                _buildFaqItem(
                  context,
                  question: 'How do I explore related characters?',
                  answer:
                      'Click on any character in the graph or in the related characters section to explore its connections and see example sentences.',
                ),

                _buildFaqItem(
                  context,
                  question: 'What character sets are supported?',
                  answer:
                      'The app supports simplified Chinese, traditional Chinese, HSK vocabulary, and Cantonese characters.',
                ),

                _buildFaqItem(
                  context,
                  question: 'Can I study offline?',
                  answer:
                      'Yes! All character data is stored locally in the app, so you can use it without an internet connection.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, {required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(question, style: Theme.of(context).textTheme.titleMedium),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(answer, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
