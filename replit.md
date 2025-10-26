# Controle de Ponto - Sistema de Registro de Horários

## Overview

A Flutter web application designed for managing employee work and break times, featuring simple start/stop buttons. The system supports three user types (Admin, Manager, Employee) with distinct permission levels and provides detailed daily summaries. It is fully integrated with Supabase for data persistence using PostgreSQL. The project aims to streamline time tracking, improve accountability, and offer comprehensive reporting for workforce management.

## Recent Changes (Outubro 2025)

### Sistema de Atribuição de Funcionários a Gerentes (26/10/2025)
- **Nova Funcionalidade:** Implementado sistema completo de atribuição de funcionários a gerentes específicos
  - **Banco de Dados:** Adicionada coluna `manager_id` (FK para users.id) na tabela users
  - **Modelo User:** Campo `managerId` (String?, nullable) para armazenar ID do gerente responsável
  - **AdminScreen:** Dropdown "Gerente Responsável" ao criar/editar funcionários
    - Dropdown só aparece quando role selecionado é "Funcionário"
    - Lista apenas gerentes disponíveis + opção "Sem gerente"
    - Admins e gerentes sempre têm managerId = null
  - **Dashboard do Gerente:** Filtragem automática para mostrar apenas funcionários atribuídos
    - Gerente vê apenas funcionários com managerId == currentUser.id
    - Admin continua vendo todos os funcionários
  - **Registro Público:** Botão "Criar nova conta" agora cria apenas contas de funcionário (sem seleção de role)
  - **Limpeza de Código:** Removidos logs de debug e credenciais de teste da tela de login
- **Resultado:** Melhor controle organizacional com gerentes responsáveis por equipes específicas

### Correção: Atualização da Dashboard Após Edição (15/10/2025)
- **Problema Resolvido:** Edições de horário no histórico não atualizavam a dashboard do gerente
  - **Causa:** Botão "Ver Histórico Completo" não tinha callback `.then(setState)` ao retornar
  - **Solução:** Adicionado `.then((_) => setState(() {}))` no botão de histórico
  - **Resultado:** Dashboard agora atualiza automaticamente ao voltar do histórico, recarregando FutureBuilders com dados do Supabase
- **Logs de Debug:** Adicionados logs em DataService e SupabaseService para rastreamento de tipos de registro
- **Carregamento de Usuários:** DashboardScreen agora carrega usuários do Supabase no initState para gerentes/admins

### Migração de Tipos e Carregamento Dinâmico de Usuários (15/10/2025)
- **Problema 1 Resolvido:** Lançamentos manuais salvavam todos os registros como "pausa"
  - **Causa:** TimeRecord.type usava enum RecordType mas Supabase esperava String
  - **Solução:** Migrado TimeRecord.type de enum para String ('trabalho'/'pausa')
  - **Arquivos Atualizados:** time_record.dart, history_screen.dart, data_service.dart, edit_record_screen.dart
- **Problema 2 Resolvido:** Funcionários criados apareciam como "Usuário desconhecido" no histórico
  - **Causa:** DataService usava lista hardcoded de usuários ao invés de ler do Supabase
  - **Solução:** Implementado `loadUsers()` que busca todos os usuários do banco
  - **Integração:** loadUsers() chamado após login e após CRUD de usuários (add/update/delete)
  - **AdminScreen:** Métodos async com await + reload automático da lista de usuários
- **Resultado:** Novos funcionários aparecem imediatamente na dashboard e histórico sem necessidade de reiniciar

### Correção Crítica: UI Lendo do Supabase (15/10/2025)
- **Problema Resolvido:** Registros salvos no Supabase não apareciam na UI (leitura de memória local vazia)
- **HistoryScreen:** Convertido para FutureBuilder com leitura async do Supabase
  - Admin/gerente sem filtro → `getAllRecords()` (todos os registros)
  - Admin/gerente com filtro → `getUserRecords(userId)` (usuário específico)
  - Funcionário → `getUserRecords(currentUser.id)` (apenas próprios registros)
  - Dropdown corrigido para aceitar `String?` (nullable) permitindo "Todos os usuários"
- **ManualEntryScreen:** `addManualRecord()` agora usa `await` com tratamento de erros
- **EditRecordScreen:** `updateRecord()` e `deleteRecord()` agora usam `await` com tratamento de erros
- **Resultado:** UI agora carrega dados do Supabase em tempo real, histórico acessível para todos os tipos de usuário

### Correções de Compilação
- **DateFormat removido:** Substituído por formatação manual de datas (sem dependência do pacote `intl`)
- **Build compilando:** Flutter web build bem-sucedido após limpeza de cache

