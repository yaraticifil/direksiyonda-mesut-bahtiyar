import 'package:flutter/material.dart';
import 'legal_texts.dart';

class ClarificationPage extends StatelessWidget {
  const ClarificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalTextPage(
      title: 'Aydınlatma Metni',
      paragraphs: const [
        TextSpan(
          text:
              'Bu aydınlatma metni, Ortak Yol platformu kapsamında işlenen kişisel veriler hakkında kullanıcıları bilgilendirmek amacıyla hazırlanmıştır.\n\n',
        ),
        TextSpan(
          text: 'Veri Sorumlusu ve İletişim\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'Uygulamanın geliştiricisi/işleticisi, ilgili mevzuat çerçevesinde veri sorumlusu sıfatıyla hareket eder. '
              'İleride belirli bir tüzel kişilik adına faaliyete geçilmesi halinde; unvan, adres ve iletişim bilgileri bu alanda güncellenecektir.\n\n',
        ),
        TextSpan(
          text: 'İşleme Amaçları\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'Kişisel verileriniz; sürücü ve yolcu kayıt süreçlerinin yürütülmesi, yolculuk organizasyonu, güvenliğin sağlanması, '
              'hak ve taleplerin yönetimi, sistem performansının ölçülmesi ve geliştirilmesi amaçlarıyla işlenmektedir.\n\n',
        ),
        TextSpan(
          text: 'Toplama Yöntemi ve Hukuki Sebepler\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'Veriler; mobil uygulama üzerinden beyan yoluyla, cihaz izinleri kapsamında (örneğin konum verisi) otomatik yollarla veya '
              'ilgili üçüncü taraf servisler üzerinden toplanabilir. '
              'Bu işlemler, kanunlarda açıkça öngörülmesi, sözleşmenin kurulması ve ifası, veri sorumlusunun meşru menfaati gibi hukuki sebeplere dayanmaktadır.\n\n',
        ),
        TextSpan(
          text: 'Haklarınız\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'Kişisel verilerinize ilişkin olarak bilgi talep etme, düzeltme, silme, işlenmesini kısıtlama ve itiraz etme haklarına sahipsiniz. '
              'Bu hakları kullanmak için uygulama içinde yer alan iletişim / veri silme alanlarını kullanabilir veya geliştirici ile irtibata geçebilirsiniz.\n\n',
        ),
      ],
    );
  }
}

