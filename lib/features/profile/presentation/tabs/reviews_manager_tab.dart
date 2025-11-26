import 'package:flutter/material.dart';
import '../../../business/data/business_service.dart';
import '../../../business/domain/business_model.dart';
import 'package:intl/intl.dart';

class ReviewsManagerTab extends StatelessWidget {
  final String businessId;
  final BusinessService _businessService = BusinessService();

  ReviewsManagerTab({super.key, required this.businessId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BusinessModel>(
      stream: _businessService.getBusinessStream(businessId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final business = snapshot.data!;
        final reviews = business.reviews;

        if (reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No tienes reseñas aún',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cuando los clientes dejen reseñas, aparecerán aquí',
                ),
              ],
            ),
          );
        }

        // Calculate statistics
        final totalReviews = reviews.length;
        final averageRating = business.rating;
        final ratingDistribution = _calculateRatingDistribution(reviews);

        return Column(
          children: [
            // Statistics Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            averageRating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < averageRating.floor()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$totalReviews reseña${totalReviews != 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      // Rating distribution bars
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(5, (index) {
                          final stars = 5 - index;
                          final percentage = ratingDistribution[stars] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Text(
                                  '$stars★',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 100,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: percentage / 100,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${percentage.toInt()}%',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Reviews List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: reviews.length,
                separatorBuilder: (context, index) => const Divider(height: 32),
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return _buildReviewCard(context, review);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReviewCard(BuildContext context, Review review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                review.userName[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < review.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd/MM/yyyy').format(review.date),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(review.comment, style: const TextStyle(fontSize: 15, height: 1.4)),
      ],
    );
  }

  Map<int, double> _calculateRatingDistribution(List<Review> reviews) {
    if (reviews.isEmpty) return {};

    final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var review in reviews) {
      final rating = review.rating.floor();
      distribution[rating] = (distribution[rating] ?? 0) + 1;
    }

    return distribution.map(
      (key, value) => MapEntry(key, (value / reviews.length) * 100),
    );
  }
}
