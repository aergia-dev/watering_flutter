class Protocol {
  static var map = {
    "POWER_ON": [0x01, 0x00, 0x00],
    "POWER_OFF": [0x01, 0x00, 0x01],

    //
    "TIMESTAMP": [0x02, 0x00, 0x00],
    "OPEN_TIME": [0x02, 0x00, 0x01],
    "WATERING_TIME": [0x02, 0x00, 0x02],
    "RESTING_TIME": [0x02, 0x00, 0x03],
  };
}