
import '../domain/note_node.dart';
import '../../database/app_database.dart';

extension NoteNodeRowMapper on NoteNodeRow {
  NoteNode toNode() => NoteNode(
        id: id,
        parentId: parentId,
        isFolder: isFolder,
        name: name,
        body: isFolder ? '' : body,
        autoName: autoName,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );
}
