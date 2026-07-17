import 'package:flutter/material.dart';
import '../models/job_model.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const JobCard({super.key, required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          splashColor: const Color(0xFF6366F1).withOpacity(0.08),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF0F0F8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(),
                const SizedBox(width: 13),
                Expanded(child: _buildContent(context)),
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chevron_right_rounded,
                      size: 16, color: Color(0xFF6366F1)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initial = job.displayCompany.isNotEmpty
        ? job.displayCompany[0].toUpperCase()
        : '?';
    final gradient = _gradientSeed(job.displayCompany);
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          job.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          job.displayCompany,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 11),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            if (job.parsedLocation != null)
              _buildChip(Icons.location_on_outlined, job.parsedLocation!),
            _buildChip(Icons.event_outlined, job.postedDateFormatted),
            _buildChip(Icons.work_outline_rounded, job.experienceRange),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.08),
            const Color(0xFFEC4899).withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF6366F1)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF4B4B63),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _gradientSeed(String text) {
    const palette = [
      [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      [Color(0xFFEC4899), Color(0xFFF472B6)],
      [Color(0xFF14B8A6), Color(0xFF5EEAD4)],
      [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      [Color(0xFF3B82F6), Color(0xFF60A5FA)],
      [Color(0xFF8B5CF6), Color(0xFFC084FC)],
    ];
    final hash = text.codeUnits.fold(0, (a, b) => a + b);
    return palette[hash % palette.length];
  }
}