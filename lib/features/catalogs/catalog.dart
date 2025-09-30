import 'package:flutter/material.dart';
import '../../core/form_engine/models.dart';


/// Example catalog of forms and dashboard tiles. Edit here to add new flows.
final Map<String, FormConfig> formCatalog = {
  'contact_us': FormConfig(
    id: 'contact_us',
    title: 'Contact Us',
    description: 'Tell us how we can help.',
    fields: [
      FieldSpec(id: 'name', label: 'Full name', type: FieldType.text, validator: ValidatorSpec(required: true, minLength: 2)),
      FieldSpec(id: 'email', label: 'Email', type: FieldType.email, validator: ValidatorSpec(required: true)),
      FieldSpec(id: 'topic', label: 'Topic', type: FieldType.dropdown, options: ['Support', 'Billing', 'Feedback', 'Other'], validator: ValidatorSpec(required: true)),
      FieldSpec(id: 'message', label: 'Message', type: FieldType.multiline, validator: ValidatorSpec(required: true, minLength: 10)),
      FieldSpec(id: 'consent', label: 'I agree to be contacted', type: FieldType.checkbox, validator: ValidatorSpec(required: true)),
    ],
  ),
  'lead_capture': FormConfig(
    id: 'lead_capture',
    title: 'Lead Capture',
    description: 'Collect basic lead details for outreach.',
    fields: [
      FieldSpec(id: 'firstName', label: 'First name', type: FieldType.text, validator: ValidatorSpec(required: true)),
      FieldSpec(id: 'lastName', label: 'Last name', type: FieldType.text, validator: ValidatorSpec(required: true)),
      FieldSpec(id: 'phone', label: 'Phone', type: FieldType.phone, validator: ValidatorSpec(required: true)),
      FieldSpec(id: 'budget', label: 'Budget (USD)', type: FieldType.number, hint: 'e.g., 5000', validator: ValidatorSpec(min: 0)),
      FieldSpec(id: 'followUp', label: 'Request follow-up call', type: FieldType.switch_),
      FieldSpec(id: 'preferredDate', label: 'Preferred date', type: FieldType.date),
    ],
  ),
  'contact_request' : FormConfig(
    id: 'contact_request',
    title: 'Contact Request',
    description: 'Share your details and what you need. We will reach out.',
    fields: [
      FieldSpec(
        id: 'fullName',
        label: 'Full Name',
        type: FieldType.text,
        validator: ValidatorSpec(required: true, minLength: 2),
      ),
      FieldSpec(
        id: 'email',
        label: 'Email',
        type: FieldType.email,
        validator: ValidatorSpec(required: true),
      ),
      FieldSpec(
        id: 'phone',
        label: 'Phone (optional)',
        type: FieldType.phone,
        validator: const ValidatorSpec(required: false),
      ),
      FieldSpec(
        id: 'requirement',
        label: 'Tell us about your requirement',
        type: FieldType.multiline,
        validator: ValidatorSpec(required: true, minLength: 10),
      ),
    ],
  ),
  'spatial_booking' : FormConfig(
    id: 'spatial_booking',
    title: 'Book a Spatial.io Table',
    description: 'Tell us about your organization and preferred slot. We will contact you to facilitate the booking.',
    fields: [
      FieldSpec(
        id: 'orgName',
        label: 'Organization Name',
        type: FieldType.text,
        validator: ValidatorSpec(required: true, minLength: 2),
      ),
      FieldSpec(
        id: 'contactName',
        label: 'Contact Person',
        type: FieldType.text,
        validator: ValidatorSpec(required: true, minLength: 2),
      ),
      FieldSpec(
        id: 'email',
        label: 'Email',
        type: FieldType.email,
        validator: ValidatorSpec(required: true),
      ),
      FieldSpec(
        id: 'phone',
        label: 'Phone (optional)',
        type: FieldType.phone,
        validator: const ValidatorSpec(required: false),
      ),
      FieldSpec(
        id: 'preferredDate',
        label: 'Preferred Date',
        type: FieldType.date,
        validator: const ValidatorSpec(required: true),
      ),
      FieldSpec(
        id: 'timeSlot',
        label: 'Preferred Time Slot',
        type: FieldType.dropdown,
        options: ['Morning', 'Afternoon', 'Evening'],
        validator: const ValidatorSpec(required: true),
      ),
      FieldSpec(
        id: 'boothSize',
        label: 'Booth Size',
        type: FieldType.dropdown,
        options: ['Small', 'Medium', 'Large'],
        validator: const ValidatorSpec(required: true),
      ),
      FieldSpec(
        id: 'links',
        label: 'Website / Social links (optional)',
        type: FieldType.multiline,
        validator: const ValidatorSpec(required: false),
      ),
      FieldSpec(
        id: 'notes',
        label: 'Additional notes',
        type: FieldType.multiline,
        validator: const ValidatorSpec(required: false),
      ),
    ],
  ),
  'magazine_ad_request' : FormConfig(
    id: 'magazine_ad_request',
    title: 'Regen Global Magazine – Ad Request',
    description: 'Tell us about your ad. We’ll contact you to finalize details.',
    fields: [
      FieldSpec(
        id: 'orgName',
        label: 'Organization Name',
        type: FieldType.text,
        validator: ValidatorSpec(required: true, minLength: 2),
      ),
      FieldSpec(
        id: 'contactName',
        label: 'Contact Person',
        type: FieldType.text,
        validator: ValidatorSpec(required: true, minLength: 2),
      ),
      FieldSpec(
        id: 'email',
        label: 'Email',
        type: FieldType.email,
        validator: ValidatorSpec(required: true),
      ),
      FieldSpec(
        id: 'phone',
        label: 'Phone (optional)',
        type: FieldType.phone,
        validator: ValidatorSpec(required: false),
      ),
      FieldSpec(
        id: 'preferredIssue',
        label: 'Preferred Issue / Month',
        type: FieldType.text, // keep text to avoid date-encoding complexity
        validator: ValidatorSpec(required: false),
      ),
      FieldSpec(
        id: 'adSize',
        label: 'Ad Size',
        type: FieldType.dropdown,
        options: ['Quarter Page', 'Half Page', 'Full Page'],
        validator: ValidatorSpec(required: true),
      ),
      FieldSpec(
        id: 'placement',
        label: 'Preferred Placement',
        type: FieldType.dropdown,
        options: ['Front Section', 'Middle Section', 'Back Section', 'No preference'],
        validator: ValidatorSpec(required: true),
      ),
      FieldSpec(
        id: 'budget',
        label: 'Estimated Budget (USD)',
        type: FieldType.number,
        validator: ValidatorSpec(required: false),
      ),
      FieldSpec(
        id: 'notes',
        label: 'Additional Notes',
        type: FieldType.multiline,
        validator: ValidatorSpec(required: false),
      ),
    ],
  )
};


