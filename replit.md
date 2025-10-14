# Controle de Ponto - Sistema de Registro de Horários

## Visão Geral

Aplicativo Flutter web para controle de horários de trabalho e pausas de funcionários com botões simples de start/stop. O sistema suporta 3 tipos de usuários (Admin, Gerente e Funcionário) com diferentes níveis de permissão e oferece resumos diários detalhados.

**Status:** ✅ Completamente funcional com modo claro/escuro  
**Última atualização:** 14 de outubro de 2025

## Preferências do Usuário

- Comunicação: Linguagem simples e cotidiana
- Código: Comentado em português para facilitar entendimento
- Design: Sistema simplificado sem captura de fotos

## Cores do Sistema

- **Azul Escuro:** #1E3A8A - Cor principal (botões, AppBar, destaques)
- **Preto:** #000 - Texto principal no modo claro
- **Branco:** #FFF - Fundo no modo claro, texto no modo escuro
- **Cinza Escuro:** #1F2937 - Fundo de cards no modo escuro

### Modo Claro e Escuro
- ☀️ **Modo Claro:** Fundo branco, textos pretos, botões azul escuro
- 🌙 **Modo Escuro:** Fundo preto, textos brancos, cards cinza escuro
- Toggle disponível no AppBar do Dashboard

## Funcionalidades Implementadas

### 🔐 Tela de Login
- Autenticação com email e senha
- Suporte para 3 tipos de usuários: Admin, Gerente e Funcionário
- Usuários de teste pré-cadastrados
- Design adaptativo com cores do tema

### 📊 Dashboard (Tela Principal)

**Para Funcionários:**
- **Botões Start/Stop de Trabalho:** Inicia e para períodos de trabalho
- **Botões Start/Stop de Pausa:** Inicia e para períodos de pausa/break
- **Resumo Diário Pessoal:**
  - Total de horas trabalhadas
  - Total de horas em pausa
  - Horas líquidas (trabalho - pausas)
- **Indicador de Status:** Mostra se está trabalhando, em pausa ou fora do expediente
- **Lançamento Manual:** Pode lançar um horário manual por dia
- Acesso ao histórico pessoal dos últimos 30 dias

**Para Admin/Gerente:**
- **Resumo de Todos os Funcionários:** Visualização granular separada por funcionário
- Para cada funcionário mostra:
  - Nome e email
  - Total trabalhado no dia
  - Total de pausas no dia
  - Horas líquidas
- **Lançamento Manual Ilimitado:** Pode lançar horários para qualquer funcionário
- **Edição de Registros:** Pode editar/deletar registros dos últimos 30 dias
- Acesso à administração de usuários
- Visualização de histórico completo

### 📝 Lançamento Manual de Horários

**Para Funcionários:**
- Pode lançar **um horário manual por dia**
- Seleciona data (últimos 30 dias), horário de início e fim
- Escolhe tipo: Trabalho ou Pausa
- Sistema valida se já lançou manual no dia

**Para Admin/Gerente:**
- Lançamento ilimitado para qualquer funcionário
- Mesma interface de seleção de data e horários
- Dropdown para escolher o funcionário

### 📋 Histórico de Pontos (30 Dias)
- Lista todos os períodos registrados dos **últimos 30 dias**
- Mostra data de início e fim de cada período
- Exibe duração calculada (horas e minutos)
- Indica períodos ainda em andamento
- Filtro por usuário (para Admin/Gerente)
- Cores diferenciadas por tipo (trabalho = azul, pausa = preto)
- **Botão de editar** para gerentes (registros dos últimos 30 dias)

### ✏️ Edição de Registros (Admin/Gerente)

**Funcionalidades:**
- Editar data, horário de início, horário de fim e tipo
- Deletar registros com confirmação
- Apenas registros dos **últimos 30 dias** podem ser editados
- Mostra informações do funcionário
- Validações de horário (fim > início)

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
- Design com cores do tema

## Estrutura do Projeto

```
lib/
├── main.dart                      # Ponto de entrada com suporte a tema
├── models/
│   ├── user.dart                  # Modelo de dados de usuário
│   └── time_record.dart           # Modelo de registro (start/stop + cálculos)
├── services/
│   ├── data_service.dart          # Gerenciamento de dados e cálculos
│   └── theme_service.dart         # Gerenciamento de tema claro/escuro
└── screens/
    ├── login_screen.dart          # Tela de login
    ├── dashboard_screen.dart      # Dashboard com start/stop e resumos
    ├── manual_entry_screen.dart   # Lançamento manual de horários
    ├── history_screen.dart        # Histórico dos últimos 30 dias
    ├── edit_record_screen.dart    # Edição de registros (gerente)
    ├── admin_screen.dart          # Administração
    └── profile_screen.dart        # Perfil do usuário
```

