-- Script SQL para criar as tabelas no Supabase
-- Execute este script no SQL Editor do Supabase

-- Tabela de usuários
CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'gerente', 'funcionario')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de registros de ponto
CREATE TABLE IF NOT EXISTS time_records (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE,
  type TEXT NOT NULL CHECK (type IN ('trabalho', 'pausa')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_time_records_user_id ON time_records(user_id);
CREATE INDEX IF NOT EXISTS idx_time_records_start_time ON time_records(start_time);
CREATE INDEX IF NOT EXISTS idx_time_records_active ON time_records(user_id, end_time) WHERE end_time IS NULL;

-- Inserir usuários de teste
INSERT INTO users (name, email, password, role) VALUES
  ('Administrador', 'admin@empresa.com', 'admin123', 'admin'),
  ('Gerente Silva', 'gerente@empresa.com', 'gerente123', 'gerente'),
  ('João Funcionário', 'funcionario@empresa.com', 'func123', 'funcionario')
ON CONFLICT (email) DO NOTHING;

-- Habilitar Row Level Security (RLS) - Segurança
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE time_records ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança para users
CREATE POLICY "Permitir leitura de usuários" ON users
  FOR SELECT USING (true);

CREATE POLICY "Permitir inserção de usuários" ON users
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Permitir atualização de usuários" ON users
  FOR UPDATE USING (true);

CREATE POLICY "Permitir exclusão de usuários" ON users
  FOR DELETE USING (true);

-- Políticas de segurança para time_records
CREATE POLICY "Permitir leitura de registros" ON time_records
  FOR SELECT USING (true);

CREATE POLICY "Permitir inserção de registros" ON time_records
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Permitir atualização de registros" ON time_records
  FOR UPDATE USING (true);

CREATE POLICY "Permitir exclusão de registros" ON time_records
  FOR DELETE USING (true);
