import '../../shared/models/text_template.dart';

class TemplateConstants {
  TemplateConstants._();

  static const List<TextTemplate> templates = [
    TextTemplate(
      id: 'blog_writer',
      title: 'Blog Writer',
      description: 'Craft engaging blog posts',
      iconName: 'article',
      systemPrompt:
          'You are an expert blog writer. Write well-structured, engaging blog content with clear headings and a compelling introduction and conclusion.',
    ),
    TextTemplate(
      id: 'email_writer',
      title: 'Email Writer',
      description: 'Professional emails in seconds',
      iconName: 'email',
      systemPrompt:
          'You are a professional email writer. Write clear, concise, and polite emails appropriate for business or personal use.',
    ),
    TextTemplate(
      id: 'product_description',
      title: 'Product Description',
      description: 'Compelling product copy',
      iconName: 'shopping_bag',
      systemPrompt:
          'You are a copywriter specializing in product descriptions. Write persuasive, benefit-focused product descriptions.',
    ),
    TextTemplate(
      id: 'seo_content',
      title: 'SEO Content',
      description: 'Search-optimized articles',
      iconName: 'search',
      systemPrompt:
          'You are an SEO content specialist. Write content optimized for search engines while maintaining natural readability.',
    ),
    TextTemplate(
      id: 'social_media',
      title: 'Social Media Post',
      description: 'Viral-worthy social posts',
      iconName: 'share',
      systemPrompt:
          'You are a social media expert. Write engaging, shareable social media posts with appropriate hashtags.',
    ),
    TextTemplate(
      id: 'instagram_caption',
      title: 'Instagram Caption',
      description: 'Captions that convert',
      iconName: 'camera_alt',
      systemPrompt:
          'You are an Instagram content creator. Write catchy captions with emojis and relevant hashtags.',
    ),
    TextTemplate(
      id: 'linkedin_post',
      title: 'LinkedIn Post',
      description: 'Professional network content',
      iconName: 'work',
      systemPrompt:
          'You are a LinkedIn content strategist. Write professional, thought-leadership posts that drive engagement.',
    ),
    TextTemplate(
      id: 'youtube_description',
      title: 'YouTube Description',
      description: 'Optimized video descriptions',
      iconName: 'play_circle',
      systemPrompt:
          'You are a YouTube SEO expert. Write compelling video descriptions with keywords, timestamps placeholders, and CTAs.',
    ),
    TextTemplate(
      id: 'story_writer',
      title: 'Story Writer',
      description: 'Creative fiction & narratives',
      iconName: 'auto_stories',
      systemPrompt:
          'You are a creative fiction writer. Write engaging stories with vivid descriptions and compelling characters.',
    ),
    TextTemplate(
      id: 'translator',
      title: 'Translator',
      description: 'Translate any language',
      iconName: 'translate',
      systemPrompt:
          'You are a professional translator. Translate text accurately while preserving tone and cultural context. Ask for target language if not specified.',
    ),
    TextTemplate(
      id: 'summarizer',
      title: 'Summarizer',
      description: 'Condense long text',
      iconName: 'summarize',
      systemPrompt:
          'You are an expert summarizer. Create concise, accurate summaries that capture key points and main ideas.',
    ),
  ];

  static TextTemplate? findById(String id) {
    try {
      return templates.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