## Tecnologias e Dependências

### Framework
- **Flutter 3.22.0** com Dart 3.4.0
- Material Design (Material 3) com tema dinâmico

### Pacotes
- `intl` ^0.18.0 - Formatação de datas e horas

### Plataformas Suportadas
- ✅ Web (HTML renderer) - Totalmente funcional
- 📱 Android - Código preparado
- 🍎 iOS - Código preparado  
- 🖥️ Desktop (Windows, macOS, Linux) - Código preparado

## Arquitetura

### Modelos de Dados

**User:**
- id, name, email, password, role (admin/gerente/funcionario)

**TimeRecord:**
- id, userId, startTime, endTime (null = em andamento)
- type (trabalho ou pausa)
- Métodos: isActive, durationInMinutes, durationInHours, copyWith

**DailySummary:**
- userId, date
- totalWorkHours (total de horas trabalhadas)
- totalBreakHours (total de horas de pausa)
- netWorkHours (horas líquidas = trabalho - pausas)
- Método estático: formatHours (converte decimal para "Xh Ymin")

### Gerenciamento de Dados (DataService)

**Métodos principais:**
- `startPeriod()` - Inicia um período (trabalho ou pausa)
- `stopActivePeriod()` - Finaliza o período ativo
- `hasActivePeriod()` - Verifica se há período ativo
- `getActivePeriod()` - Obtém o período ativo atual
- `getDailySummary()` - Calcula resumo diário de um usuário
- `getEmployees()` - Lista todos os funcionários
- `addManualRecord()` - Adiciona registro manual com horários específicos
- `updateRecord()` - Atualiza um registro existente
- `deleteRecord()` - Remove um registro
- `hasManualRecordToday()` - Verifica se funcionário já lançou manual hoje
- `getRecordsLastDays()` - Obtém registros dos últimos N dias
- `canEditRecord()` - Verifica se registro pode ser editado (30 dias)

### Gerenciamento de Tema (ThemeService)

**Funcionalidades:**
- Modo claro e escuro
- Toggle entre modos
- Cores personalizadas (azul escuro, preto, branco)
- Suporte a Material 3
- Listener para mudanças de tema

### Controle de Permissões
- **Admin**: Acesso total, pode deletar usuários
- **Gerente**: Administração de usuários, edição de registros, lançamento ilimitado
- **Funcionário**: Apenas registros pessoais, um lançamento manual por dia

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

## Funcionamento do Sistema

### Para Funcionários

**Registro Automático (Start/Stop):**
1. **Iniciar Trabalho:** Clica em "Iniciar Trabalho"
   - Sistema registra horário de início
   - Botão "Parar Trabalho" fica habilitado
   - Botões de pausa ficam habilitados
2. **Fazer Pausa:** Durante o trabalho, clica em "Iniciar Pausa"
   - Sistema registra início da pausa
   - Tempo de pausa não conta como trabalho
3. **Retornar da Pausa:** Clica em "Retornar ao Trabalho"
   - Sistema finaliza a pausa
   - Volta ao estado de trabalhando
4. **Finalizar Trabalho:** Clica em "Parar Trabalho"
   - Sistema registra horário de fim
   - Calcula duração total
   - Atualiza resumo diário

**Lançamento Manual (Uma vez por dia):**
1. Clica em "Lançamento Manual de Horário"
2. Seleciona tipo (Trabalho ou Pausa)
3. Escolhe data (últimos 30 dias)
4. Define horário de início e fim
5. Salva registro
6. **Limitação:** Apenas um lançamento manual por dia

### Para Admin/Gerente

**Visualização:**
1. Dashboard mostra todos os funcionários separadamente
2. Para cada funcionário vê:
   - Quantas horas trabalhou hoje
   - Quanto tempo ficou em pausa
   - Quantas horas líquidas (trabalho - pausa)

**Lançamento Manual (Ilimitado):**
1. Acessa "Lançamento Manual de Horário"
2. Seleciona o funcionário (dropdown)
3. Define tipo, data e horários
4. Salva sem limitação de quantidade

**Edição de Registros:**
1. Acessa "Ver Histórico Completo"
2. Filtra por funcionário (opcional)
3. Clica no ícone de editar em qualquer registro dos últimos 30 dias
4. Modifica data, horários ou tipo
5. Pode deletar o registro com confirmação

**Administração:**
- Criar, editar e deletar usuários
- Ver histórico completo filtrado

## Cálculos Automáticos

### Resumo Diário
Para cada dia, o sistema calcula:

1. **Total Trabalhado:** Soma de todas as durações de períodos de "trabalho" finalizados
2. **Total de Pausas:** Soma de todas as durações de períodos de "pausa" finalizados
3. **Horas Líquidas:** Total Trabalhado - Total de Pausas

**Nota:** Períodos ainda em andamento não são contabilizados nos totais.

