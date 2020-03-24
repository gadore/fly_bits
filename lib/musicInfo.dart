class MusicItem {
  String id;
  String album;
  String artist;
  String path;
  String dateAdded;
  String displayName;
  String duration;
  String size;

  String getdisplayName(){
    return this.displayName.split('.')[0];
  }

  String getActualTimeLength(){
    var totalSeconds = int.parse(this.duration)/1000;
    var hours = totalSeconds/(60*60);
    var minutes = (totalSeconds - hours*60*60)/60;
    var seconds = (totalSeconds - hours*60*60 - minutes*60);
    return hours.toString() + ':' + minutes.toString() + ':' + seconds.toString();
  }

  String getStorageSize(){
    var totalByte = int.parse(this.size);
    var mb = totalByte/(1024*1024);
    var kb = (totalByte-mb*1024*1024);
    return mb == 0 ? kb.toString() + 'KB' : mb.toString() + 'M';
  }
}