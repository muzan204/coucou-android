import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../models/project.dart';
import '../services/github_service.dart';
import '../services/favorite_service.dart';
import '../services/termux_service.dart';
import '../widgets/project_cover.dart';

class ProjectDetail extends StatefulWidget {
  final ProjectRepo repo;
  final GitHubService github;
  final TermuxService termux;
  final bool termuxOnline;
  const ProjectDetail({super.key, required this.repo, required this.github, required this.termux, required this.termuxOnline});
  @override State<ProjectDetail> createState() => _ProjectDetailState();
}

class _ProjectDetailState extends State<ProjectDetail> {
  final favoritesService = FavoriteService();
  bool loading = true, installed = false, dirty = false, favorite = false;
  String branch = '';
  ApkRelease? apk;
  @override void initState(){super.initState(); _load();}
  Future<void> _load() async {
    branch = widget.repo.branch;
    final favorites = await favoritesService.load();
    favorite = favorites.contains(widget.repo.fullName);
    if(widget.termuxOnline){
      try { final s=await widget.termux.status(widget.repo); installed=s['installed']==true; dirty=s['dirty']==true; branch=s['branch']?.toString()??branch; } catch(_){}
    }
    apk=await widget.github.latestApk(widget.repo);
    if(mounted)setState(()=>loading=false);
  }
  Future<void> _toggleFavorite() async { final next=await favoritesService.toggle(widget.repo.fullName); if(mounted)setState(()=>favorite=next.contains(widget.repo.fullName)); }
  Future<void> _open(String url) async { final u=Uri.tryParse(url); if(u!=null) await launchUrl(u,mode:LaunchMode.externalApplication); }
  Future<void> _sync() async {
    if(!widget.termuxOnline){_msg('No Termux rode: coucou-agent',true);return;}
    try { final r=installed?await widget.termux.pull(widget.repo):await widget.termux.clone(widget.repo); _msg(r['message']?.toString()??'Concluído', false); await _load(); }
    catch(e){_msg(e.toString(),true);}
  }
  void _msg(String t,bool err)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(t),backgroundColor:err?AppColors.red:AppColors.surface));
  @override Widget build(BuildContext context){
    final r=widget.repo;
    return Scaffold(appBar:AppBar(title:Text(r.name),actions:[IconButton(onPressed:_toggleFavorite,icon:Icon(favorite?Icons.star:Icons.star_border,color:favorite?AppColors.amber:null))]),body:loading?const Center(child:CircularProgressIndicator()):ListView(padding:const EdgeInsets.all(18),children:[
      AspectRatio(aspectRatio:16/9,child:ProjectCover(repo:r,favorite:favorite,onFavorite:_toggleFavorite,heroTag:'project-${r.id}',borderRadius:BorderRadius.circular(24))),
      const SizedBox(height:16),
      Row(children:[Expanded(child:Text(r.name,style:const TextStyle(fontSize:28,fontWeight:FontWeight.w900))),if(r.isPrivate)const Icon(Icons.lock,color:AppColors.violet)]),
      const SizedBox(height:6),Text(r.description,style:const TextStyle(color:AppColors.muted,height:1.45)),const SizedBox(height:14),
      Wrap(spacing:8,runSpacing:8,children:[_pill(r.language,AppColors.cyan),_pill(r.visibility,r.isPrivate?AppColors.violet:AppColors.green),_pill('branch $branch',AppColors.muted),if(r.hasSite)_pill('site online',AppColors.green),if(favorite)_pill('favorito',AppColors.amber),if(installed)_pill(dirty?'alterações locais':'baixado',dirty?AppColors.amber:AppColors.green)]),
      const SizedBox(height:20),
      _btn(Icons.code,'Abrir GitHub',()=>_open(r.htmlUrl)),
      if(r.hasSite)_btn(Icons.public,'Abrir site',()=>_open(r.homepage)),
      _btn(installed?Icons.sync:Icons.download,installed?'Atualizar no Termux':'Baixar no Termux',_sync),
      if(apk!=null)_btn(Icons.android,'Baixar APK ${apk!.tag}',()=>_open(apk!.downloadUrl)),
      if(apk==null)const Padding(padding:EdgeInsets.all(10),child:Text('Sem APK publicado em GitHub Releases.',style:TextStyle(color:AppColors.muted))),
    ]));
  }
  Widget _pill(String t,Color c)=>Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),decoration:BoxDecoration(color:c.withValues(alpha:.12),borderRadius:BorderRadius.circular(99)),child:Text(t,style:TextStyle(color:c,fontWeight:FontWeight.w800,fontSize:12)));
  Widget _btn(IconData i,String t,VoidCallback f)=>Padding(padding:const EdgeInsets.only(bottom:9),child:FilledButton.tonalIcon(onPressed:f,icon:Icon(i),label:Align(alignment:Alignment.centerLeft,child:Text(t))));
}
