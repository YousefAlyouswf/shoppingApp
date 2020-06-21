import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;

const apiKey = "AIzaSyDDYcLMRVB_DYsqm_pVbgYtPDKsYBKqd8U";

class GoogleMapsServices {
  Future<String> getRouteCoordinates(LatLng l1, LatLng l2) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$apiKey";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);

    return values["routes"][0]["overview_polyline"]["points"];
  }

  Future<String> getDistance(LatLng l1, LatLng l2) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$apiKey";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);

    return values['routes'][0]['legs'][0]['distance']['text'];
  }
}

class GmapManager extends StatefulWidget {
  final LatLng latLng;

  const GmapManager({Key key, this.latLng}) : super(key: key);

  @override
  _GmapManagerState createState() => _GmapManagerState();
}

class _GmapManagerState extends State<GmapManager> {
  // bool loading = true;
  // final Set<Marker> _markers = {};
  // final Set<Polyline> _polyLines = {};
  // GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  // Set<Polyline> get polyLines => _polyLines;
  // Completer<GoogleMapController> _controller = Completer();
  // static LatLng latLng;
  // LocationData currentLocationq;

  // @override
  // void initState() {
  //   getLocation();
  //   setSourceAndDestinationIcons();
  //   sendRequest();
  //   super.initState();
  // }

  // getLocation() async {
  //   var location = new Location();
  //   if (mounted) {
  //     location.onLocationChanged.listen((currentLocation) {
  //       latLng = LatLng(currentLocation.latitude, currentLocation.longitude);

  //       _onAddMarkerButtonPressed();
  //       loading = false;
  //     });
  //   }

  //   sendRequest();
  // }

  // BitmapDescriptor sourceIcon;
  // BitmapDescriptor destinationIcon;
  // void _onAddMarkerButtonPressed() {
  //   if (mounted) {
  //     setState(() {
  //       _markers.add(Marker(
  //         markerId: MarkerId("111"),
  //         position: latLng,
  //         icon: sourceIcon,
  //       ));
  //     });
  //   }
  // }

  // void setSourceAndDestinationIcons() async {
  //   sourceIcon = await BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration(devicePixelRatio: 2.5),
  //       'assets/images/map-marker.png');

  //   destinationIcon = await BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration(devicePixelRatio: 2.5), 'assets/images/marker.png');
  // }

  // void onCameraMove(CameraPosition position) {
  //   latLng = position.target;
  // }

  // List<LatLng> _convertToLatLng(List points) {
  //   List<LatLng> result = <LatLng>[];
  //   for (int i = 0; i < points.length; i++) {
  //     if (i % 2 != 0) {
  //       result.add(LatLng(points[i - 1], points[i]));
  //     }
  //   }
  //   return result;
  // }


  // void createRoute(String encondedPoly) {
  //   _polyLines.add(Polyline(
  //       polylineId: PolylineId(latLng.toString()),
  //       width: 4,
  //       points: _convertToLatLng(_decodePoly(encondedPoly)),
  //       color: Colors.red));
  // }

  // void _addMarker(LatLng location, String address) {
  //   _markers.add(
  //     Marker(
  //       markerId: MarkerId("112"),
  //       position: location,
  //       infoWindow: InfoWindow(title: address, snippet: "go here"),
  //       icon: destinationIcon,
  //     ),
  //   );
  // }

  // List _decodePoly(String poly) {
  //   var list = poly.codeUnits;
  //   var lList = new List();
  //   int index = 0;
  //   int len = poly.length;
  //   int c = 0;
  //   do {
  //     var shift = 0;
  //     int result = 0;

  //     do {
  //       c = list[index] - 63;
  //       result |= (c & 0x1F) << (shift * 5);
  //       index++;
  //       shift++;
  //     } while (c >= 32);
  //     if (result & 1 == 1) {
  //       result = ~result;
  //     }
  //     var result1 = (result >> 1) * 0.00001;
  //     lList.add(result1);
  //   } while (index < len);

  //   for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

  //   return lList;
  // }

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
// for my drawn routes on the map
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;
  String googleAPIKey = "AIzaSyDDYcLMRVB_DYsqm_pVbgYtPDKsYBKqd8U";
// for my custom marker pins
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
// the user's initial location and current location
// as it moves
  LocationData currentLocation;
// a reference to the destination location
  LocationData destinationLocation;
// wrapper around the location API
  Location location;

