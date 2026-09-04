#!/bin/bash

# Vercel sunucusuna Flutter'ı indir ve kur
echo "Flutter SDK indiriliyor..."
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Proje dosyalarını (web, android, ios) oluştur
echo "Flutter projesi başlatılıyor..."
flutter create .

# Web için projeyi derle
echo "Web sürümü derleniyor..."
flutter build web --release
