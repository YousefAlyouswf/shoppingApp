
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shop_app/widgets/widgets.dart';

class GmapManager extends StatefulWidget {
  final LatLng latLng;

  const GmapManager({Key key, this.latLng}) : super(key: key);
  
  @override
  _GmapManagerState createState() => _GmapManagerState();
}

class _GmapManagerState extends State<GmapManager> {
  Location location;
  LocationData _locationData;
  bool _serviceEnabled;
  //PermissionStatus _permissionGranted;

  final Set<Marker> _markers = {};
  void _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId("111"),
        position: widget.latLng,
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  MapType mapType;
  bool isNormalType = true;
  changeMapType() {
    setState(() {
      if (isNormalType) {
        mapType = MapType.normal;
        isNormalType = false;
      } else {
        mapType = MapType.satellite;
        isNormalType = true;
      }
    });
  }

  GoogleMapController googleMapController;
  onMapCareated(GoogleMapController controller) {
    googleMapController = controller;
    setState(() {});
  }

  serveiceRequest() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
  }

  double long;
  double lat;
  getLocation() async {
    _locationData = await location.getLocation();

    setState(() {
      long = _locationData.longitude;
      lat = _locationData.latitude;
    });
  }

  @override
  void initState() {
    super.initState();

    location = new Location();
    serveiceRequest();
    getLocation();
    changeMapType();
    _onAddMarkerButtonPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: lat == null
          ? Container()
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: onMapCareated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(lat, long),
                    zoom: 15,
                  ),
                  mapType: mapType,
                  markers: _markers,
                  myLocationEnabled: true,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: changeMapType,
                      child: Container(
                        alignment: Alignment.center,
                        height: 30,
                        decoration: BoxDecoration(
                            color: !isNormalType ? Colors.orange : Colors.black,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        width: 100,
                        child: Text(
                          !isNormalType ? "قمر صناعي" : "خريطة",
                          style: TextStyle(
                            color: isNormalType ? Colors.orange : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
