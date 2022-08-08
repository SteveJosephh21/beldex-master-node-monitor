import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:master_node_monitor/src/beldex/master_node.dart';
import 'package:master_node_monitor/src/beldex/master_node_status.dart';
import 'package:master_node_monitor/src/stores/settings_store.dart';

part 'node_sync_store.g.dart';

class NodeSyncStore = NodeSyncStoreBase with _$NodeSyncStore;

abstract class NodeSyncStoreBase with Store {
  NodeSyncStoreBase(this._masterNodes, this._settingsStore) : isSyncing = true;

  @action
  Future sync() async {
    isSyncing = true;
    final masterNodePublicKeys =
        _masterNodes.values.map((e) => e.publicKey).toList();
    try {
      final resultData =
          await _settingsStore.daemon.sendRPCRequest('get_master_nodes');
      final results = (resultData['result']['master_node_states'] as List);
      currentHeight = resultData['result']['height'] as int;
      networkSize =
          results.where((element) => element['active'] as bool).length;
      if (masterNodePublicKeys.isNotEmpty) {
        final myNodes = results.where((element) =>
            masterNodePublicKeys.contains(element['master_node_pubkey']));
        nodes = [];
        for (final result in myNodes) {
          final masterNodeStatus = MasterNodeStatus.load(result);
          final masterNode = _masterNodes.values.firstWhere((element) =>
              element.publicKey == masterNodeStatus.nodeInfo.publicKey);
          if (!masterNode.nodeInfo.equals(masterNodeStatus.nodeInfo)) {
            masterNode.nodeInfo = masterNodeStatus.nodeInfo;
            await _masterNodes.put(masterNode.key, masterNode);
          }
          nodes.add(masterNodeStatus);
        }
      }
    } catch (e) {
      print(e);
      nodes = [];
      networkSize = 0;
      currentHeight = 0;
    }
    isSyncing = false;
  }

  @action
  Future startSync() async {
    print('[Beldex-Master-Node: Sync] Started');
    while (runSyncLoop) {
      await sync();
      print('[Beldex-Master-Node: Sync] Ran Sync');
      await Future.delayed(Duration(seconds: 20));
    }
    print('[Beldex-Master-Node: Sync] Stopped!!!!');
  }

  @action
  void stopSync() {
    runSyncLoop = false;
  }

  @observable
  bool runSyncLoop = true;

  @observable
  bool isSyncing;

  @observable
  int currentHeight;

  @observable
  int networkSize;

  @observable
  List<MasterNodeStatus> nodes;

  SettingsStore _settingsStore;

  Box<MasterNode> _masterNodes;
}
