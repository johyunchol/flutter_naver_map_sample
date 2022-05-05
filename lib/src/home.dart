import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Completer<NaverMapController> _controller = Completer();

  static const CameraPosition initPosition = CameraPosition(
    target: LatLng(37.3626138, 126.9264801),
    zoom: 17.0,
  );

  Set<Marker> markers = {};
  Set<PathOverlay> pathOverlays = {};
  Set<CircleOverlay> circles = {};
  Set<PolygonOverlay> polygons = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NaverMap(
            initialCameraPosition: initPosition,
            onMapCreated: (NaverMapController controller) {
              _controller.complete(controller);
            },
            mapType: MapType.Basic,
            pathOverlays: pathOverlays,
            circles: circles.toList(),
            polygons: polygons.toList(),
            markers: markers.toList(),
            onMapTap: (LatLng latLng) async {
              final NaverMapController controller = await _controller.future;
              controller.moveCamera(CameraUpdate.scrollTo(latLng), animationDuration: 2);

              setState(() {
                markers.add(
                  Marker(markerId: latLng.toString(), position: latLng, infoWindow: "${latLng.latitude} / ${latLng.longitude}"),
                );
              });
            },
            useSurface: kReleaseMode,
          ),
          Positioned(
              bottom: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    child: const Text('직선'),
                    onPressed: () {
                      List<LatLng> list = const [
                        LatLng(37.3625806, 126.9248464),
                        LatLng(37.3626138, 126.9264801),
                        LatLng(37.3632727, 126.9280313),
                      ];

                      setState(() {
                        clearMap();

                        pathOverlays.add(PathOverlay(
                          PathOverlayId("1"),
                          list,
                          width: 4,
                          color: Colors.red,
                          outlineColor: Colors.white,
                        ));

                        fitBounds(list);
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    child: const Text('원'),
                    onPressed: () {
                      LatLng center = const LatLng(37.3626138, 126.9264801);

                      clearMap();

                      setState(() {
                        circles.add(CircleOverlay(
                          overlayId: center.toString(),
                          center: center,
                          radius: 35.0,
                          color: Colors.transparent,
                          outlineColor: Colors.red,
                          outlineWidth: 4,
                        ));
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    child: const Text('다각형'),
                    onPressed: () {
                      List<LatLng> polygon1 = const [
                        LatLng(37.3625806, 126.9248464),
                        LatLng(37.3626138, 126.9264801),
                        LatLng(37.3632727, 126.9280313),
                      ];

                      List<LatLng> polygon2 = const [
                        LatLng(37.36119, 126.9193982),
                        LatLng(37.3534215, 126.9295909),
                        LatLng(37.3549206, 126.9327015),
                      ];

                      setState(() {
                        clearMap();

                        polygons.add(PolygonOverlay(
                          polygon1.toString(),
                          polygon1,
                          color: Colors.transparent,
                          outlineColor: Colors.red,
                          outlineWidth: 4,
                        ));
                        polygons.add(PolygonOverlay(
                          polygon2.toString(),
                          polygon2,
                          color: Colors.transparent,
                          outlineColor: Colors.red,
                          outlineWidth: 4,
                        ));

                        fitBounds([...polygon1, ...polygon2]);
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    child: const Text('다각형-반전'),
                    onPressed: () {
                      List<LatLng> polygon1 = const [
                        LatLng(37.3625806, 126.9248464),
                        LatLng(37.3626138, 126.9264801),
                        LatLng(37.3632727, 126.9280313),
                      ];

                      List<LatLng> polygon2 = const [
                        LatLng(37.36119, 126.9193982),
                        LatLng(37.3534215, 126.9295909),
                        LatLng(37.3549206, 126.9327015),
                      ];

                      setState(() {
                        clearMap();

                        polygons.add(PolygonOverlay(
                          polygon1.toString(),
                          createOuterBounds(),
                          holes: [polygon1, polygon2],
                          color: Colors.black38,
                          outlineColor: Colors.red,
                          outlineWidth: 4,
                        ));

                        fitBounds([...polygon1, ...polygon2]);
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                ],
              )),
        ],
      ),
    );
  }

  List<LatLng> createOuterBounds() {
    double delta = 0.01;

    List<LatLng> list = [];

    list.add(LatLng(90 - delta, -180 + delta));
    list.add(LatLng(0, -180 + delta));
    list.add(LatLng(-90 + delta, -180 + delta));
    list.add(LatLng(-90 + delta, 0));
    list.add(LatLng(-90 + delta, 180 - delta));
    list.add(LatLng(0, 180 - delta));
    list.add(LatLng(90 - delta, 180 - delta));
    list.add(LatLng(90 - delta, 0));
    list.add(LatLng(90 - delta, -180 + delta));

    return list;
  }

  clearMap() {
    pathOverlays.clear();
    circles.clear();
    polygons.clear();
    markers.clear();
  }

  fitBounds(List<LatLng> bounds) async {
    final NaverMapController controller = await _controller.future;
    controller.moveCamera(CameraUpdate.fitBounds(LatLngBounds.fromLatLngList(bounds)), animationDuration: 2);
  }
}
