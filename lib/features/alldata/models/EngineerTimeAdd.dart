class EngineerTimeAdd {

  String? name;
  String? userId;
  List<EngineerTimeData> time;
  bool more;
  bool isLeadMe;

  EngineerTimeAdd({
    this.name,
    this.userId,
    required this.time,
    this.more = false,
    this.isLeadMe = false,
  });
}

class EngineerTimeData {

  String? startTime;
  String? endTime;
  bool isNew;

  EngineerTimeData({
    this.startTime,
    this.endTime,
    this.isNew = true,
  });
}