### Correções Críticas de Login (Anteriores)
- **Problema Resolvido:** Tela cinza após login (DataService.currentUser null)
- **Solução:** Sincronização automática entre SupabaseService e DataService após autenticação
- **Implementação:** LoginScreen agora seta currentUser no DataService após login bem-sucedido no Supabase

### Melhorias de Tratamento de Erros
- **SupabaseService.initialize():** Validação de credenciais, logs de debug, propagação adequada de exceções
- **main.dart:** Try-catch global com ErrorApp mostrando mensagens amigáveis em caso de falha na inicialização
- **Prevenção:** Tela cinza agora substituída por tela de erro informativa

### Integração Supabase
- **Detecção de Duplicados:** Validação em tempo real de emails duplicados no cadastro
- **Flag is_manual:** Diferenciação entre registros automáticos (start/stop) e manuais
- **Mensagens Específicas:** Erros de constraint unique retornam mensagens claras para o usuário

## User Preferences

- Comunicação: Linguagem simples e cotidiana
- Código: Comentado em português para facilitar entendimento
- Design: Sistema simplificado sem captura de fotos
- Backend: Supabase para armazenamento permanente

## System Architecture

The application is built with Flutter 3.22.0 and Dart 3.4.0, utilizing Material Design (Material 3) with dynamic theming (light/dark mode).

### UI/UX Decisions
- **Color Scheme:** Dark Blue (#1E3A8A) for primary actions, Black (#000) for light mode text, White (#FFF) for light mode background and dark mode text, Dark Grey (#1F2937) for dark mode card backgrounds.
- **Theming:** Supports both light and dark modes with a toggle in the Dashboard AppBar.
- **Design Philosophy:** Simplified interface focusing on core time-tracking functionalities without advanced features like photo capture.

### Feature Specifications
-   **Authentication:** Login via email/password using Supabase, supporting Admin, Manager, and Employee roles. Public user registration is available.
-   **Dashboard:**
    -   **Employees:** Start/stop work and break timers, personal daily summary (total worked, total breaks, net hours), status indicator, and manual time entry (one per day). Access to personal 30-day history.
    -   **Admin/Manager:** Overview of all employees' daily summaries, unlimited manual time entries for any employee, ability to edit/delete records (last 30 days), and user administration.
-   **Manual Time Entry:** Allows employees one manual entry per day for the last 30 days. Admins/Managers have unlimited manual entries for any employee.
-   **History:** Displays records from the last 30 days with start/end times and calculated durations. Admins/Managers can filter by user and edit/delete records.
-   **User Administration (Admin/Manager):** Create, edit, and delete users (Admin only for deletion), and manage user roles/permissions.
-   **Permission Control:**
    -   **Admin:** Full access, including user deletion. Can assign employees to managers. Sees all employees in dashboard.
    -   **Manager:** User administration, record editing, unlimited manual entries. Can assign employees to other managers. Sees only assigned employees in dashboard.
    -   **Employee:** Personal records only, one manual entry per day. Can have an assigned manager.

### System Design Choices
-   **Data Models:**
    -   `User`: id, name, email, password, role, managerId (nullable - ID do gerente responsável pelo funcionário).
    -   `TimeRecord`: id, userId, startTime, endTime, type (work/break). Includes methods for active status and duration calculation.
    -   `DailySummary`: userId, date, totalWorkHours, totalBreakHours, netWorkHours.
-   **Supabase Integration (`SupabaseService`):** Manages all database interactions, including authentication, user management, and time record operations.
-   **Theme Management (`ThemeService`):** Handles light/dark mode switching and custom color application.
-   **Rules of Business:**
    -   **Manual Entries:** Employees are limited to one manual entry per day for their own records (last 30 days). Managers/Admins have unlimited entries for any user (last 30 days).
    -   **Record Editing:** Only Managers/Admins can edit or delete records, limited to the last 30 days, with validation (end time > start time).
    -   **History View:** Displays records from the last 30 days; employees see only their own, while managers/admins see all with filtering options.

## External Dependencies

-   **Framework:** Flutter (3.22.0)
-   **Backend & Database:** Supabase (PostgreSQL)
    -   **Tables:** `users` (with manager_id FK), `time_records`.
    -   **Authentication:** Email/password login managed by Supabase.
    -   **Security:** Row Level Security (RLS) enabled with defined access policies.
-   **Packages:**
    -   `intl` (for date and time formatting)
    -   `supabase_flutter` (for Supabase integration)
-   **Platform Support:** Primarily developed for Web (HTML renderer), with code prepared for Android, iOS, and Desktop.