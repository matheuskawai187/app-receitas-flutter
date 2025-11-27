# 🍽️ Receitas App

Um aplicativo de receitas desenvolvido em **Flutter/Dart** que consome a **API TheMealDB** para exibir receitas internacionais.  
Desenvolvido como trabalho da faculdade com funcionalidades de busca, filtros e favoritos persistentes.

---

## ✨ Funcionalidades

- 🌍 **Listagem de receitas internacionais** via API TheMealDB
- 🔍 **Busca em tempo real** com tolerância a erros de digitação
- 🏷️ **Filtros por categoria** (Dessert, Seafood, Chicken, Beef, Pasta, etc.)
- ❤️ **Sistema de favoritos** com persistência local
- 📱 **3 abas principais**: Home, Buscar e Favoritos
- 📄 **Detalhes completos** das receitas (ingredientes, medidas e modo de preparo)
- 🎨 **Interface consistente** com tema laranja

---

## 🛠️ Tecnologias Utilizadas

- **Flutter/Dart** - Framework mobile
- **API REST** - TheMealDB (https://www.themealdb.com)
- **SharedPreferences** - Armazenamento local de favoritos
- **HTTP Package** - Requisições à API
- **Material Design** - Interface de usuário

---

## 📋 Requisitos Atendidos

Este projeto atende aos seguintes requisitos acadêmicos:

- ✅ **Uso de banco de dados local** (SharedPreferences para favoritos)
- ✅ **Uso de servidor ou rede** (Consumo da API TheMealDB)
- ✅ **Interface completa** com navegação entre telas
- ✅ **Funcionalidades extras** (busca, filtros, persistência)

---

## 🚀 Como Executar

### **1. Pré-requisitos**

- Flutter SDK 3.2.0+
- Dart SDK
- Android Studio ou VS Code
- Dispositivo/Emulador Android ou iOS

### **2. Clonar o repositório**

```bash
git clone https://github.com/matheuskawai187/app-receitas-flutter.git
cd app-receitas-flutter
```

### **3. Instalar dependências**

```bash
flutter pub get
```

### **4. Executar o app**

**Em um emulador/dispositivo conectado:**
```bash
flutter run
```

**No navegador (web):**
```bash
flutter run -d chrome
```

**Gerar APK para instalação:**
```bash
flutter build apk --release
```
O APK ficará em: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📦 Dependências

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  shared_preferences: ^2.2.2
  cupertino_icons: ^1.0.8
```

---

## 📱 Estrutura do Projeto

```
lib/
├── main.dart              # Tela principal e navegação
├── buscar_page.dart       # Tela de busca com API
└── api_service.dart       # Serviço de requisições à API
```

### **Principais Classes:**

- `MealDBService` - Gerencia requisições à API
- `ReceitaAPI` - Modelo simplificado de receita
- `ReceitaAPIDetalhada` - Modelo completo com todos os detalhes
- `HomePage` - Lista receitas por categoria
- `BuscarPage` - Busca receitas por nome
- `FavoritosPage` - Exibe receitas favoritadas
- `DetalhesReceitaAPIPage` - Detalhes completos da receita

---

## 🎯 Funcionalidades Detalhadas

### **Home (Receitas Internacionais)**
- Lista receitas organizadas por categorias
- Filtro "Todas" que carrega 5 receitas de cada categoria
- Possibilidade de desselecionar categoria clicando novamente
- Card com imagem, nome e ícone de favorito

### **Buscar**
- Campo de busca com debounce (500ms)
- Busca flexível que aceita termos parciais
- Sugestões de termos populares (Pasta, Chicken, Soup, etc.)
- Resultado em tempo real

### **Favoritos**
- Lista de todas as receitas favoritadas
- Persistência entre sessões do app
- Remoção rápida de favoritos

### **Detalhes da Receita**
- Imagem em destaque
- Lista de ingredientes com medidas
- Modo de preparo completo
- Categoria e origem do prato
- Botão de favoritar/desfavoritar

---

## 🌐 API Utilizada

**TheMealDB API** - API gratuita com milhares de receitas internacionais

Endpoints utilizados:
- `GET /filter.php?c={categoria}` - Buscar por categoria
- `GET /search.php?s={nome}` - Buscar por nome
- `GET /search.php?f={letra}` - Buscar pela primeira letra
- `GET /lookup.php?i={id}` - Detalhes completos
- `GET /categories.php` - Listar categorias

Documentação: https://www.themealdb.com/api.php

---

## 🎨 Paleta de Cores

- **Primária:** Laranja (`Colors.orange`)
- **Fundo:** Laranja claro (`Colors.orange[50]`)
- **Favorito:** Vermelho (`Colors.red`)
- **Texto:** Cinza escuro (`Colors.grey[700]`)

---

## 🐛 Possíveis Melhorias Futuras

- [ ] Adicionar modo escuro
- [ ] Implementar SQLite ao invés de SharedPreferences
- [ ] Adicionar receitas offline
- [ ] Criar sistema de avaliações
- [ ] Compartilhar receitas via WhatsApp/Instagram
- [ ] Adicionar lista de compras baseada nos ingredientes

---

## 📄 Licença

Este projeto foi desenvolvido para fins educacionais como trabalho da faculdade.

---

**Desenvolvido com ❤️ em Flutter**