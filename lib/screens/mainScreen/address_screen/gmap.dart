import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:location/location.dart';

import '../homePage.dart';

class Gmap extends StatefulWidget {
  @override
  _GmapState createState() => _GmapState();
}

class _GmapState extends State<Gmap> {
  Location location;
  LocationData _locationData;
  PermissionStatus _permissionGranted;
  Map<MarkerId, Marker> markers =
      <MarkerId, Marker>{}; // CLASS MEMBER, MAP OF MARKS

  void _add(LatLng latLng) {
    try {
      final MarkerId markerId = MarkerId('0');

      // creating a new MARKER
      final Marker marker = Marker(
        markerId: markerId,
        position: latLng,
        infoWindow:
            InfoWindow(title: "الموقع الي بنوصله الطلب", snippet: 'رفوف'),
        onTap: () {},
      );

      setState(() {
        // adding a new marker to map
        markers[markerId] = marker;
      });
    } catch (e) {}
  }

  GoogleMapController googleMapController;
  onapCareated(GoogleMapController controller) {
    try {
      googleMapController = controller;
      setState(() {});
    } catch (e) {}
  }

  serveiceRequest() async {
    try {
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied ||
          _permissionGranted == PermissionStatus.deniedForever) {
        setState(() {
          long = 46.674976;
          lat = 24.711906;
        });
      } else {
        setState(() {
          long = 46.674976;
          lat = 24.711906;
        });
      }
    } catch (e) {}
  }

  double long;
  double lat;
  @override
  void initState() {
    super.initState();

    location = new Location();
    serveiceRequest();
    getLocation();
    changeMapType();
  }

  getLocation() async {
    try {
      _locationData = await location.getLocation();

      setState(() {
        long = _locationData.longitude;
        lat = _locationData.latitude;
      });
    } catch (e) {
      print("PERMISSION_DENIED");
    }
  }

  MapType mapType;
  bool isNormalType = true;
  changeMapType() {
    try {
      setState(() {
        if (isNormalType) {
          mapType = MapType.normal;
          isNormalType = false;
        } else {
          mapType = MapType.satellite;
          isNormalType = true;
        }
      });
    } catch (e) {}
  }

  LatLng customerLocation;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(word("select_map", context)),
      ),
      body: Stack(
        children: [
          lat == null
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : GoogleMap(
                  compassEnabled: true,
                  mapType: mapType,
                  onMapCreated: onapCareated,
                  markers: Set<Marker>.of(markers.values),
                  onTap: (latLng) {
                    try {
                      setState(() {
                        customerLocation = latLng;
                      });
                      _add(latLng);
                    } catch (e) {}
                  },
                  onLongPress: (latLng) {
                    setState(() {
                      customerLocation = latLng;
                    });
                    _add(latLng);
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(lat, long),
                    zoom: 14.4746,
                  ),
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
                      borderRadius: BorderRadius.all(Radius.circular(20))),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: InkWell(
                onTap: () {
                  try {
                    if (customerLocation == null) {
                      errorToast("أختر موقع المنزل من الخريطة");
                    } else {
                      Navigator.pop(context, customerLocation);
                    }
                  } catch (e) {
                    print("Press back");
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 50,
                  decoration: BoxDecoration(
                    color: customerLocation == null ? Colors.grey : Colors.blue,
                  ),
                  child: Center(
                    child: Text(
                      "أرسل هذا الموقع",
                      style: TextStyle(color: Colors.white, fontSize: 22),
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
