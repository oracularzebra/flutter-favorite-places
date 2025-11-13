import 'package:favorite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
      latitude: 37.422,
      longitude: -122.084,
      address: '',
    ),
    this.isSelecting = true,
  });
  final PlaceLocation location;
  final bool isSelecting;

  @override
  State<MapScreen> createState() {
    return _MapScreenState();
  }
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;

  @override
  void initState() {
    super.initState();
    _pickedLocation = LatLng(widget.location.latitude, widget.location.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isSelecting ? 'Pick your location' : 'Your location',
        ),
        actions: [
          if (widget.isSelecting)
            IconButton(
              onPressed: () {
                if (_pickedLocation != null) {
                  Navigator.of(context).pop(PlaceLocation(
                    latitude: _pickedLocation!.latitude,
                    longitude: _pickedLocation!.longitude,
                    address: '',
                  ));
                }
              },
              icon: Icon(Icons.save),
            ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(widget.location.latitude, widget.location.longitude),
          initialZoom: 16,
          onTap: widget.isSelecting
              ? (tapPosition, point) {
                  setState(() {
                    _pickedLocation = point;
                  });
                }
              : null,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.favorite_places',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _pickedLocation ?? LatLng(widget.location.latitude, widget.location.longitude),
                width: 40,
                height: 40,
                child: Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
