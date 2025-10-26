-- ============================================
-- MIGRAÇÃO: Adicionar sistema de atribuição de funcionários para gerentes
-- ============================================
-- Execute este script no painel SQL do Supabase
-- (https://supabase.com/dashboard > SQL Editor)

-- 1. Adiciona coluna manager_id à tabela users
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS manager_id INTEGER;

-- 2. Adiciona foreign key constraint
ALTER TABLE users
ADD CONSTRAINT fk_manager_id 
FOREIGN KEY (manager_id) 
REFERENCES users(id) 
ON DELETE SET NULL;

-- 3. Cria índice para melhorar performance
CREATE INDEX IF NOT EXISTS idx_users_manager_id 
ON users(manager_id);

-- 4. Define valores padrão (NULL para todos os usuários existentes)
UPDATE users SET manager_id = NULL WHERE manager_id IS NULL;

-- ============================================
-- VERIFICAÇÃO: Execute para confirmar que funcionou
-- ============================================
-- SELECT id, name, email, role, manager_id FROM users;
