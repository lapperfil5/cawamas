/*
  # Create demo users and sample data

  1. New Data
    - Create a sample private (fraccionamiento)
    - Create demo users in auth.users
    - Create resident profile for juan.perez@email.com
    
  2. Demo Users
    - admin@fraccionamiento.com (admin user)
    - juan.perez@email.com (resident user)
    - Both with password: 123456
    
  3. Security
    - Users are created with confirmed email status
    - Resident is linked to the sample private
*/

-- Create a sample private/fraccionamiento
INSERT INTO privates (id, name, code, monthly_amount, description, total_residents)
VALUES (
  'f47ac10b-58cc-4372-a567-0e02b2c3d479',
  'Fraccionamiento Los Álamos',
  'ALAMOS001',
  2500.00,
  'Fraccionamiento residencial Los Álamos - Zona Norte',
  50
) ON CONFLICT (code) DO NOTHING;

-- Insert demo users into auth.users table
-- Note: In a real production environment, users should register through the normal signup flow
-- This is only for demo purposes

-- Admin user
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  invited_at,
  confirmation_token,
  confirmation_sent_at,
  recovery_token,
  recovery_sent_at,
  email_change_token_new,
  email_change,
  email_change_sent_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  created_at,
  updated_at,
  phone,
  phone_confirmed_at,
  phone_change,
  phone_change_token,
  phone_change_sent_at,
  email_change_token_current,
  email_change_confirm_status,
  banned_until,
  reauthentication_token,
  reauthentication_sent_at,
  is_sso_user,
  deleted_at
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  'authenticated',
  'authenticated',
  'admin@fraccionamiento.com',
  '$2a$10$8K1p/a0dUrZBvHEHdBVKoOmc2nHqHn89NNyg6rJ3qx9cyGrn4H/6O', -- password: 123456
  NOW(),
  NULL,
  '',
  NULL,
  '',
  NULL,
  '',
  '',
  NULL,
  NULL,
  '{"provider": "email", "providers": ["email"]}',
  '{}',
  NULL,
  NOW(),
  NOW(),
  NULL,
  NULL,
  '',
  '',
  NULL,
  '',
  0,
  NULL,
  '',
  NULL,
  false,
  NULL
) ON CONFLICT (email) DO NOTHING;

-- Resident user
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  invited_at,
  confirmation_token,
  confirmation_sent_at,
  recovery_token,
  recovery_sent_at,
  email_change_token_new,
  email_change,
  email_change_sent_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  created_at,
  updated_at,
  phone,
  phone_confirmed_at,
  phone_change,
  phone_change_token,
  phone_change_sent_at,
  email_change_token_current,
  email_change_confirm_status,
  banned_until,
  reauthentication_token,
  reauthentication_sent_at,
  is_sso_user,
  deleted_at
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  'b1ffbc99-9c0b-4ef8-bb6d-6bb9bd380a22',
  'authenticated',
  'authenticated',
  'juan.perez@email.com',
  '$2a$10$8K1p/a0dUrZBvHEHdBVKoOmc2nHqHn89NNyg6rJ3qx9cyGrn4H/6O', -- password: 123456
  NOW(),
  NULL,
  '',
  NULL,
  '',
  NULL,
  '',
  '',
  NULL,
  NULL,
  '{"provider": "email", "providers": ["email"]}',
  '{}',
  NULL,
  NOW(),
  NOW(),
  NULL,
  NULL,
  '',
  '',
  NULL,
  '',
  0,
  NULL,
  '',
  NULL,
  false,
  NULL
) ON CONFLICT (email) DO NOTHING;

-- Create resident profile for juan.perez@email.com
INSERT INTO residents (
  id,
  email,
  name,
  resident_code,
  address,
  unit,
  phone,
  clabe_account,
  monthly_amount,
  due_date,
  private_id,
  is_active
) VALUES (
  'b1ffbc99-9c0b-4ef8-bb6d-6bb9bd380a22',
  'juan.perez@email.com',
  'Juan Pérez García',
  'RES001',
  'Calle Álamos 123',
  'Casa 15',
  '+52 55 1234 5678',
  '012345678901234567',
  2500.00,
  15,
  'f47ac10b-58cc-4372-a567-0e02b2c3d479',
  true
) ON CONFLICT (email) DO NOTHING;

-- Create a sample notification
INSERT INTO notifications (
  title,
  message,
  private_id,
  priority,
  is_active
) VALUES (
  'Bienvenido al Sistema',
  'Bienvenido al sistema de gestión de pagos del Fraccionamiento Los Álamos. Aquí podrás realizar tus pagos mensuales y consultar tu historial.',
  'f47ac10b-58cc-4372-a567-0e02b2c3d479',
  'medium',
  true
) ON CONFLICT DO NOTHING;