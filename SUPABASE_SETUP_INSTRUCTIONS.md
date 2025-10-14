# 📋 Instruções para Configurar o Banco de Dados Supabase

## ✅ Etapa 1: Executar o Script SQL

Para que o aplicativo funcione com o Supabase, você precisa criar as tabelas no banco de dados. Siga os passos abaixo:

### Passo a Passo:

1. **Acesse seu projeto no Supabase:**
   - Vá para https://supabase.com
   - Faça login e acesse seu projeto

2. **Abra o SQL Editor:**
   - No menu lateral esquerdo, clique em **SQL Editor** (ícone de banco de dados)
   - Ou clique no botão **New query** para abrir um editor SQL vazio

3. **Copie e cole o script SQL:**
   - Abra o arquivo `supabase_setup.sql` que está na raiz do projeto
   - Copie TODO o conteúdo do arquivo
   - Cole no SQL Editor do Supabase

4. **Execute o script:**
   - Clique no botão **Run** (ou pressione Ctrl+Enter / Cmd+Enter)
   - Aguarde a confirmação de sucesso

### O que o script faz:

- ✅ Cria a tabela `users` (usuários)
- ✅ Cria a tabela `time_records` (registros de ponto)
- ✅ Adiciona índices para melhorar a performance
- ✅ Insere os 3 usuários de teste (admin, gerente e funcionário)
- ✅ Configura políticas de segurança (RLS)

### Usuários de Teste Criados:

| Tipo | Email | Senha |
|------|-------|-------|
| Admin | admin@empresa.com | admin123 |
| Gerente | gerente@empresa.com | gerente123 |
| Funcionário | funcionario@empresa.com | func123 |

## ✅ Etapa 2: Verificar as Tabelas

Após executar o script, você pode verificar se as tabelas foram criadas:

1. No menu lateral do Supabase, clique em **Table Editor**
2. Você deve ver duas tabelas:
   - `users` (com 3 usuários)
   - `time_records` (vazia por enquanto)

## ✅ Etapa 3: Testar o Aplicativo

Agora o aplicativo está pronto para usar o Supabase!

1. Faça login com um dos usuários de teste
2. Experimente registrar pontos
3. Os dados agora serão salvos permanentemente no Supabase

## 🔒 Segurança

As credenciais do Supabase (`SUPABASE_URL` e `SUPABASE_ANON_KEY`) já foram configuradas como variáveis de ambiente seguras no Replit. Elas não serão expostas no código.

## 📚 Próximos Passos

- Para adicionar novos usuários, use a tela de cadastro do admin
- Para visualizar os dados diretamente, use o Table Editor do Supabase
- Para fazer consultas personalizadas, use o SQL Editor

---

**Importante:** Execute o script SQL apenas uma vez. Se executar novamente, o script verificará se as tabelas já existem e não duplicará os dados.
