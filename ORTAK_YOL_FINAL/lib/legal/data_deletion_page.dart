import 'package:flutter/material.dart';
import 'legal_texts.dart';

class DataDeletionPage extends StatelessWidget {
  const DataDeletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalTextPage(
      title: 'Veri Silme Talebi',
      paragraphs: const [
        TextSpan(
          text:
              'Bu sayfa, kişisel verilerinizin silinmesine veya anonim hale getirilmesine yönelik taleplerinizi iletebilmeniz için hazırlanmıştır.\n\n',
        ),
        TextSpan(
          text: 'Veri Silme Süreci\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'Uygulama; kanunen saklanması zorunlu olan kayıtlar saklı kalmak üzere, hesabınızın kapatılmasını talep etmeniz halinde '
              'kişisel verilerinizi makul süre içinde silmeyi veya anonimleştirmeyi hedefler.\n\n',
        ),
        TextSpan(
          text: 'Nasıl Talep Oluşturulur?\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'Demo aşamasında; hesap silme ve veri silme taleplerinizi, kayıt olduğunuz e-posta adresiyle birlikte geliştirici ekibe iletebilirsiniz. '
              'Üretim ortamında, bu talep için özel bir başvuru kanalı ve form sağlanacaktır.\n\n',
        ),
        TextSpan(
          text: 'Önemli Not\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'Yasal yükümlülükler, uyuşmazlık süreçleri veya yetkili mercilerin talepleri nedeniyle belirli kayıtların belirli sürelerle saklanması gerekebilir. '
              'Bu hallerde; veriler, yalnızca zorunlu kapsam ve süre ile sınırlı olmak üzere korunur.\n\n',
        ),
        TextSpan(
          text: LegalTexts.tbkGeneralReference,
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

