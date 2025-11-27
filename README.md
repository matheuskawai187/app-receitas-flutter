# 🍳 Receitas App

Um app simples em **Flutter** para visualizar e gerenciar receitas fáceis.  
Inclui 20 receitas com imagens, filtros por categoria, busca e favoritos persistentes.

---

## 🚀 Funcionalidades

- Lista de **20 receitas** divididas em categorias (Doces, Principais, Saladas, etc.).
- Filtro por categoria via dropdown.
- **Busca em tempo real** por nome ou descrição.
- Sistema de **favoritos locais** usando `shared_preferences`.
- Abas: **Home** e **Favoritos**.
- Tela de **detalhes da receita** com ingredientes e modo de preparo.

---

## 🧩 Requisitos

- **Flutter SDK 3.2.0+**
- Editor: **VS Code** ou **Android Studio**
- Conexão com a internet (para imagens online)

---

## ⚙️ Instalação e Execução

1. **Crie o projeto Flutter:**
   ```bash
   flutter create receitas_app
   cd receitas_app


2.Substitua o arquivo lib/main.dart pelo código do app (contendo as 20 receitas).
Atualize o arquivo pubspec.yaml com o conteúdo abaixo:

name: receitas_app
description: "App de receitas simples para visualizar e gerenciar receitas."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.2.0

dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true


Baixe as dependências:

flutter pub get


Execute o app:

💻 Web: flutter run -d chrome

📱 Mobile: flutter run