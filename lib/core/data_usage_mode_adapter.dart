// lib/core/settings/data_usage_mode_adapter.dart
import 'package:hive/hive.dart';
import '../features/settings/data/models/app_settings_model.dart';

class DataUsageModeAdapter extends TypeAdapter<DataUsageMode> {
  @override
  final int typeId = 2;

  @override
  DataUsageMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DataUsageMode.low;
      case 1:
        return DataUsageMode.standard;
      case 2:
        return DataUsageMode.unlimited;
      default:
        return DataUsageMode.standard;
    }
  }

  @override
  void write(BinaryWriter writer, DataUsageMode obj) {
    switch (obj) {
      case DataUsageMode.low:
        writer.writeByte(0);
        break;
      case DataUsageMode.standard:
        writer.writeByte(1);
        break;
      case DataUsageMode.unlimited:
        writer.writeByte(2);
        break;
    }
  }
}
