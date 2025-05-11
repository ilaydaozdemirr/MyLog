import 'package:flutter/material.dart';
import 'snowfall_widget_web.dart';
import 'snowflake_ımage_widget_web.dart';
import 'drawer_menu.dart';

class HomePageWeb extends StatelessWidget {
  const HomePageWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80,
        title: const Text(
          'MYLOG',
          style: TextStyle(
            color: Colors.black,
            fontSize: 27,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onSelected: (value) {
              if (value == 'login') {
                Navigator.pushNamed(context, '/login');
              } else if (value == 'register') {
                Navigator.pushNamed(context, '/register');
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'login', child: Text('Giriş Yap')),
                  const PopupMenuItem(
                    value: 'register',
                    child: Text('Kayıt Ol'),
                  ),
                ],
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              showMyLogDrawer(context); //
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          // 🔽 Scrollable içerik
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Üst görsel
                  SizedBox(
                    height: 750,
                    width: double.infinity,
                    child: Image.asset(
                      'web/assets/web_gorsel.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 150),

                  // Ajanda görseli + Yazı
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 20.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Görsel sol
                        Expanded(
                          flex: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'web/assets/mylog_ajanda.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                        // Yazı sağ
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Hedefleriniz Gerçeğe Dönüşsün ✨',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 40),
                              Text(
                                'MYLOG, sadece bir ajanda değil; hayallerinize ulaşmanız için günlük alışkanlıklarınızı, hedeflerinizi ve ilhamınızı bir araya getiren kişisel bir rehberdir. \nGünlük yazılarınızdan tutun, haftalık planlarınıza kadar tüm detayları analiz eder, gelişiminizi görselleştirir. AI destekli analizlerle duygu durumunuzu takip eder, hedeflerinizi destekleyici önerilerde bulunur. Sade tasarımı ve estetik yapısıyla hayatınızın doğal bir parçası hâline gelir.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // ❄️ Kar animasyonu en önde, ama etkileşimi engellemez
          const Positioned.fill(
            child: IgnorePointer(child: SnowflakeImageWidgetWeb()),
          ),
        ],
      ),
    );
  }
}
