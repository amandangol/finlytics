import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../models/photo_model.dart';
import '../../../../../../models/transaction_model.dart';

class PhotoSection extends StatelessWidget {
  final TransactionModel transaction;
  final Future<List<PhotoModel>> Function(String userId, String transactionId)
      fetchPhotos;

  const PhotoSection(
      {super.key, required this.transaction, required this.fetchPhotos});

  @override
  Widget build(BuildContext context) {
    Future<void> downloadImage(BuildContext context, String url) async {
      try {
        // Format the current date and time
        final now = DateTime.now();
        final formattedDate = DateFormat('yyyyMMdd_HHmmss').format(now);
        final filePath =
            "/storage/emulated/0/DCIM/TrackUrSpends/transaction_photo_$formattedDate.jpg";

        // Download the file
        await Dio().download(url, filePath);

        // Notify the user of the successful download
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image downloaded to $filePath')),
        );
      } catch (e) {
        // Handle any errors during the download
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading image: $e')),
        );
      }
    }

    return FutureBuilder<List<PhotoModel>>(
      future: fetchPhotos(transaction.userId, transaction.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SpinKitThreeBounce(
              color: AppTheme.primaryDarkColor,
              size: 20.0,
            ),
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading photos'));
        } else if (snapshot.data!.isEmpty) {
          return const Center(child: Text('No photos for this transaction'));
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Photos:', style: AppTheme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final photo = snapshot.data![index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => downloadImage(context, photo.imageUrl),
                        child: Image.network(
                          photo.imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