final List<LinkSpec> dashboardLinks = [
  LinkSpec(
    id: 'latest_regen_global_magazine',
    title: 'Regen Global Magazine',
    subtitle: 'Latest edition',
    icon: Icons.book, // or Icons.language, Icons.public
    destinationType: DestinationType.external,
    url: 'https://drive.google.com/file/d/1_90k_jjtSdSHLEoA2CeNKAuZFx4LnMDD/view', // TODO: replace with real link
  ),
  LinkSpec(
    id: 'tile_consultants',
    title: 'Consultants',
    subtitle: 'Business · Environment · Health',
    icon: Icons.people_outline,
    destinationType: DestinationType.list,
    listId: 'consultants',
  ),
  LinkSpec(
    id: 'tile_contractors',
    title: 'Contractors',
    subtitle: 'Environment · Health',
    icon: Icons.handyman_outlined,
    destinationType: DestinationType.list,
    listId: 'contractors',
  ),
  LinkSpec(
    id: 'tile_social',
    title: 'Our Social Media Channels',
    subtitle: 'Follow us online',
    icon: Icons.public_outlined,
    destinationType: DestinationType.list,
    listId: 'social_channels',
  ),
  LinkSpec(
    id: 'tile_products',
    title: 'Products',
    subtitle: 'Harm Free Emporium · Health',
    icon: Icons.shopping_bag_outlined,
    destinationType: DestinationType.list,
    listId: 'products',
  ),
  LinkSpec(
    id: 'tile_initiatives',
    title: 'Initiatives',
    subtitle: 'Build Back Green · Sustainability · ARC',
    icon: Icons.auto_awesome_outlined, // pick any icon you like
    destinationType: DestinationType.list,
    listId: 'initiatives',
  ),
  LinkSpec(
    id: 'tile_programs',
    title: 'Programs',
    subtitle: 'Program 1 · Program 2 · Program 3',
    icon: Icons.school_outlined, // pick any Material icon you prefer
    destinationType: DestinationType.list,
    listId: 'programs',
  ),
  LinkSpec(
    id: 'tile_events',
    title: 'Events',
    subtitle: 'Event 1 · Event 2 · Event 3',
    icon: Icons.event_outlined, // good match for events
    destinationType: DestinationType.list,
    listId: 'events',
  ),
  LinkSpec(
    id: 'tile_international_community_alliances',
    title: 'International Community Alliances',
    subtitle: 'Learn more',
    icon: Icons.public_outlined, // or Icons.language, Icons.public
    destinationType: DestinationType.external,
    url: 'https://www.earthstockfoundation.org/documents/ARC.pdf', // TODO: replace with real link
  ),
  LinkSpec(
    id: 'spatial_world_link',
    title: 'Join Our Spatial.io World',
    subtitle: 'Our virtual community',
    icon: Icons.book, // or Icons.language, Icons.public
    destinationType: DestinationType.external,
    url: 'https://www.spatial.io/s/Earthstock-2024-66b66a85e2c982f2df947c76', // TODO: replace with real link
  ),

];

