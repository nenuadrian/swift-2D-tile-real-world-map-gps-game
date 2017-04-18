<?php

function tileToLatLon($xtile, $ytile) {
	$n = pow(2, 16);
	$lon_deg = $xtile / $n * 360.0 - 180.0;
	$lat_deg = rad2deg(atan(sinh(pi() * (1 - 2 * $ytile / $n))));

	return array($lat_deg, $lon_deg);
}

function latLonToTile($lat, $lon) {
	$xtile = floor((($lon + 180) / 360) * pow(2, 16));
	$ytile = floor((1 - log(tan(deg2rad($lat)) + 1 / cos(deg2rad($lat))) / pi()) /2 * pow(2, 16));
	return array($xtile, $ytile);
}


function latLonToMeters($lat, $lon) {
	$earthRadius = 6378137;
    $originShift = 2 * M_PI * $earthRadius / 2;

    $x = $lon * $originShift / 180.0;
    $y = log(tan((90 + $lat) * M_PI / 360)) / (M_PI / 180);
    $y = $y * $originShift / 180.0;


    return array($x, $y);
}

function processField($data, $tile) {
  $result = array();
  foreach($data['features'] as $f) {
    $shape = array('type' => strtolower($f['geometry']['type']), 'coords' => array());
  //  print_r($f);
    if (in_array($shape['type'], array('polygon', 'multilinestring'))) {
      foreach($f['geometry']['coordinates'] as $c) {
        $ccc = [];
        foreach($c as $cc) {
          $cc = latLonToMeters($cc[1], $cc[0]);
          $ccc[] = array(abs($cc[0] - $tile[0]), abs($cc[1] - $tile[1]));
        }
        $shape['coords'][] = $ccc;
      }
    } else if ($shape['type'] == 'multipolygon') {
      foreach($f['geometry']['coordinates'] as $c) {
        $cccc = [];
        foreach($c as $cc) {
          $ccccc = [];
          foreach($cc as $ccc) {
            $ccc = latLonToMeters($ccc[1], $ccc[0]);
            $ccccc[] = array(abs($ccc[0] - $tile[0]), abs($ccc[1] - $tile[1]));
          }
          $cccc[] = $ccccc;
        }
        $shape['coords'][] = $cccc;
      }
    } else {
      foreach($f['geometry']['coordinates'] as $c) {
          $c = latLonToMeters($c[1], $c[0]);
          $shape['coords'][] =  array(abs($c[0] - $tile[0]), abs($c[1] - $tile[1]));
      }
    }
    $result[] = $shape;
  }

  return $result;
}

$folders = scandir('data');
unset($folders[0], $folders[1]);

foreach($folders as $x) {
  $files = scandir($f = 'data/' . $x);
  @mkdir('processed/' . $x);
  foreach($files as $f2) {
    if (!file_exists('processed/' . $x . '/' . $f2)) {
      $data = json_decode(file_get_contents('data/' . $x . '/' . $f2), true);
      $tile = tileToLatLon($x, $y = explode('.', $f2)[0]);
      $tile_m = latLonToMeters($tile[0], $tile[1]);
      $result = array(
        'x' => intval($x),
        'y' => intval($y),
        'tile' => $tile,
        'tile_m' => $tile_m,
        'water' => processField($data['water'], $tile_m),
        'buildings' => processField($data['buildings'], $tile_m),
        'roads' => processField($data['roads'], $tile_m)
      );

      file_put_contents('processed/' . $x . '/' . $f2, json_encode($result));
    }
  }
}
