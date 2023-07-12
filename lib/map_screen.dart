import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_cluster/place.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  //Map Variable Initialization
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(53.665386199951172, 9.9735679626464844),
    zoom: 14,
  );

  late ClusterManager _manager;
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = {};

  List<Place> items = [
    Place(
        name: 'Location 1',
        latLng: const LatLng(53.665386199951172, 9.9735679626464844)),
    Place(
        name: 'Location 2',
        latLng: const LatLng(52.383163452148437, 9.8094778060913086)),
    Place(
        name: 'Location 3',
        latLng: const LatLng(52.383163452148437, 9.8094778060913086)),
    Place(
        name: 'Location 4',
        latLng: const LatLng(52.383163452148437, 9.8094778060913086)),
    Place(
        name: 'Location 5',
        latLng: const LatLng(52.280868530273438, 7.446558952331543)),
    Place(
        name: 'Location 6',
        latLng: const LatLng(52.383163452148437, 9.8094778060913086)),
    Place(
        name: 'Location 7',
        latLng: const LatLng(52.2806396484375, 7.446159839630127)),
    Place(
        name: 'Location 8',
        latLng: const LatLng(48.492977142333984, 9.21216106414795)),
    Place(
        name: 'Location 9',
        latLng: const LatLng(48.520744323730469, 9.2085399627685547)),
    Place(
        name: 'Location 10',
        latLng: const LatLng(51.357879638671875, 12.457629203796387))
  ];

  @override
  void initState() {
    _manager = _initClusterManager();
    super.initState();
  }

  ClusterManager _initClusterManager() {
    return ClusterManager<Place>(
      levels: [1, 4.25, 6.75, 8.25, 11.5, 14.5, 16.0, 16.5, 20.0],
      items, _updateMarkers,
        markerBuilder: _markerBuilder);
  }

  void _updateMarkers(Set<Marker> markers) {
    print('Updated ${markers.length} markers');
    setState(() {
      this.markers = markers;
    });
  }

  Future<Marker> Function(Cluster<Place>) get _markerBuilder =>
      (cluster) async {
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {
            print('---- $cluster');
            for (var p in cluster.items) {
              print(p);
            }
          },
          icon: await _getMarkerBitmap(cluster.isMultiple ? 125 : 75,
              text: cluster.isMultiple ? cluster.count.toString() : null),
        );
      };


  //Change your marker here
  Future<BitmapDescriptor> _getMarkerBitmap(int size, {String? text}) async {
    if (kIsWeb) size = (size / 2).floor();

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.orange;
    final Paint paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Map Cluster Demo"),
      ),
      body: GoogleMap(
        myLocationEnabled: true,
        initialCameraPosition: _initialCameraPosition,
        myLocationButtonEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _manager.setMapId(controller.mapId);
        },
        onCameraMove: _manager.onCameraMove,
        onCameraIdle: _manager.updateMap,
        markers: markers,
      ),
    );
  }
}