  @override
  void initState() {
    super.initState();

    // create an instance of Location
    location = new Location();
    polylinePoints = PolylinePoints();

    // subscribe to changes in the user's location
    // by "listening" to the location's onLocationChanged event
    location.onLocationChanged.listen((LocationData cLoc) {
      // cLoc contains the lat and long of the

      // current user's position in real time,
      // so we're holding on to it
      currentLocation = cLoc;
      updatePinOnMap();
    });
    // set custom marker pins
    setSourceAndDestinationIcons();
    // set the initial location
    setInitialLocation();
  }
  // GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  // String distance = '';
  // void sendRequest() async {
  //   LatLng destination =
  //       LatLng(widget.latLng.latitude, widget.latLng.longitude);
 
  //   distance = await _googleMapsServices.getDistance(latLng, destination);
  // }
  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/map-marker.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/images/marker.png');
  }

  void setInitialLocation() async {
    // set the initial location by pulling the user's
    // current location from the location's getLocation()
    currentLocation = await location.getLocation();

    // hard-coded destination for this example
    destinationLocation = LocationData.fromMap({
      "latitude": widget.latLng.latitude,
      "longitude": widget.latLng.longitude
    });
  }

//------------------------------------------------------------------
  MapType _currentMapType = MapType.normal;
  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(24.693353, 46.685243),
    );
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING);
    }
    return Scaffold(
      appBar: appBar(),
      body: Stack(
        children: [
          GoogleMap(
        
              markers: _markers,
              polylines: _polylines,
              mapType: _currentMapType,
              initialCameraPosition: initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                // my map has completed being created;
                // i'm ready to show the pins on the map
                showPinsOnMap();
              }),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: FloatingActionButton(
                onPressed: _onMapTypeButtonPressed,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                backgroundColor: Colors.green,
                child: const Icon(Icons.map, size: 36.0),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                    border: Border.all(), color: Colors.blue[100]),
                child: FlatButton(
                  onPressed: showPinsOnMap,
                  child: Text("حدد الطريق"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showPinsOnMap() {
    // // get a LatLng for the source location
    // // from the LocationData currentLocation object
    // var pinPosition =
    //     LatLng(currentLocation.latitude, currentLocation.longitude);
    // // get a LatLng out of the LocationData object
    // var destPosition =
    //     LatLng(destinationLocation.latitude, destinationLocation.longitude);
    // // add the initial source location pin
    // _markers.add(Marker(
    //     markerId: MarkerId('sourcePin'),
    //     position: pinPosition,
    //     icon: sourceIcon));
    // // destination pin
    // _markers.add(Marker(
    //     markerId: MarkerId('destPin'),
    //     position: destPosition,
    //     icon: destinationIcon));
    // // set the route lines on the map from source to destination
    // // for more info follow this tutorial
    // setPolylines();
  }

void setPolylines() async {
  //  List<PointLatLng> result = await polylinePoints.getRouteBetweenCoordinates(
  //  googleAPIKey,
  //  currentLocation.latitude,
  //  currentLocation.longitude,
  //  destinationLocation.latitude,
  //  destinationLocation.longitude);
  //  if(result.isNotEmpty){
  //     result.forEach((PointLatLng point){
  //        polylineCoordinates.add(
  //           LatLng(point.latitude,point.longitude)
  //        );
  //     });
  //    setState(() {
  //     _polylines.add(Polyline(
  //       width: 5, // set the width of the polylines
  //       polylineId: PolylineId("“poly”"),
  //       color: Color.fromARGB(255, 40, 122, 198), 
  //       points: polylineCoordinates
  //       ));
  //   });
  // }
}

  void updatePinOnMap() async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    if (mounted) {
      setState(() {
        // updated position
        var pinPosition =
            LatLng(currentLocation.latitude, currentLocation.longitude);

        // the trick is to remove the marker (by id)
        // and add it again at the updated location
        _markers.removeWhere((m) => m.markerId.value == "sourcePin");
        _markers.add(Marker(
            markerId: MarkerId("sourcePin"),
            position: pinPosition, // updated position
            icon: sourceIcon));
      });
    }
  }
}
