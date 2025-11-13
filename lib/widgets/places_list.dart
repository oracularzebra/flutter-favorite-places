import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/screens/place_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacesList extends ConsumerStatefulWidget {
  const PlacesList({required this.places, super.key});
  final List<Place> places;

  @override
  ConsumerState<PlacesList> createState() {
    return _PlacesListState();
  }
}

class _PlacesListState extends ConsumerState<PlacesList> {
  @override
  Widget build(BuildContext context) {
    if (widget.places.isEmpty) {
      return Center(child: Text("No places added yet."));
    }
    return ListView.builder(
      itemCount: widget.places.length,
      itemBuilder: (context, index) => ListTile(
        leading: CircleAvatar(
          radius: 26,
          backgroundImage: FileImage(widget.places[index].image),
        ),
        title: Text(
          widget.places[index].title,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          widget.places[index].location.address,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                PlacesDetailScreen(place: widget.places[index]),
          ),
        ),
      ),
    );
  }
}