### Exemplo Prático

Se um funcionário fez:
- Trabalho: 09:00 - 12:00 (3h)
- Pausa: 12:00 - 13:00 (1h)
- Trabalho: 13:00 - 18:00 (5h)

O resumo mostra:
- Total Trabalhado: 8h 0min
- Total de Pausas: 1h 0min
- Horas Líquidas: 7h 0min

## Regras de Negócio

### Lançamento Manual
1. **Funcionários:** 
   - Máximo de 1 lançamento manual por dia
   - Podem lançar apenas para si mesmos
   - Data limitada aos últimos 30 dias
2. **Gerentes/Admin:**
   - Lançamentos ilimitados
   - Podem lançar para qualquer funcionário
   - Data limitada aos últimos 30 dias

### Edição de Registros
1. **Apenas gerentes/admin** podem editar
2. Apenas registros dos **últimos 30 dias**
3. Podem modificar: data, horários, tipo
4. Podem deletar com confirmação
5. Validação: horário de fim > horário de início

### Histórico
1. Mostra registros dos **últimos 30 dias**
2. Funcionários veem apenas seus registros
3. Gerentes/admin veem todos, com filtro opcional
4. Registros ativos marcados como "Em Andamento"

## Armazenamento de Dados

**Atual (MVP):**
- Dados em memória (não persistem após refresh)
- Ideal para desenvolvimento e testes

**Para Produção:**
- Implementar backend REST ou Firebase
- Banco de dados PostgreSQL ou MySQL
- Autenticação JWT

## Melhorias Futuras

### Backend e Persistência
- [ ] Integração com Firebase ou backend REST
- [ ] Banco de dados real
- [ ] Autenticação JWT
- [ ] API para exportação de dados

### Funcionalidades
- [ ] Relatórios mensais e anuais
- [ ] Exportação para Excel/PDF
- [ ] Gráficos de produtividade
- [ ] Notificações (lembrete de registrar ponto)
- [ ] Geolocalização (verificar se está no local de trabalho)
- [ ] Justificativas para ausências
- [ ] Histórico completo (mais de 30 dias)
- [ ] Aprovação de lançamentos manuais

### Mobile
- [ ] Build e testes Android/iOS
- [ ] Notificações push mobile
- [ ] Modo offline com sincronização

## Histórico de Desenvolvimento

**14/10/2025 - Versão 3.0:**
- ✅ Mudança completa de cores (preto, branco, azul escuro)
- ✅ Implementado modo claro e modo escuro com toggle
- ✅ Adicionado lançamento manual de horários:
  - Funcionários: 1 por dia
  - Gerentes: ilimitado para qualquer funcionário
- ✅ Histórico filtrado para últimos 30 dias
- ✅ Edição e exclusão de registros (gerentes, últimos 30 dias)
- ✅ ThemeService para gerenciamento de tema
- ✅ Validações de regras de negócio

**14/10/2025 - Versão 2.0:**
- ✅ Removida funcionalidade de foto
- ✅ Implementado sistema start/stop simples
- ✅ Adicionado cálculo de horas trabalhadas
- ✅ Criado resumo diário com totais
- ✅ Implementada visualização granular para Admin/Gerente
- ✅ Aplicado esquema de cores personalizado (#14a25c, #f28b4f, #000)
- ✅ Simplificada estrutura do app

**14/10/2025 - Versão 1.0:**
- ✅ Criação inicial com 7 telas
- ✅ Sistema com captura de foto
- ✅ Compatibilidade web
- ✅ Workflow configurado

## Notas Técnicas

### Cores no Código
```dart
// Azul Escuro (Principal)
Color(0xFF1E3A8A)

// Preto
Color(0xFF000000)

// Branco
Color(0xFFFFFFFF)

// Cinza Escuro (Cards modo escuro)
Color(0xFF1F2937)
```

### Tema Dinâmico
```dart
// Acesso ao tema atual
Theme.of(context).colorScheme.primary
Theme.of(context).colorScheme.onSurface

// Toggle de tema
final themeService = ThemeService();
themeService.toggleTheme();
```

### Compatibilidade Web
- Build estático servido via Python HTTP server
- Sem dependências de câmera ou imagem
- Apenas dependência: intl (formatação de datas)

### Git Ignore
Configurado para excluir:
- Arquivos de build Flutter
- Dependências e cache
- Arquivos IDE
- Arquivos de plataformas específicas

## Comandos Úteis

```bash
# Instalar dependências
flutter pub get

# Limpar e fazer build para web
flutter clean && flutter build web --web-renderer html

# Executar com workflow configurado
./run_web.sh

# Ver dependências desatualizadas
flutter pub outdated
```

## Suporte

Para dúvidas ou melhorias, consulte a documentação do Flutter em https://flutter.dev
