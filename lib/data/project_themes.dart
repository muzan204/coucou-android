import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/project.dart';

class ProjectVisual {
  final String cover;
  final Color primary;
  final Color secondary;
  final Color accent;
  final IconData icon;
  final String category;

  const ProjectVisual({
    required this.cover,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.icon,
    required this.category,
  });
}

class ProjectThemes {
  static const Map<String, ProjectVisual> _items = {
    'coucou-android': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFF16E7FF),
      secondary: Color(0xFF9B6CFF),
      accent: Color(0xFF3BD88F),
      icon: Icons.smart_toy_rounded,
      category: 'Hub',
    ),
    'chatflow': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFF9B6CFF),
      secondary: Color(0xFF16E7FF),
      accent: Color(0xFFFF5FD2),
      icon: Icons.forum_rounded,
      category: 'IA',
    ),
    'os-noturnos': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFF9B6CFF),
      secondary: Color(0xFFFF627D),
      accent: Color(0xFF16E7FF),
      icon: Icons.nightlight_round,
      category: 'Bot',
    ),
    'site-aniversario': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1464349095431-e9a21285b5f3?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFFFF5FD2),
      secondary: Color(0xFFF7C451),
      accent: Color(0xFFFF627D),
      icon: Icons.cake_rounded,
      category: 'Site',
    ),
    'aurora-music': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFFFF5FD2),
      secondary: Color(0xFF9B6CFF),
      accent: Color(0xFF16E7FF),
      icon: Icons.music_note_rounded,
      category: 'Música',
    ),
    'orbita-neom': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFF16E7FF),
      secondary: Color(0xFF5B7CFA),
      accent: Color(0xFF9B6CFF),
      icon: Icons.rocket_launch_rounded,
      category: 'Space',
    ),
    'cyberquiz': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1510511459019-5dda7724fd87?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFF3BD88F),
      secondary: Color(0xFF16E7FF),
      accent: Color(0xFF9B6CFF),
      icon: Icons.security_rounded,
      category: 'Cyber',
    ),
    'cruzadinha-tech': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFF5B7CFA),
      secondary: Color(0xFF16E7FF),
      accent: Color(0xFF3BD88F),
      icon: Icons.extension_rounded,
      category: 'Educação',
    ),
    'klass-sistema-escolar': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1509062522246-3755977927d7?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFF5B7CFA),
      secondary: Color(0xFF3BD88F),
      accent: Color(0xFF16E7FF),
      icon: Icons.school_rounded,
      category: 'Escola',
    ),
    'ecotech': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1497436072909-f5e4be4f6e8d?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFF3BD88F),
      secondary: Color(0xFF16E7FF),
      accent: Color(0xFFF7C451),
      icon: Icons.eco_rounded,
      category: 'Eco',
    ),
    'carrinho': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFFF7C451),
      secondary: Color(0xFF5B7CFA),
      accent: Color(0xFF3BD88F),
      icon: Icons.shopping_cart_rounded,
      category: 'Loja',
    ),
    'techgear-cart': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1498049794561-7780e7231661?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFF16E7FF),
      secondary: Color(0xFF5B7CFA),
      accent: Color(0xFFF7C451),
      icon: Icons.devices_rounded,
      category: 'Tech',
    ),
    'mini-loja-netflix-react': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFFFF627D),
      secondary: Color(0xFF9B6CFF),
      accent: Color(0xFFF7C451),
      icon: Icons.movie_rounded,
      category: 'React',
    ),
    'projeto-portifolio-basc': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFF5B7CFA),
      secondary: Color(0xFF16E7FF),
      accent: Color(0xFF9B6CFF),
      icon: Icons.web_rounded,
      category: 'Portfólio',
    ),
    'login-fullstack': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFF9B6CFF),
      secondary: Color(0xFF5B7CFA),
      accent: Color(0xFF3BD88F),
      icon: Icons.lock_rounded,
      category: 'Full-stack',
    ),
    'framer-motion-demo': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1558655146-d09347e92766?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFFFF5FD2),
      secondary: Color(0xFF9B6CFF),
      accent: Color(0xFF16E7FF),
      icon: Icons.animation_rounded,
      category: 'Motion',
    ),
    'chatbot': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1531746790731-6c087fecd65a?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFF16E7FF),
      secondary: Color(0xFF3BD88F),
      accent: Color(0xFF9B6CFF),
      icon: Icons.psychology_rounded,
      category: 'IA',
    ),
    'rpg-de_programa-o': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFFFF627D),
      secondary: Color(0xFF9B6CFF),
      accent: Color(0xFFF7C451),
      icon: Icons.sports_esports_rounded,
      category: 'Game',
    ),
    'calculadora.basc': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1509228627152-72ae9ae6848d?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFF5B7CFA),
      secondary: Color(0xFF16E7FF),
      accent: Color(0xFFF7C451),
      icon: Icons.calculate_rounded,
      category: 'Utilitário',
    ),
    'ayumi': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFFFF5FD2),
      secondary: Color(0xFF5B7CFA),
      accent: Color(0xFF16E7FF),
      icon: Icons.auto_awesome_rounded,
      category: 'Projeto',
    ),
    'dotfiles': ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?auto=format&fit=crop&w=1400&q=88',
      primary: Color(0xFF3BD88F),
      secondary: Color(0xFF16E7FF),
      accent: Color(0xFF9B6CFF),
      icon: Icons.terminal_rounded,
      category: 'Dev',
    ),
  };

  static ProjectVisual of(ProjectRepo repo) {
    final name = repo.name.toLowerCase();

    for (final entry in _items.entries) {
      if (name.contains(entry.key)) return entry.value;
    }

    final language = repo.language.toLowerCase();

    if (language.contains('dart') || language.contains('flutter')) {
      return const ProjectVisual(
        cover: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=1400&q=88',
        primary: AppColors.cyan,
        secondary: AppColors.blue,
        accent: AppColors.violet,
        icon: Icons.flutter_dash_rounded,
        category: 'Flutter',
      );
    }

    if (language.contains('javascript') || language.contains('typescript')) {
      return const ProjectVisual(
        cover: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=1400&q=88',
        primary: AppColors.amber,
        secondary: AppColors.blue,
        accent: AppColors.cyan,
        icon: Icons.javascript_rounded,
        category: 'Web',
      );
    }

    if (language.contains('python')) {
      return const ProjectVisual(
        cover: 'https://images.unsplash.com/photo-1526379095098-d400fd0bf935?auto=format&fit=crop&w=1400&q=88',
        primary: AppColors.green,
        secondary: AppColors.blue,
        accent: AppColors.cyan,
        icon: Icons.code_rounded,
        category: 'Python',
      );
    }

    return const ProjectVisual(
      cover: 'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?auto=format&fit=crop&w=1400&q=88',
      primary: AppColors.cyan,
      secondary: AppColors.violet,
      accent: AppColors.green,
      icon: Icons.folder_rounded,
      category: 'Projeto',
    );
  }
}
