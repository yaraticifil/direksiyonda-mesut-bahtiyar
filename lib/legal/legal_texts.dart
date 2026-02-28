import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan hukuki ve bilgilendirici metinler.
/// Metinleri burada toplamak, hem demo hem de üretim ortamında
/// dil / ton değişikliklerini merkezî olarak yönetmeyi kolaylaştırır.
class LegalTexts {
  // ─── SÜRÜCÜ TARAFI ───

  static const String driverSplashTitle = 'Direksiyon başında yalnız değilsin.';

  static const String driverSplashSubtitle =
      'Bu platform, bağımsız sürücülerin dijital ortamda hizmet sunabilmesi için tasarlanmıştır.\n'
      'Yolun açık, süreç şeffaf.';

  static const String driverRegisterInfo =
      'Bu platform, sürücülerin başvurularını dijital ortamda ön değerlendirmeye alır.\n'
      'Kimlik ve belge doğrulama süreçleri, yürürlükteki mevzuata uygun şekilde ve açık rıza çerçevesinde yürütülür.\n'
      'Kişisel verileriniz, yalnızca hizmet sunumu amacıyla işlenir.';

  static const String driverDashboardDisclaimer =
      'Bu platform, bağımsız sürücü ile yolcu arasında dijital aracılık hizmeti sunar.\n'
      'Platform, taşımacılık hizmetinin tarafı değildir.';

  static const String driverPenaltyIntro =
      'Bu alan, sürücülerin yaşadıkları idari işlemleri kayıt altına alabilmeleri için oluşturulmuştur.\n'
      'Platform, iletilen bilgileri saklar ve talep edilmesi halinde ilgili mercilerle paylaşabilir.\n'
      'Hukuki danışmanlık hizmeti platform tarafından doğrudan sunulmamaktadır.';

  static const String driverProcessSupportTitle = 'Süreç Desteği Paneli';

  static const String driverProcessSupportSubtitle =
      'Bu panel, sürücülerin yaşadıkları süreçleri kayıt altına almasına yardımcı olur.\n'
      'Hukuki değerlendirme, bağımsız uzmanlar tarafından yapılmalıdır.';

  // ─── YOLCU TARAFI ───

  static const String passengerFareDisclaimer =
      'Yolculuk fiyatı, mesafe ve süre tahminine göre hesaplanmıştır.\n'
      'Nihai ücret, yolculuk sonunda gerçekleşen mesafeye göre güncellenebilir.\n'
      'Platform, sürücü ile yolcu arasında dijital aracılık hizmeti sunar.';

  static const String passengerTrustMessage =
      'Platform üzerindeki sürücüler başvuru sürecinden geçirilir.\n'
      'Ancak taşımacılık hizmetinin doğrudan sorumluluğu sürücüye aittir.';

  static const String passengerCancellationPolicy =
      'Yolculuk, sürücü ataması öncesinde ücretsiz iptal edilebilir.\n'
      'Sürücü ataması sonrası iptallerde belirli bir hizmet bedeli uygulanabilir.';

  static const String passengerInvoiceInfo =
      'Bu ekran bilgilendirme amaçlıdır.\n'
      'Resmî mali belge düzenleme süreci, ilgili mevzuata uygun şekilde ayrıca yürütülür.';

  // ─── ADMIN TARAFI ───

  static const String adminLoginNotice =
      'Bu alan yalnızca yetkilendirilmiş kullanıcılar içindir.\n'
      'Tüm erişimler kayıt altındadır.';

  static const String adminDashboardNotice =
      'Bu panel, platform üzerindeki dijital süreçlerin yönetimi amacıyla oluşturulmuştur.\n'
      'Panel, taşımacılık faaliyetinin tarafı değildir.';

  // ─── KVKK / GİZLİLİK / KULLANIM ───

  static const String consentCheckboxText =
      'Kişisel verilerimin, hizmet sunumu amacıyla işlenmesini kabul ediyorum.\n'
      'Aydınlatma Metni ve Gizlilik Politikası’nı okudum ve onaylıyorum.';

  static const String tbkGeneralReference =
      'Hizmet ilişkileri, yürürlükteki Türk Borçlar Kanunu hükümlerine tabidir.';
}

/// Basit, kaydırılabilir metin sayfası şablonu.
class LegalTextPage extends StatelessWidget {
  final String title;
  final List<InlineSpan> paragraphs;

  const LegalTextPage({
    super.key,
    required this.title,
    required this.paragraphs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      height: 1.5,
                    ),
                children: paragraphs,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

