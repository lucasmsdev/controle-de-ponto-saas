# Controle de Ponto - Sistema de Registro de Horários

## Visão Geral

Aplicativo Flutter web para controle de horários de trabalho e pausas de funcionários com botões simples de start/stop. O sistema suporta 3 tipos de usuários (Admin, Gerente e Funcionário) com diferentes níveis de permissão e oferece resumos diários detalhados.

**Status:** ✅ Completamente funcional  
**Última atualização:** 14 de outubro de 2025

## Preferências do Usuário

- Comunicação: Linguagem simples e cotidiana
- Código: Comentado em português para facilitar entendimento
- Design: Sistema simplificado sem captura de fotos

## Cores do Sistema

- **Principal:** #14a25c (verde) - Trabalho e ações principais
- **Secundário:** #f28b4f (laranja) - Pausas e ações secundárias
- **Preto:** #000 - Textos e informações importantes

## Funcionalidades Implementadas

### 🔐 Tela de Login
- Autenticação com email e senha
- Suporte para 3 tipos de usuários: Admin, Gerente e Funcionário
- Usuários de teste pré-cadastrados
- Design com cores personalizadas

### 📊 Dashboard (Tela Principal)

**Para Funcionários:**
- **Botões Start/Stop de Trabalho:** Inicia e para períodos de trabalho
- **Botões Start/Stop de Pausa:** Inicia e para períodos de pausa/break
- **Resumo Diário Pessoal:**
  - Total de horas trabalhadas
  - Total de horas em pausa
  - Horas líquidas (trabalho - pausas)
- **Indicador de Status:** Mostra se está trabalhando, em pausa ou fora do expediente
- Acesso ao histórico pessoal

**Para Admin/Gerente:**
- **Resumo de Todos os Funcionários:** Visualização granular separada por funcionário
- Para cada funcionário mostra:
  - Nome e email
  - Total trabalhado no dia
  - Total de pausas no dia
  - Horas líquidas
- Acesso à administração de usuários
- Visualização de histórico completo

### 📋 Histórico de Pontos
- Lista todos os períodos registrados (trabalho e pausas)
- Mostra data de início e fim de cada período
- Exibe duração calculada (horas e minutos)
- Indica períodos ainda em andamento
- Filtro por usuário (para Admin/Gerente)
- Cores diferenciadas por tipo (trabalho = verde, pausa = laranja)

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
- Design com cores do sistema

## Estrutura do Projeto

```
lib/
├── main.dart                      # Ponto de entrada com tema personalizado
├── models/
│   ├── user.dart                  # Modelo de dados de usuário
│   └── time_record.dart           # Modelo de registro (start/stop + cálculos)
├── services/
│   └── data_service.dart          # Gerenciamento de dados e cálculos
└── screens/
    ├── login_screen.dart          # Tela de login
    ├── dashboard_screen.dart      # Dashboard com start/stop e resumos
    ├── history_screen.dart        # Histórico de períodos
    ├── admin_screen.dart          # Administração
    └── profile_screen.dart        # Perfil do usuário
```

## Tecnologias e Dependências

### Framework
- **Flutter 3.22.0** com Dart 3.4.0
- Material Design (Material 3)

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
- Métodos: isActive, durationInMinutes, durationInHours

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

### Controle de Permissões
- **Admin**: Acesso total, pode deletar usuários
- **Gerente**: Administração de usuários, visualização de todos os funcionários
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

## Funcionamento do Sistema

### Para Funcionários

1. **Iniciar Trabalho:** Clica em "Iniciar Trabalho"
   - Sistema registra horário de início
   - Botão "Parar Trabalho" fica habilitado
   - Botões de pausa ficam habilitados

2. **Fazer Pausa:** Durante o trabalho, clica em "Iniciar Pausa"
   - Sistema registra início da pausa
   - Tempo de pausa não conta como trabalho
   - Botão "Retornar ao Trabalho" fica habilitado

3. **Retornar da Pausa:** Clica em "Retornar ao Trabalho"
   - Sistema finaliza a pausa
   - Volta ao estado de trabalhando

4. **Finalizar Trabalho:** Clica em "Parar Trabalho"
   - Sistema registra horário de fim
   - Calcula duração total
   - Atualiza resumo diário

### Para Admin/Gerente

1. **Visualizar Funcionários:** Dashboard mostra todos os funcionários separadamente
2. **Ver Resumos:** Para cada funcionário vê:
   - Quantas horas trabalhou hoje
   - Quanto tempo ficou em pausa
   - Quantas horas líquidas (trabalho - pausa)
3. **Administrar:** Pode criar, editar e deletar usuários
4. **Histórico:** Pode filtrar e ver histórico de qualquer funcionário

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

### Mobile
- [ ] Build e testes Android/iOS
- [ ] Notificações push mobile
- [ ] Modo offline com sincronização

## Histórico de Desenvolvimento

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
// Principal (Verde)
Color(0xFF14a25c)

// Secundário (Laranja)
Color(0xFFf28b4f)

// Preto
Color(0xFF000)
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
