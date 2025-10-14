# Controle de Ponto - Sistema de Registro de Horários

## Overview

A Flutter web application designed for managing employee work and break times, featuring simple start/stop buttons. The system supports three user types (Admin, Manager, Employee) with distinct permission levels and provides detailed daily summaries. It is fully integrated with Supabase for data persistence using PostgreSQL. The project aims to streamline time tracking, improve accountability, and offer comprehensive reporting for workforce management.

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
    -   **Admin:** Full access, including user deletion.
    -   **Manager:** User administration, record editing, unlimited manual entries.
    -   **Employee:** Personal records only, one manual entry per day.

### System Design Choices
-   **Data Models:**
    -   `User`: id, name, email, password, role.
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
    -   **Tables:** `users`, `time_records`.
    -   **Authentication:** Email/password login managed by Supabase.
    -   **Security:** Row Level Security (RLS) enabled with defined access policies.
-   **Packages:**
    -   `intl` (for date and time formatting)
    -   `supabase_flutter` (for Supabase integration)
-   **Platform Support:** Primarily developed for Web (HTML renderer), with code prepared for Android, iOS, and Desktop.