import 'package:flutter/material.dart';
import 'legal_texts.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalTextPage(
      title: 'Kullanım Koşulları',
      paragraphs: const [
        TextSpan(
          text:
              'Bu metin, Ortak Yol mobil uygulamasının demo/pilot sürümünü kullanan kişiler için örnek kullanım koşullarını içermektedir.\n\n',
        ),
        TextSpan(
          text: '1. Hizmetin Niteliği\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'Platform, bağımsız sürücüler ile yolcuları bir araya getiren dijital bir aracılık hizmeti sunar. '
              'Platform, taşımacılık sözleşmesinin doğrudan tarafı değildir; taşıma hizmeti sürücüler tarafından ifa edilir.\n\n',
        ),
        TextSpan(
          text: '2. Hesap Oluşturma ve Sorumluluk\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'Kullanıcı, kayıt sırasında doğru ve güncel bilgi vermeyi; hesabının güvenliğinden ve hesabı üzerinden yapılan işlemlerden '
              'sorumlu olduğunu kabul eder. Uygunsuz, hukuka aykırı veya yanıltıcı beyanlar hesabın kısıtlanmasına neden olabilir.\n\n',
        ),
        TextSpan(
          text: '3. Yasaklı Kullanımlar\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'Uygulama; mevzuata aykırı, hileli, üçüncü kişilerin haklarını ihlal eden veya güvenlik riski oluşturan amaçlarla kullanılamaz. '
              'Bu tür tespitlerde hesaplar kısıtlanabilir veya kapatılabilir.\n\n',
        ),
        TextSpan(
          text: '4. Sorumluluk Sınırları\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'Platform, makul teknik ve idari tedbirleri almakla birlikte; bağlantı sorunları, üçüncü taraf servis kesintileri, '
              'kullanıcıların kendi kusurundan kaynaklanan zararlar gibi hallerde sorumluluğunu sınırlar. '
              'Taşıma hizmeti, sürücü ile yolcu arasındaki sözleşme kapsamında yürütülür.\n\n',
        ),
        TextSpan(
          text: '5. Değişiklikler\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'Uygulama; özellikler, kapsam ve metinlerde değişiklik yapma hakkını saklı tutar. Değişiklikler, uygulama içi bildirimler veya güncellenen metinler üzerinden duyurulur.\n\n',
        ),
        TextSpan(
          text: '6. Uygulanacak Hukuk\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'İşbu demo metin, Türk hukuku çerçevesinde yorumlanır. Uygulamanın üretim ortamına taşınması halinde, '
              'güncel ve bağlayıcı kullanım koşulları ayrıca ilan edilecektir.\n\n',
        ),
        TextSpan(
          text: LegalTexts.tbkGeneralReference,
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

