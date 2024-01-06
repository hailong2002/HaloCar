import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:halo_app/shared/widget.dart';

class Rating extends StatefulWidget {
  const Rating({Key? key, required this.tripId, required this.uid, required this.driverId}) : super(key: key);
  final String tripId;
  final String uid;
  final String driverId;
  @override
  State<Rating> createState() => _RatingState();
}

class _RatingState extends State<Rating> {

  late double _rating;
  final double _initialRating = 0.0;
  DatabaseService databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _rating = _initialRating;
  }
  @override
  Widget build(BuildContext context) {
    return   SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 10.0,
                ),
                _ratingBar(),
                ElevatedButton(
                    onPressed: (){
                      databaseService.rateTrip(widget.tripId, _rating, widget.uid, widget.driverId);
                      showToast("Thanks for your rating <3", Colors.pink);
                    },
                    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), backgroundColor: Colors.amber),
                    child: const Text("Rate", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),)
                )
              ],
            ),

    );
  }


  Widget _ratingBar() {
        return RatingBar.builder(
          initialRating: _initialRating,
          minRating: 0.5,
          direction:Axis.horizontal,
          allowHalfRating: true,
          unratedColor: Colors.amber.withAlpha(50),
          itemCount: 5,
          itemSize: 50.0,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            setState(() {
              _rating = rating;
            });
          },
          updateOnDrag: true,
        );
    }
  }



