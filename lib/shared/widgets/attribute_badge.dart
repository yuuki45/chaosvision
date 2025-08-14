import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AttributeBadge extends StatelessWidget {
  final String attribute;
  final double size;

  const AttributeBadge({
    super.key,
    required this.attribute,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.attributeColors[attribute] ?? AppColors.primary;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.5,
        vertical: size * 0.25,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(size * 0.5),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getAttributeIcon(attribute, color),
          SizedBox(width: size * 0.2),
          Text(
            attribute,
            style: TextStyle(
              color: color,
              fontSize: size * 0.6,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAttributeIcon(String attribute, Color color) {
    // 特殊イベント属性は星アイコンを使用
    if (['時空', '封印', '虚無', '混沌'].contains(attribute)) {
      return Text(
        '🌟',
        style: TextStyle(
          fontSize: size * 0.7,
        ),
      );
    }
    
    IconData iconData;
    
    switch (attribute) {
      case '炎':
        iconData = Icons.local_fire_department;
        break;
      case '氷':
        iconData = Icons.ac_unit;
        break;
      case '雷':
        iconData = Icons.bolt;
        break;
      case '闇':
        iconData = Icons.nights_stay;
        break;
      case '光':
        iconData = Icons.wb_sunny;
        break;
      case '風':
        iconData = Icons.air;
        break;
      case '地':
        iconData = Icons.terrain;
        break;
      case '水':
        iconData = Icons.water_drop;
        break;
      case '無':
      default:
        iconData = Icons.circle_outlined;
        break;
    }
    
    return Icon(
      iconData,
      color: color,
      size: size * 0.7,
    );
  }
}