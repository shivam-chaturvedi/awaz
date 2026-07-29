import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _privacyPolicyUri =
    Uri.parse('https://www.termsfeed.com/live/58fa3786-15f9-4568-91ec-5c241d88198f');

class LegalSection {
  final String title;
  final List<String> paragraphs;
  final List<String>? bulletPoints;

  const LegalSection({
    required this.title,
    this.paragraphs = const [],
    this.bulletPoints,
  });
}

class LegalDocument {
  final String title;
  final String? description;
  final List<LegalSection> sections;

  const LegalDocument({
    required this.title,
    this.description,
    this.sections = const [],
  });
}

class LegalInfoScreen extends StatelessWidget {
  final LegalDocument document;
  final Widget? footer;

  const LegalInfoScreen({super.key, required this.document, this.footer});

  Widget _buildTableOfContents(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translate('legal.table_of_contents'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          document.sections.length,
          (index) {
            final section = document.sections[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${index + 1}. ${section.title}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, LegalSection section, int index) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${index + 1}. ${section.title}',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        ...section.paragraphs.map((paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                paragraph,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
            )),
        if (section.bulletPoints != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: section.bulletPoints!.map((point) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 20)),
                      Expanded(
                        child: Text(
                          point,
                          style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(document.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            _buildTableOfContents(context),
            const SizedBox(height: 16),
            if (document.description != null) ...[
              Text(
                document.description!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
            ],
            ...List.generate(
              document.sections.length,
              (index) => _buildSection(
                context,
                document.sections[index],
                index,
              ),
            ),
            if (footer != null) ...[
              const SizedBox(height: 16),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  LegalDocument _buildDocument() {
    return LegalDocument(
      title: translate('legal.privacy_policy_title'),
      description: translate('legal.privacy_policy_description'),
      sections: const [
        LegalSection(
          title: 'What information do we collect?',
          paragraphs: [
            'We collect what you voluntarily provide when setting up the app, such as your name, preferences, caregiver notes, and custom vocabulary. Images uploaded to represent words or phrases are stored locally and used solely to enhance communication.',
          ],
          bulletPoints: [
            'Voice and text phrases you type or add to the grid.',
            'Manually assigned images/icons that help you express words.',
            'Configuration choices (grid layout, language, theme, frozen rows).',
          ],
        ),
        LegalSection(
          title: 'How do we process your information?',
          paragraphs: [
            'All processing happens on your device. We use the selected settings to render vocabulary, generate speech, and keep track of usage analytics without sending data outside of the app.',
          ],
        ),
        LegalSection(
          title: 'When and with whom do we share your information?',
          paragraphs: [
            'We do not share personal data with third-party advertisers or analytics vendors. Data is only shared when you export it yourself via backup files, and caregiver devices can import that backup if you authorize it.',
          ],
        ),
        LegalSection(
          title: 'Do we use cookies or tracking?',
          paragraphs: [
            'No cookies or tracking technologies are used. We prioritize an offline-first experience to maintain privacy and reliability.',
          ],
        ),
        LegalSection(
          title: 'Do we use social logins?',
          paragraphs: [
            'We do not integrate with social login providers. All accounts and vocabulary are managed locally so caregivers and users retain control.',
          ],
        ),
        LegalSection(
          title: 'Is your information transferred internationally?',
          paragraphs: [
            'Since everything stays on your device by default, we do not transmit data across borders. If you back up data to a cloud service of your choice, those services may store information abroad, so review their policies.',
          ],
        ),
        LegalSection(
          title: 'How long do we keep your information?',
          paragraphs: [
            'Data remains until you delete it. Backup exports that you save externally stay as long as you keep the file, and you can remove them at any time.',
          ],
        ),
        LegalSection(
          title: 'Do we collect information from minors?',
          paragraphs: [
            'The app is designed for users of all ages, including minors. Caregivers control which vocabulary and images are available, and no parental consent is required because the app never shares data externally.',
          ],
        ),
        LegalSection(
          title: 'What are your privacy rights?',
          paragraphs: [
            'You can review or export vocabulary and settings at will. You can also disable features like auto speak or frozen rows whenever you choose.',
          ],
        ),
        LegalSection(
          title: 'Do-not-track controls',
          paragraphs: [
            'Because we do not use tracking services, there are no additional do-not-track controls needed beyond the accessible settings already provided.',
          ],
        ),
        LegalSection(
          title: 'Do we make updates to this notice?',
          paragraphs: [
            'When this policy changes, we will post the new notice within the app and describe what changed at the top of this screen.',
          ],
        ),
        LegalSection(
          title: 'How can you contact us?',
          paragraphs: [
            'Send privacy, content, or feedback questions to dinoishan4@gmail.com. We aim to respond within two business days.',
          ],
        ),
        LegalSection(
          title: 'How can you review, update, or delete your data?',
          paragraphs: [
            'Review vocabulary via the custom vocabulary screen, update settings through this settings tab, and delete data by using the reset option in settings or removing exported files from your storage.',
          ],
        ),
      ],
    );
  }

  Future<void> _openPrivacyPolicyUrl(BuildContext context) async {
    final launched = await launchUrl(
      _privacyPolicyUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open privacy policy')),
      );
    }
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.open_in_new_rounded),
          label: const Text('View Privacy Policy'),
          onPressed: () => _openPrivacyPolicyUrl(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LegalInfoScreen(
      document: _buildDocument(),
      footer: _buildFooter(context),
    );
  }
}

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});
  LegalDocument _buildDocument() {
    return LegalDocument(
      title: translate('legal.terms_of_service_title'),
      description: translate('legal.terms_of_service_description'),
      sections: const [
        LegalSection(
          title: 'Scope of the agreement',
          paragraphs: [
            'These terms govern how you may use Chinnam AAC. Installing or opening the app confirms that you accept them and will follow the accessibility-focused experience outlined here.',
          ],
        ),
        LegalSection(
          title: 'User responsibilities',
          paragraphs: [
            'Use the app in a respectful manner. Do not upload images or text that violates copyright, the rights of others, or community standards.',
          ],
        ),
        LegalSection(
          title: 'Content and images',
          paragraphs: [
            'You control the vocabulary, phrases, and images assigned to words. Keep icon references accurate and remove or replace content when it becomes outdated.',
          ],
        ),
        LegalSection(
          title: 'Caregiver and therapist contributions',
          paragraphs: [
            'Caregivers may add vocabulary, usage notes, and backups. They must ensure any data shared with clients is done so with consent.',
          ],
        ),
        LegalSection(
          title: 'App access and availability',
          paragraphs: [
            'We strive to keep the app available. However, service interruptions can occur during maintenance or updates, and we do not guarantee uninterrupted access.',
          ],
        ),
        LegalSection(
          title: 'Updates and maintenance',
          paragraphs: [
            'We will notify you about significant changes through app updates or in-app prompts. Installing the latest version ensures improvement and security patches are applied.',
          ],
        ),
        LegalSection(
          title: 'Limitation of liability',
          paragraphs: [
            'While we work to provide reliable communication, Chinnam AAC is provided “as is.” We are not liable for indirect losses or data recovery costs beyond reasonable compensation.',
          ],
        ),
        LegalSection(
          title: 'Governing law and dispute resolution',
          paragraphs: [
            'Any disputes are governed by the laws of the primary jurisdiction where the caregiver or user normally accesses the app.',
          ],
        ),
        LegalSection(
          title: 'Contact and feedback',
          paragraphs: [
            'We welcome content or feedback questions at dinoishan4@gmail.com, and your input helps us improve future releases.',
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LegalInfoScreen(document: _buildDocument());
  }
}
