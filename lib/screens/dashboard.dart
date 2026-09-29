import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../data/project_themes.dart';
import '../models/project.dart';
import '../services/github_service.dart';
import '../services/favorite_service.dart';
import '../services/termux_service.dart';
import '../services/update_service.dart';
import '../widgets/mascot.dart';
import '../widgets/project_cover.dart';
import 'project_detail.dart';

const coucouPort=8765;
class Dashboard extends StatefulWidget{const Dashboard({super.key});@override State<Dashboard> createState()=>_DashboardState();}
class _DashboardState extends State<Dashboard>{
  final github=GitHubService(),termux=TermuxService(),updater=UpdateService(),favoritesService=FavoriteService(); HttpServer? server; StreamSubscription? overlaySub;
  List<ProjectRepo> projects=[]; Set<String> favorites={}; bool loading=true,termuxOnline=false,overlayActive=false,hasToken=false,checkingUpdate=false,downloadingUpdate=false; double updateProgress=0; AppUpdate? appUpdate; String currentAppVersion=''; String latestAppVersion=''; String updateMessage='Toque para verificar'; String projectFilter='Todos'; int tab=0; String search=''; CoucouState state=CoucouState.idle;
  @override void initState(){super.initState();_init();}
  Future<void> _init() async{favorites=await favoritesService.load();overlaySub=FlutterOverlayWindow.overlayListener.listen((e){if(e is String){final s=stateFromString(e);if(s!=null&&mounted)setState(()=>state=s);}});await _startBridge();await _refresh();await _checkUpdate();}
  Future<void> _startBridge() async{server=await HttpServer.bind(InternetAddress.loopbackIPv4,coucouPort);server!.listen((q)async{q.response.headers.contentType=ContentType.json;if(q.uri.path=='/ping'){q.response.write(jsonEncode({'ok':true,'service':'coucou-android','port':coucouPort}));}else if(q.uri.path=='/state'){final s=stateFromString(q.uri.queryParameters['value']??'');if(s==null){q.response.statusCode=400;}else{await _setState(s);q.response.write(jsonEncode({'ok':true,'state':s.name}));}}else{q.response.statusCode=404;}await q.response.close();});}
  Future<void> _refresh() async{if(mounted)setState(()=>loading=true);try{final list=await github.loadProjects();final tok=await github.readToken();final tx=await termux.ping();final ov=await FlutterOverlayWindow.isActive();final fav=await favoritesService.load();if(mounted)setState((){projects=list;hasToken=tok!=null&&tok.isNotEmpty;termuxOnline=tx;overlayActive=ov;favorites=fav;loading=false;});}catch(e){if(mounted)setState(()=>loading=false);_msg(e.toString(),true);}}
  Future<void> _setState(CoucouState s)async{if(mounted)setState(()=>state=s);if(await FlutterOverlayWindow.isActive())await FlutterOverlayWindow.shareData(s.name);}
  Future<void> _checkUpdate()async{if(checkingUpdate)return;if(mounted)setState(()=>checkingUpdate=true);try{final status=await updater.checkDetailed();if(mounted)setState((){appUpdate=status.update;currentAppVersion=status.currentVersion;latestAppVersion=status.latestVersion;updateMessage=status.message;});if(mounted)_msg(status.message,false);}catch(e){if(mounted){setState(()=>updateMessage='Falha ao verificar atualização');_msg(e.toString(),true);}}finally{if(mounted)setState(()=>checkingUpdate=false);}}
  Future<void> _installUpdate()async{final u=appUpdate;if(u==null||downloadingUpdate)return;if(mounted)setState((){downloadingUpdate=true;updateProgress=0;});try{await updater.downloadAndInstall(u,onProgress:(v){if(mounted)setState(()=>updateProgress=v);});}catch(e){_msg(e.toString(),true);}finally{if(mounted)setState(()=>downloadingUpdate=false);}}
  Future<void> _toggleOverlay()async{if(overlayActive){await FlutterOverlayWindow.closeOverlay();}else{if(!await FlutterOverlayWindow.isPermissionGranted())await FlutterOverlayWindow.requestPermission();if(await FlutterOverlayWindow.isPermissionGranted()){await FlutterOverlayWindow.showOverlay(height:190,width:360,alignment:OverlayAlignment.topCenter,flag:OverlayFlag.defaultFlag,enableDrag:true,positionGravity:PositionGravity.auto,overlayTitle:'Coucou Projects Hub',overlayContent:'GitHub + Termux ativo',visibility:NotificationVisibility.visibilityPublic);await Future.delayed(const Duration(milliseconds:400));await FlutterOverlayWindow.shareData(state.name);}}await _refresh();}
  void _msg(String t,bool e)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(t),backgroundColor:e?AppColors.red:AppColors.surface));
  Future<void> _detail(ProjectRepo p)async{await Navigator.push(context,MaterialPageRoute(builder:(_)=>ProjectDetail(repo:p,github:github,termux:termux,termuxOnline:termuxOnline)));favorites=await favoritesService.load();if(mounted)setState((){});} Future<void> _toggleFavorite(ProjectRepo p)async{final next=await favoritesService.toggle(p.fullName);if(mounted)setState(()=>favorites=next);}
  Future<void> _open(String u)async{final x=Uri.tryParse(u);if(x!=null)await launchUrl(x,mode:LaunchMode.externalApplication);}
  List<ProjectRepo> get shown{
    final q=search.toLowerCase().trim();
    final list=projects.where((p){
      final matchesSearch=p.name.toLowerCase().contains(q)||p.description.toLowerCase().contains(q)||p.language.toLowerCase().contains(q);
      final matchesFilter=switch(projectFilter){
        'Favoritos'=>favorites.contains(p.fullName),
        'Sites'=>p.hasSite,
        'Privados'=>p.isPrivate,
        'Públicos'=>!p.isPrivate,
        _=>true,
      };
      return matchesSearch&&matchesFilter;
    }).toList();
    list.sort((a,b){
      final af=favorites.contains(a.fullName)?1:0;
      final bf=favorites.contains(b.fullName)?1:0;
      if(af!=bf)return bf.compareTo(af);
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  }
  @override Widget build(BuildContext context){return Scaffold(appBar:AppBar(title:const Text('Coucou Projects Hub',style:TextStyle(fontWeight:FontWeight.w900)),actions:[IconButton(onPressed:_refresh,icon:const Icon(Icons.refresh))]),body:IndexedStack(index:tab,children:[_home(),_projects(),_apks(),_sites(),_settings()]),bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),destinations:const [NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home),label:'Início'),NavigationDestination(icon:Icon(Icons.folder_outlined),selectedIcon:Icon(Icons.folder),label:'Projetos'),NavigationDestination(icon:Icon(Icons.android_outlined),selectedIcon:Icon(Icons.android),label:'APKs'),NavigationDestination(icon:Icon(Icons.public_outlined),selectedIcon:Icon(Icons.public),label:'Sites'),NavigationDestination(icon:Icon(Icons.settings_outlined),selectedIcon:Icon(Icons.settings),label:'Ajustes')]));}
  Widget _home()=>RefreshIndicator(onRefresh:_refresh,child:ListView(padding:const EdgeInsets.all(18),children:[ClipRRect(borderRadius:BorderRadius.circular(24),child:Image.asset('assets/brand/logo.jpg')),const SizedBox(height:16),Row(children:[MascotImage(state:state,size:86),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(state.label,style:TextStyle(fontSize:24,fontWeight:FontWeight.w900,color:state.color)),Text('${projects.length} projetos sincronizados',style:const TextStyle(color:AppColors.muted))]))]),const SizedBox(height:16),Row(children:[Expanded(child:_stat('GitHub',hasToken?'Público + privado':'Somente público',hasToken?AppColors.green:AppColors.amber)),const SizedBox(width:10),Expanded(child:_stat('Termux',termuxOnline?'Online':'Offline',termuxOnline?AppColors.green:AppColors.red))]),const SizedBox(height:10),_stat('Mascote',overlayActive?'Flutuando':'Desligado',overlayActive?AppColors.cyan:AppColors.muted),const SizedBox(height:12),if(appUpdate!=null)Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[const Icon(Icons.system_update_alt,color:AppColors.green),const SizedBox(width:8),Expanded(child:Text('Nova versão ${appUpdate!.version}',style:const TextStyle(fontWeight:FontWeight.w900,fontSize:16)))]),const SizedBox(height:6),Text(appUpdate!.notes,style:const TextStyle(color:AppColors.muted)),const SizedBox(height:10),if(downloadingUpdate)LinearProgressIndicator(value:updateProgress>0?updateProgress:null),if(downloadingUpdate)const SizedBox(height:8),FilledButton.icon(onPressed:downloadingUpdate?null:_installUpdate,icon:const Icon(Icons.download),label:Text(downloadingUpdate?'Baixando ${(updateProgress*100).toStringAsFixed(0)}%':'Atualizar agora'))]))),if(appUpdate!=null)const SizedBox(height:10),FilledButton.icon(onPressed:_toggleOverlay,icon:Icon(overlayActive?Icons.close:Icons.bubble_chart),label:Text(overlayActive?'Fechar mascote':'Mostrar mascote flutuante')),const SizedBox(height:22),Row(children:[const Expanded(child:Text('Destaques',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900))),if(favorites.isNotEmpty)Text('${favorites.length} favoritos',style:const TextStyle(color:AppColors.amber,fontWeight:FontWeight.w800))]),const SizedBox(height:8),...shown.take(6).map((p)=>Padding(padding:const EdgeInsets.only(bottom:10),child:GestureDetector(onTap:()=>_detail(p),child:SizedBox(height:150,child:ProjectCover(repo:p,favorite:favorites.contains(p.fullName),onFavorite:()=>_toggleFavorite(p),heroTag:'project-${p.id}')))))]));
  Widget _projects()=>Column(children:[
    Padding(padding:const EdgeInsets.fromLTRB(14,14,14,8),child:TextField(onChanged:(v)=>setState(()=>search=v),decoration:const InputDecoration(prefixIcon:Icon(Icons.search_rounded),hintText:'Buscar por nome, descrição ou linguagem...'))),
    SizedBox(height:46,child:ListView(scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:14),children:['Todos','Favoritos','Sites','Públicos','Privados'].map((f)=>Padding(padding:const EdgeInsets.only(right:8),child:FilterChip(label:Text(f),selected:projectFilter==f,onSelected:(_)=>setState(()=>projectFilter=f),selectedColor:AppColors.cyan.withValues(alpha:.16),checkmarkColor:AppColors.cyan,side:BorderSide(color:projectFilter==f?AppColors.cyan.withValues(alpha:.35):AppColors.line))).toList())),
    const SizedBox(height:8),
    Expanded(child:loading?const Center(child:CircularProgressIndicator()):LayoutBuilder(builder:(context,constraints){
      final width=constraints.maxWidth;
      final columns=width>=1000?4:width>=700?3:2;
      final ratio=columns==2?.74:.82;
      return RefreshIndicator(onRefresh:_refresh,child:GridView.builder(padding:const EdgeInsets.fromLTRB(14,0,14,28),gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:columns,childAspectRatio:ratio,crossAxisSpacing:12,mainAxisSpacing:12),itemCount:shown.length,itemBuilder:(_,i)=>_card(shown[i])));
    }))
  ]);
  Widget _card(ProjectRepo p){
    final visual=ProjectThemes.of(p);
    return InkWell(onTap:()=>_detail(p),borderRadius:BorderRadius.circular(22),child:Container(clipBehavior:Clip.antiAlias,decoration:BoxDecoration(color:AppColors.surface2,borderRadius:BorderRadius.circular(22),border:Border.all(color:visual.primary.withValues(alpha:.14)),boxShadow:[BoxShadow(color:visual.primary.withValues(alpha:.06),blurRadius:18,offset:const Offset(0,8))]),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Expanded(child:ProjectCover(repo:p,favorite:favorites.contains(p.fullName),onFavorite:()=>_toggleFavorite(p),heroTag:'project-${p.id}',borderRadius:const BorderRadius.only(topLeft:Radius.circular(22),topRight:Radius.circular(22)))),
      Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(p.description,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:11,color:AppColors.muted,height:1.35)),
        const SizedBox(height:8),
        Row(children:[Icon(visual.icon,size:13,color:visual.primary),const SizedBox(width:5),Expanded(child:Text(visual.category,style:TextStyle(fontSize:11,color:visual.primary,fontWeight:FontWeight.w800))),if(p.hasSite)const Icon(Icons.public_rounded,size:14,color:AppColors.green)])
      ]))
    ])));
  }
  Widget _apks()=>RefreshIndicator(onRefresh:_refresh,child:ListView(padding:const EdgeInsets.all(18),children:[const Text('APKs & Releases',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),const Text('APKs publicados em GitHub Releases.',style:TextStyle(color:AppColors.muted)),const SizedBox(height:14),...projects.map((p)=>FutureBuilder<ApkRelease?>(future:github.latestApk(p),builder:(_,s){if(s.connectionState==ConnectionState.waiting)return ListTile(title:Text(p.name),trailing:const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)));final a=s.data;if(a==null)return const SizedBox.shrink();return Card(child:ListTile(leading:const Icon(Icons.android,color:AppColors.green),title:Text(p.name),subtitle:Text('${a.tag} • ${a.name}'),trailing:IconButton(icon:const Icon(Icons.download),onPressed:()=>_open(a.downloadUrl))));}))]));
  Widget _sites()=>ListView(padding:const EdgeInsets.all(18),children:[const Text('Sites',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),const SizedBox(height:12),...projects.where((p)=>p.hasSite).map((p)=>Card(child:ListTile(onTap:()=>_open(p.homepage),leading:const Icon(Icons.public,color:AppColors.cyan),title:Text(p.name),subtitle:Text(p.homepage,maxLines:1,overflow:TextOverflow.ellipsis),trailing:const Icon(Icons.open_in_new))))]);
  Widget _settings()=>ListView(padding:const EdgeInsets.all(18),children:[const Text('Ajustes',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),const SizedBox(height:14),Card(child:ListTile(leading:const Icon(Icons.key,color:AppColors.violet),title:const Text('Projetos privados'),subtitle:Text(hasToken?'Token salvo com segurança':'Configure um Fine-grained PAT'),trailing:FilledButton.tonal(onPressed:_tokenDialog,child:Text(hasToken?'Alterar':'Configurar')))),const SizedBox(height:10),Card(child:ListTile(leading:Icon(Icons.terminal,color:termuxOnline?AppColors.green:AppColors.red),title:const Text('Agente Termux'),subtitle:Text(termuxOnline?'Online em 127.0.0.1:8766':'Rode: coucou-agent'))),const SizedBox(height:10),Card(child:ListTile(leading:const Icon(Icons.system_update_alt,color:AppColors.green),title:const Text('Atualizações automáticas'),subtitle:Text(currentAppVersion.isEmpty?updateMessage:'Instalada: $currentAppVersion • Disponível: ${latestAppVersion.isEmpty?'?':latestAppVersion}\n$updateMessage'),isThreeLine:true,trailing:checkingUpdate?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):IconButton(onPressed:_checkUpdate,icon:const Icon(Icons.refresh)))),const SizedBox(height:10),Card(child:ListTile(leading:const Icon(Icons.star,color:AppColors.amber),title:const Text('Favoritos'),subtitle:Text('${favorites.length} projeto(s) marcado(s)'))),const SizedBox(height:10),const Card(child:ListTile(leading:Icon(Icons.palette_rounded,color:AppColors.cyan),title:Text('Tema Coucou V4'),subtitle:Text('Base dark premium + identidade e cores próprias por projeto')))]);
  Future<void> _tokenDialog()async{final c=TextEditingController(text:await github.readToken()??'');if(!mounted)return;await showDialog(context:context,builder:(x)=>AlertDialog(title:const Text('GitHub Fine-grained PAT'),content:Column(mainAxisSize:MainAxisSize.min,children:[const Text('Crie um token com acesso apenas aos repositórios que quer mostrar. Ele fica no armazenamento seguro do Android.'),const SizedBox(height:10),TextField(controller:c,obscureText:true,decoration:const InputDecoration(labelText:'github_pat_...'))]),actions:[TextButton(onPressed:()=>Navigator.pop(x),child:const Text('Cancelar')),TextButton(onPressed:()async{await github.saveToken('');if(x.mounted)Navigator.pop(x);},child:const Text('Remover')),FilledButton(onPressed:()async{await github.saveToken(c.text);if(x.mounted)Navigator.pop(x);},child:const Text('Salvar'))]));await _refresh();}
  Widget _stat(String a,String b,Color c)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:AppColors.surface2,borderRadius:BorderRadius.circular(18),border:Border.all(color:c.withValues(alpha:.16))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(a,style:const TextStyle(color:AppColors.muted)),Text(b,style:TextStyle(fontWeight:FontWeight.w900,color:c))]));
  @override void dispose(){overlaySub?.cancel();FlutterOverlayWindow.disposeOverlayListener();server?.close(force:true);super.dispose();}
}
