import 'package:flutter/material.dart';

class HydrantFields extends StatelessWidget {
  final String? tekananAirTerpilih;
  final String? katupTerpilih;
  final String? selangHydrantTerpilih;
  final Color accentColor;
  final Color accentSoft;
  final void Function(String) onTekananAirChanged;
  final void Function(String) onKatupChanged;
  final void Function(String) onSelangHydrantChanged;

  const HydrantFields({
    Key? key,
    required this.tekananAirTerpilih,
    required this.katupTerpilih,
    required this.selangHydrantTerpilih,
    required this.accentColor,
    required this.accentSoft,
    required this.onTekananAirChanged,
    required this.onKatupChanged,
    required this.onSelangHydrantChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CompactOptionGroup(
            title: 'Tekanan Air',
            options: const ['Good', 'Low', 'No Pressure'],
            selectedValue: tekananAirTerpilih,
            accentColor: accentColor,
            onChanged: onTekananAirChanged,
          ),
          _CompactOptionGroup(
            title: 'Katup',
            options: const ['Good', 'Bocor', 'Macet'],
            selectedValue: katupTerpilih,
            accentColor: accentColor,
            onChanged: onKatupChanged,
          ),
          _CompactOptionGroup(
            title: 'Selang Hydrant',
            options: const ['Good', 'Bad', 'Crack'],
            selectedValue: selangHydrantTerpilih,
            accentColor: accentColor,
            onChanged: onSelangHydrantChanged,
          ),
        ],
      ),
    );
  }
}

class _CompactOptionGroup extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selectedValue;
  final Color accentColor;
  final void Function(String) onChanged;

  const _CompactOptionGroup({
    Key? key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.accentColor,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map((option) => _ChoiceChip(
                      label: option,
                      isSelected: selectedValue == option,
                      accentColor: accentColor,
                      onTap: () => onChanged(option),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _ChoiceChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? accentColor : const Color(0xFFE2E8F0),
            width: 1.4,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}
