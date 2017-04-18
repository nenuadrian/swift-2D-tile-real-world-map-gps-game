<?php

for ($i = 32350; $i <= 32366; $i++) {
  @mkdir('data/' . $i);
  for ($j = 21200; $j <= 21220; $j++) {
    if (!file_exists("data/$i/$j.json")) {
      $data = file_get_contents("http://tile.mapzen.com/mapzen/vector/v1/all/16/$i/$j.json?api_key=mapzen-YMzZVyX");
      file_put_contents("data/$i/$j.json", $data);
    }
  }
}
