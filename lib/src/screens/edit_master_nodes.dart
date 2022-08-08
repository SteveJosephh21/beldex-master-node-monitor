import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:master_node_monitor/generated/l10n.dart';
import 'package:master_node_monitor/src/beldex/master_node.dart';
import 'package:master_node_monitor/src/stores/node_sync_store.dart';
import 'package:master_node_monitor/src/utils/edit_master_node_arguments.dart';
import 'package:master_node_monitor/src/utils/router/beldex_routes.dart';
import 'package:master_node_monitor/src/utils/short_address.dart';
import 'package:master_node_monitor/src/utils/theme/palette.dart';
import 'package:master_node_monitor/src/widgets/base_page.dart';
import 'package:provider/provider.dart';

class EditMasterNodesPage extends BasePage {
  @override
  String get title => S.current.title_edit_master_nodes;

  @override
  Widget trailing(BuildContext context) {
    return SizedBox(
      width: 30,
      child: MaterialButton(
          padding: EdgeInsets.all(0),
          onPressed: () =>
              Navigator.of(context).pushNamed(BeldexRoutes.addMasterNode),
          child: Icon(Icons.add_sharp,
              color: Theme.of(context).primaryTextTheme.caption.color,
              size: 24)),
    );
  }

  @override
  Widget body(BuildContext context) => EditMasterNodesPageBody();
}

class EditMasterNodesPageBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EditMasterNodesPageBodyState();
}

class EditMasterNodesPageBodyState extends State<EditMasterNodesPageBody> {
  @override
  Widget build(BuildContext context) {
    final masterNodeSources = context.watch<Box<MasterNode>>();
    final nodeSyncStore = context.watch<NodeSyncStore>();

    final masterNodes = masterNodeSources.values.toList();

    return Container(
      padding: EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: <Widget>[
          Expanded(
              child: ListView.separated(
                  separatorBuilder: (_, __) => Divider(
                      color: Theme.of(context).dividerTheme.color, height: 1),
                  itemCount: masterNodes.length,
                  itemBuilder: (BuildContext context, int index) {
                    final masterNode = masterNodes[index];
                    final publicKey = masterNode.publicKey;

                    final content = Container(
                      padding: EdgeInsets.all(10),
                        child: ListTile(
                      leading: Icon(CupertinoIcons.chart_bar_fill,color: Theme.of(context)
                          .primaryTextTheme
                          .headline6
                          .color,),
                      trailing: InkWell(
                        onTap: () async {
                          await masterNodeSources.delete(masterNode.key);

                          if (masterNodeSources.isEmpty)
                            Navigator.pushNamedAndRemoveUntil(context, BeldexRoutes.welcome,
                                ModalRoute.withName(BeldexRoutes.dashboard));
                          else {
                            await nodeSyncStore.sync();
                            setState(() {

                            });
                          }
                        },
                        child: SvgPicture.asset('assets/images/delete.svg',color:BeldexPalette.deleteButton,width: 20,height: 20,),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            masterNode.name,
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .primaryTextTheme
                                    .headline6
                                    .color),
                          ),
                          SizedBox(height: 10,),
                          Text(publicKey.toShortAddress(16),
                            style: TextStyle(
                                fontSize: 12.0,
                                color: BeldexPalette.progressCenterText),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, BeldexRoutes.editMasterNode,
                                arguments: EditMasterNodeArguments(publicKey, false))
                            .whenComplete(() => setState(() {}));
                      },
                    ));

                    return Dismissible(
                        key: Key('${masterNode.key}'),
                        onDismissed: (direction) async {
                          await masterNodeSources.delete(masterNode.key);

                          if (masterNodeSources.isEmpty)
                            Navigator.pushNamedAndRemoveUntil(context, BeldexRoutes.welcome,
                                ModalRoute.withName(BeldexRoutes.dashboard));
                          else
                            await nodeSyncStore.sync();
                        },
                        direction: DismissDirection.endToStart,
                        background: Container(
                          padding: EdgeInsets.only(right: 10.0),
                          alignment: AlignmentDirectional.centerEnd,
                          color: BeldexPalette.red,
                          child: SvgPicture.asset('assets/images/delete.svg',color:Colors.white,width: 20,height: 20,),
                        ),
                        child: Card(
                            color: Theme.of(context).cardColor,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: content));
                  }))
        ],
      ),
    );
  }
}
