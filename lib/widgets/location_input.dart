import 'dart:convert';

import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation) onSelectLocation;

  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;

  Future savePlace(double latitude, double longitude) async{
    final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1');
    final response = await http.get(url, headers: {
      'User-Agent': 'FavoritePlacesApp/1.0.0'
    });
    final resData = json.decode(response.body);
    final address = resData['display_name'] ?? 'Unknown address';

    setState(() {
      _pickedLocation = PlaceLocation(latitude: latitude, longitude: longitude, address: address);
      _isGettingLocation = false;
    });
    
    return widget.onSelectLocation(_pickedLocation!);
  }
  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    setState(() {
      _isGettingLocation = true;
    });
     
    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if(lat == null || lng == null){
      return;
    }

    savePlace(lat, lng);
  }

  void _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<PlaceLocation>(
      MaterialPageRoute(
        builder: (context) => const MapScreen(),
      ),
    );

    if (pickedLocation == null) {
      return;
    }

    savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {

    Widget previewContent = Text(
            "NO location choosen",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          );
    
    if(_pickedLocation != null){
      previewContent = Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(_pickedLocation!.latitude, _pickedLocation!.longitude),
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.favorite_places',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(_pickedLocation!.latitude, _pickedLocation!.longitude),
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.location_pin,
                      color: const Color.fromARGB(255, 184, 85, 71),
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if(_pickedLocation!.address.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                ),
                child: Text(
                  _pickedLocation!.address,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      );
    }
    if(_isGettingLocation){
      previewContent = CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 170,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: previewContent
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              label: Text("Get Current Location"),
              icon: Icon(Icons.map),
            ),
            TextButton.icon(
              onPressed: _selectOnMap,
              label: Text("Select on Map"),
              icon: Icon(Icons.map),
            ),
          ],
        ),
      ],
    );
  }
}
