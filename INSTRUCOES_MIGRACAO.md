# 📋 Instruções para Ativar o Sistema de Atribuição de Funcionários a Gerentes

## ⚠️ IMPORTANTE: Execute o Script SQL no Supabase

Para que o sistema funcione corretamente, você precisa executar um script SQL no seu banco de dados Supabase. Siga os passos abaixo:

---

## 🔧 Passo a Passo

### 1. Acesse o Painel do Supabase
1. Vá para [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Faça login na sua conta
3. Selecione o projeto do **Controle de Ponto**

### 2. Abra o Editor SQL
1. No menu lateral esquerdo, clique em **SQL Editor**
2. Clique em **New Query** (Nova Consulta)

### 3. Execute o Script de Migração
1. Copie **TODO** o conteúdo do arquivo `supabase_migration_manager_id.sql`
2. Cole no editor SQL do Supabase
3. Clique em **Run** (Executar)

### 4. Verifique se Funcionou
Após executar o script, execute esta query para verificar:

```sql
SELECT id, name, email, role, manager_id FROM users;
```

Você deve ver a coluna `manager_id` aparecendo na tabela (ela estará vazia/NULL para todos os usuários existentes, o que é esperado).

---

## ✅ O Que Foi Implementado

### 1. **Registro Público Simplificado**
- O botão **"Criar nova conta"** na tela de login agora cria apenas contas de **funcionário**
- Não há mais seleção de tipo de usuário no registro público
- Administradores continuam podendo criar qualquer tipo de conta através do painel administrativo

### 2. **Sistema de Atribuição de Funcionários**
- **Admins** podem designar gerentes específicos para cada funcionário
- Ao criar ou editar um funcionário no painel administrativo, aparece um dropdown **"Gerente Responsável"**
- Opções: gerentes disponíveis ou "Sem gerente"
- Este dropdown **só aparece** quando o tipo selecionado é "Funcionário"

### 3. **Dashboard Filtrado para Gerentes**
- **Gerentes** agora veem apenas os funcionários atribuídos a eles
- O título muda para "Meus Funcionários" (ao invés de "Resumo de Todos os Funcionários")
- **Admins** continuam vendo todos os funcionários normalmente

### 4. **Limpeza de Código**
- Removidas as credenciais de teste da tela de login
- Removidos logs de debug desnecessários
- Código mais limpo e profissional

---

## 🎯 Como Usar o Sistema

### Para Administradores:
1. Entre no painel **Administração de Usuários**
2. Ao criar/editar um **funcionário**, selecione um gerente no dropdown
3. Gerentes e admins **não** têm gerente atribuído (sempre "Sem gerente")

### Para Gerentes:
1. Na dashboard, você verá apenas seus funcionários atribuídos
2. Você pode administrar esses funcionários (criar lançamentos manuais, ver histórico, etc.)
3. Se não houver funcionários atribuídos a você, verá a mensagem "Nenhum funcionário cadastrado"

### Para Funcionários:
1. Nada muda para funcionários
2. Eles podem ter um gerente responsável (visível apenas para admins/gerentes)

---

## 🔍 Testando o Sistema

Após executar o script SQL, teste o seguinte:

1. **Login como Admin**
   - Crie ou edite um funcionário
   - Verifique se o dropdown "Gerente Responsável" aparece
   - Atribua um gerente ao funcionário

2. **Login como Gerente**
   - Verifique se vê apenas funcionários atribuídos a você
   - Tente criar/editar funcionários

3. **Registro Público**
   - Clique em "Criar nova conta"
   - Verifique que não há seleção de tipo (sempre cria funcionário)

---

## ❓ Problemas Comuns

### "Erro ao executar SQL"
- Certifique-se de copiar TODO o script, incluindo os comentários
- Verifique se está no projeto correto do Supabase

### "Coluna manager_id já existe"
- O script está preparado para isso (`IF NOT EXISTS`)
- Você pode executá-lo múltiplas vezes sem problemas

### "Gerentes não aparecem no dropdown"
- Certifique-se de ter criado usuários com role "gerente" antes
- Faça logout e login novamente para recarregar os dados

---

## 📞 Suporte

Se tiver qualquer problema, verifique:
1. Console do navegador (F12) para erros
2. Se o script SQL foi executado corretamente
3. Se fez logout/login após executar o script

Boa sorte! 🚀
