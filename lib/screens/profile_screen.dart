import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'add_family_member_sheet.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import 'membership_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;

  String? vediqId;
  bool loading = true;
  String fullName = "User";

  String bloodGroup = "Unknown";
  String weight = "0 kg";
  String height = "0 cm";
  String phone = "";

  List<Map<String, dynamic>> familyMembers = [];
  bool loadingFamily = true;

  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
    loadFamilyMembers();
  }

  String generateVediqId() => "VDQ-${DateTime.now().millisecondsSinceEpoch}";

  Future<void> loadProfile() async {
    setState(() => loading = true);

    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data != null) {
      String id = data['vediq_id'] ?? "";

      if (id.isEmpty) {
        id = generateVediqId();
        await supabase
            .from('profiles')
            .update({'vediq_id': id}).eq('id', user.id);
      }

      setState(() {
        fullName = data['full_name'] ?? "User";
        vediqId = id;
        phone = data['phone'] ?? "";
        bloodGroup = data['blood_group'] ?? "Unknown";
        weight = "${data['weight'] ?? "0"} kg";
        height = "${data['height'] ?? "0"} cm";
        loading = false;
      });
      return;
    }

    final newId = generateVediqId();

    await supabase.from('profiles').insert({
      'id': user.id,
      'full_name': user.email?.split('@')[0] ?? 'User',
      'email': user.email,
      'phone': '',
      'vediq_id': newId,
    });

    setState(() {
      vediqId = newId;
      loading = false;
    });
  }

  Future<void> loadFamilyMembers() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('family_links')
        .select('relation, profiles!family_links_member_id_fkey(id, full_name)')
        .eq('owner_id', user.id);

    setState(() {
      familyMembers = List<Map<String, dynamic>>.from(data);
      loadingFamily = false;
    });
  }

  Widget familySection() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          height: 90,
          child: loadingFamily
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...familyMembers.map((f) {
                      final profile = f['profiles'];
                      if (profile == null) return const SizedBox();

                      final name = profile['full_name'] ?? 'Member';
                      final letter =
                          name.isNotEmpty ? name[0].toUpperCase() : "U";

                      return familyAvatar(letter, name);
                    }),
                    addFamilyAvatar(),
                  ],
                ),
        ),
      );

  Widget familyAvatar(String letter, String name) => Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            CircleAvatar(child: Text(letter)),
            const SizedBox(height: 6),
            Text(name, overflow: TextOverflow.ellipsis),
          ],
        ),
      );

  Widget addFamilyAvatar() => Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => const AddFamilyMemberSheet(),
                ).then((_) => loadFamilyMembers());
              },
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF0F172A),
                child: Icon(Icons.add, color: Colors.white),
              ),
            ),
            const SizedBox(height: 6),
            Text(AppLocalizations.of(context)!.add,
                style: const TextStyle(fontSize: 11)),
          ],
        ),
      );

  Widget settingsGroup(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(children: children),
      );

  Widget sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget infoTile(IconData icon, String title, String value) =>
      ListTile(leading: Icon(icon), title: Text(title), subtitle: Text(value));

  Widget healthBox(String title, String value) => Expanded(
        child: Column(children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.profileTitle),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _profileCard(fullName),
                  const SizedBox(height: 16),

                  /// Membership
                  GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const MembershipSheet(mode: "buy"),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.activateMembership,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(t.upgradeMessage),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  sectionTitle(t.contactInfo),
                  settingsGroup([
                    infoTile(Icons.phone, t.mobileNumber,
                        phone.isEmpty ? t.notSet : phone),
                    infoTile(Icons.email, t.emailAddress,
                        supabase.auth.currentUser?.email ?? ""),
                  ]),

                  const SizedBox(height: 24),

                  sectionTitle(t.healthDetails),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(children: [
                      healthBox(t.bloodGroup, bloodGroup),
                      healthBox(t.weight, weight),
                      healthBox(t.height, height),
                    ]),
                  ),

                  const SizedBox(height: 24),

                  sectionTitle(t.familyManagement),
                  familySection(),

                  const SizedBox(height: 24),

                  settingsGroup([
                    ListTile(
                      title: Text(t.accountSecurity),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => context.push("/account-security"),
                    ),
                    ListTile(
                      title: Text(t.legalPrivacy),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => context.push("/legal"),
                    ),
                    ListTile(
                      title: Text(t.helpSupport),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => context.push("/support-center"),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  sectionTitle(t.dataManagement),

                  settingsGroup([
                    ListTile(
                      title: Text(t.clearCache),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => context.push("/clear-cache"),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  sectionTitle(t.appSettings),
                  settingsGroup([
                    ListTile(
                      title: Text(t.language),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => showLanguageSelector(context),
                    ),
                    ListTile(
                      title: Text(t.membershipPlan),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const MembershipSheet(mode: "manage"),
                      ),
                    ),
                    ListTile(
                      title: Text(t.notifications),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => context.push("/notifications"),
                    ),
                    ListTile(
                      title: Text(t.darkMode),
                      trailing: Switch(
                        value: isDarkMode,
                        onChanged: (value) {
                          setState(() => isDarkMode = value);
                          VediqLogApp.setThemeMode(
                            context,
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                      ),
                    ),
                  ]),

                  const SizedBox(height: 30),

                  logoutButton(),
                ],
              ),
            ),
    );
  }

  Widget _profileCard(String userName) {
    final t = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () async {
        await context.push('/edit-profile');
        loadProfile();
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Text(userName.isNotEmpty ? userName[0].toUpperCase() : "U"),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(userName.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(t.tapToEditProfile,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(vediqId ?? ''),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget logoutButton() {
    final t = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          await supabase.auth.signOut();
          if (mounted) context.go('/login');
        },
        icon: const Icon(Icons.logout, color: Colors.red),
        label: Text(t.logout, style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  void showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          languageOption(context, "English", const Locale('en')),
          languageOption(context, "తెలుగు", const Locale('te')),
          languageOption(context, "हिंदी", const Locale('hi')),
          languageOption(context, "தமிழ்", const Locale('ta')),
          languageOption(context, "ಕನ್ನಡ", const Locale('kn')),
        ],
      ),
    );
  }

  Widget languageOption(BuildContext context, String title, Locale locale) {
    return ListTile(
      title: Text(title),
      onTap: () {
        VediqLogApp.setLocale(context, locale);
        Navigator.pop(context);
      },
    );
  }
}
