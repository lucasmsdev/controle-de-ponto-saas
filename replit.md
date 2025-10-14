# Controle de Ponto - Sistema de Registro de Horários

## Visão Geral

Aplicativo Flutter completo para controle de horários de entrada, saída e pausas de funcionários com registro fotográfico. O sistema suporta 3 tipos de usuários (Admin, Gerente e Funcionário) com diferentes níveis de permissão.

**Status:** ✅ MVP Web completo e funcional  
**Última atualização:** 14 de outubro de 2025

## Preferências do Usuário

- Comunicação: Linguagem simples e cotidiana
- Código: Comentado em português para facilitar entendimento

## Funcionalidades Implementadas

### 🔐 Tela de Login
- Autenticação com email e senha
- Suporte para 3 tipos de usuários: Admin, Gerente e Funcionário
- Usuários de teste pré-cadastrados

### 📊 Dashboard (Tela Principal)
**Para Funcionários:**
- Botões para registrar: Entrada, Saída, Início de Pausa, Fim de Pausa
- Acesso a lançamento manual de horários
- Visualização de histórico pessoal

**Para Admin/Gerente:**
- Resumo de funcionários e registros
- Acesso à administração de usuários
- Visualização de histórico completo

### 📸 Registro de Ponto com Foto
- Captura de foto via câmera ou seleção da galeria
- Registro automático de data/hora
- Tipos de registro: Entrada, Saída, Início/Fim de Pausa
- Preview da foto antes de confirmar

### ✏️ Lançamento Manual
- Permite registrar horários manualmente (sem foto)
- Seleção de data e horário personalizado
- Marcado como "Manual" no histórico

### 📋 Histórico de Pontos
- Lista todos os registros com data/hora
- Miniaturas de fotos (quando disponível)
- Filtro por usuário (para Admin/Gerente)
- Indicação visual de registros manuais
- Visualização ampliada de fotos

### 👥 Administração (Admin/Gerente)
- Listar todos os usuários
- Criar novos usuários
- Editar informações de usuários
- Excluir usuários (apenas Admin)
- Controle de permissões por tipo

### 👤 Perfil do Usuário
- Visualização de dados pessoais
- Edição de perfil (funcionários)
- Exibição do tipo de usuário

## Estrutura do Projeto

```
lib/
├── main.dart                      # Ponto de entrada do app
├── models/
│   ├── user.dart                  # Modelo de dados de usuário
│   └── time_record.dart           # Modelo de registro de ponto
├── services/
│   └── data_service.dart          # Serviço de gerenciamento de dados
└── screens/
    ├── login_screen.dart          # Tela de login
    ├── dashboard_screen.dart      # Dashboard principal
    ├── time_record_screen.dart    # Registro com foto
    ├── manual_record_screen.dart  # Lançamento manual
    ├── history_screen.dart        # Histórico de pontos
    ├── admin_screen.dart          # Administração
    └── profile_screen.dart        # Perfil do usuário
```

## Tecnologias e Dependências

### Framework
- **Flutter 3.22.0** com Dart 3.4.0
- Material Design (Material 3)

### Pacotes Principais
- `camera` ^0.10.5+5 - Captura de fotos
- `image_picker` ^1.0.4 - Seleção de imagens
- `intl` ^0.18.0 - Formatação de datas
- `path_provider` ^2.1.1 - Acesso ao sistema de arquivos

### Plataformas Suportadas
- ✅ Web (HTML renderer) - Funcional
- 📱 Android - Código preparado
- 🍎 iOS - Código preparado  
- 🖥️ Desktop (Windows, macOS, Linux) - Código preparado

## Arquitetura

### Modelos de Dados

**User:**
- id, name, email, password, role (admin/gerente/funcionario)

**TimeRecord:**
- id, userId, timestamp, type (entrada/saida/pausa), photoPath, isManual

### Gerenciamento de Dados
- `DataService` - Singleton que gerencia:
  - Autenticação de usuários
  - CRUD de usuários
  - Registro de pontos
  - Consultas e filtros de histórico
  - Controle de permissões

### Controle de Permissões
- **Admin**: Acesso total, pode deletar usuários
- **Gerente**: Administração de usuários, visualização geral
- **Funcionário**: Apenas registros pessoais e perfil próprio

## Configuração de Desenvolvimento

### Build e Execução Web
```bash
# Build automático e servidor na porta 5000
./run_web.sh
```

O script `run_web.sh`:
1. Compila o app para web com `flutter build web --web-renderer html`
2. Serve os arquivos estáticos em `build/web/` usando Python HTTP server
3. App disponível em `http://0.0.0.0:5000`

### Workflow Replit
- **Nome:** Flutter Web
- **Comando:** `./run_web.sh`
- **Porta:** 5000
- **Tipo:** webview

## Usuários de Teste

| Tipo | Email | Senha |
|------|-------|-------|
| Admin | admin@empresa.com | admin123 |
| Gerente | gerente@empresa.com | gerente123 |
| Funcionário | funcionario@empresa.com | func123 |

## Limitações Conhecidas (MVP Web)

### Fotos no Histórico Web
- **Web**: Fotos não são exibidas (limitação técnica do browser)
- **Solução MVP**: Ícone de câmera indica presença de foto
- **Plataformas nativas**: Código preparado para exibir fotos reais

### Armazenamento
- Dados armazenados em memória (não persistem após refresh)
- Para produção: Implementar backend e banco de dados

### Captura de Foto Web
- Funcionalidade pode variar entre navegadores
- Requer permissão de câmera do usuário
- Alternativa: Seleção de arquivo de imagem

## Melhorias Futuras

### Backend e Persistência
- [ ] Integração com Firebase ou backend REST
- [ ] Banco de dados real (PostgreSQL/MySQL)
- [ ] Autenticação JWT

### Funcionalidades
- [ ] Cálculo de horas trabalhadas
- [ ] Relatórios e exportação
- [ ] Notificações push
- [ ] Geolocalização nos registros

### Mobile
- [ ] Build e testes Android/iOS
- [ ] Suporte completo a fotos em dispositivos móveis
- [ ] Otimizações mobile

## Histórico de Desenvolvimento

**14/10/2025:**
- ✅ Criação de todas as 7 telas solicitadas
- ✅ Implementação de modelos e serviços
- ✅ Sistema de autenticação e permissões
- ✅ Integração com câmera (web-compatible)
- ✅ Workflow configurado para web
- ✅ Correções de compatibilidade web (remoção de dart:io)
- ✅ Build e deploy web funcionando

## Notas Técnicas

### Compatibilidade Web
O projeto foi adaptado para ser compatível com Flutter web:
- Removido uso direto de `dart:io` 
- Implementado detecção de plataforma com `kIsWeb`
- Renderização condicional de imagens
- Build estático servido via Python HTTP server (contorna problemas do dev server)

### Git Ignore
Configurado para excluir:
- Arquivos de build Flutter
- Dependências e cache
- Arquivos IDE (VSCode, Android Studio)
- Arquivos de plataformas específicas

## Comandos Úteis

```bash
# Instalar dependências
flutter pub get

# Build para web
flutter build web --web-renderer html

# Executar com workflow configurado
./run_web.sh

# Limpar build
flutter clean
```

## Suporte e Contato

Para dúvidas ou melhorias, consulte a documentação do Flutter em https://flutter.dev