// Reusable lists that open a form after selection
final Map<String, ItemListConfig> listCatalog = {
  'consultants' : ItemListConfig(
    id: 'consultants',
    title: 'Consultants',
    description: 'Choose an area to proceed.',
    targetFormId: 'contact_request',
    items: const [
      ListItemSpec(
        id: 'business',
        title: 'Business',
        prefill: {'segment': 'Consultants', 'domain': 'Business'},
      ),
      ListItemSpec(
        id: 'environment',
        title: 'Environment',
        prefill: {'segment': 'Consultants', 'domain': 'Environment'},
      ),
      ListItemSpec(
        id: 'health',
        title: 'Health',
        prefill: {'segment': 'Consultants', 'domain': 'Health'},
      ),
    ],
  ),
  'contractors' : ItemListConfig(
    id: 'contractors',
    title: 'Contractors',
    description: 'Choose an area to proceed.',
    targetFormId: 'contact_request',
    items: const [
      ListItemSpec(
        id: 'environment',
        title: 'Environment',
        prefill: {'segment': 'Contractors', 'domain': 'Environment'},
      ),
      ListItemSpec(
        id: 'health',
        title: 'Health',
        prefill: {'segment': 'Contractors', 'domain': 'Health'},
      ),
    ],
  ),
  'social_channels': ItemListConfig(
    id: 'social_channels',
    title: 'Our Social Media Channels',
    description: 'Stay connected with us on social media.',
    targetFormId: null, // no form
    items: const [
      ListItemSpec(
        id: 'youtube',
        title: 'YouTube',
        linkUrl: 'https://www.youtube.com/@RegenMediaTv',
      ),
      ListItemSpec(
        id: 'vimeo',
        title: 'Vimeo',
        linkUrl: 'https://vimeo.com/user207149725',
      ),ListItemSpec(
        id: 'whatsApp',
        title: 'WhatsApp',
        linkUrl: 'https://chat.whatsapp.com/BU5a765wYp4KurToTJRAEQ',
      ),ListItemSpec(
        id: 'signal',
        title: 'Signal',
        linkUrl: 'https://signal.group/#CjQKINxZt4H7Y4dtc-70mgM3d0FiJpBoxhEfSLO1VBZusmy6EhBsqagsMDqhZRG-F4eP7kq5',
      ),ListItemSpec(
        id: 'telegram',
        title: 'Telegram',
        linkUrl: 'https://t.me/+73ilYbPKq49iZTJh',
      ),
      ListItemSpec(
        id: 'instagram',
        title: 'Facebook',
        linkUrl: 'https://m.me/j/Abbsm8gFA5wGKkDd/',
      )
      // Add more channels if you like
    ],
  ),
  'products' : ItemListConfig(
    id: 'products',
    title: 'Products',
    description: 'Explore our products and resources.',
    targetFormId: null, // links-only list
    items: const [
      ListItemSpec(
        id: 'harm_free_emporium',
        title: 'Harm Free Emporium',
        linkUrl: 'https://www.regenerationglobal.net/harmFreeEmporium.html', // TODO: replace later
      ),
      ListItemSpec(
        id: 'health',
        title: 'Health',
        linkUrl: 'https://example.com/health', // TODO: replace later
      ),
    ],
  ),
  'initiatives' : ItemListConfig(
    id: 'initiatives',
    title: 'Initiatives',
    description: 'Learn about our programs and movements.',
    targetFormId: null, // links-only list
    items: const [
      ListItemSpec(
        id: 'build_back_green',
        title: 'Build Back Green',
        linkUrl: 'https://www.regenerationglobal.net/buildBackGreen.html',
      ),
      ListItemSpec(
        id: 'transition_to_sustainability',
        title: 'Transition to Sustainability',
        linkUrl: 'https://www.regenerationglobal.net/fullSpectrumTransition.html',
      ),
      ListItemSpec(
        id: 'regen_responders',
        title: 'Regen Responders',
        linkUrl: 'https://example.com/regen-responders',
      ),
      ListItemSpec(
        id: 'arc',
        title: 'Academy for Regenerative Culture',
        linkUrl: 'https://example.com/academy-for-regenerative-culture',
      ),
    ],
  ),
  'programs' : ItemListConfig(
    id: 'programs',
    title: 'Programs',
    description: 'Explore our current programs.',
    targetFormId: null,
    items: const [
      ListItemSpec(
        id: 'program_1',
        title: 'Program 1',
        linkUrl: 'https://example.com/program-1',
      ),
      ListItemSpec(
        id: 'program_2',
        title: 'Program 2',
        linkUrl: 'https://example.com/program-2',
      ),
      ListItemSpec(
        id: 'program_3',
        title: 'Program 3',
        linkUrl: 'https://example.com/program-3',
      ),
    ],
  ),
  'events' : ItemListConfig(
    id: 'events',
    title: 'Events',
    description: 'Stay updated with our upcoming and past events.',
    targetFormId: null,
    items: const [
      ListItemSpec(
        id: 'event_1',
        title: 'Earthstock Festival',
        linkUrl: 'https://www.earthstockfestival.com/',
      )
    ],
  )
};