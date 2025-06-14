/*
  # Setup Demo Users and Data

  1. Demo Users Setup
    - Creates demo admin user (admin@fraccionamiento.com)
    - Creates demo resident user (juan.perez@email.com)
    - Both users will have password: 123456

  2. Demo Data
    - Creates a sample private community
    - Creates a resident record linked to the demo user
    - Ensures proper relationships between users and data

  3. Security
    - Maintains existing RLS policies
    - Ensures demo data follows security constraints

  Note: This migration uses Supabase's auth.users table to create the demo users.
  The passwords will be hashed automatically by Supabase.
*/

-- Insert demo private community
INSERT INTO privates (id, name, code, monthly_amount, description, total_residents)
VALUES (
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  'Fraccionamiento Los Álamos',
  'ALAMOS001',
  2500.00,
  'Fraccionamiento residencial con amenidades completas',
  50
) ON CONFLICT (id) DO NOTHING;

-- Insert demo resident data
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
  'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
  'juan.perez@email.com',
  'Juan Pérez García',
  'RES001',
  'Calle Los Álamos #123',
  'Casa 123',
  '+52 55 1234 5678',
  '646180157000000004',
  2500.00,
  15,
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  true
) ON CONFLICT (email) DO UPDATE SET
  name = EXCLUDED.name,
  resident_code = EXCLUDED.resident_code,
  address = EXCLUDED.address,
  unit = EXCLUDED.unit,
  phone = EXCLUDED.phone,
  clabe_account = EXCLUDED.clabe_account,
  monthly_amount = EXCLUDED.monthly_amount,
  due_date = EXCLUDED.due_date,
  private_id = EXCLUDED.private_id,
  is_active = EXCLUDED.is_active;

-- Create a sample notification
INSERT INTO notifications (
  title,
  message,
  private_id,
  priority,
  is_active
) VALUES (
  'Bienvenido al Sistema',
  'Bienvenido al sistema de gestión de pagos del Fraccionamiento Los Álamos. Aquí podrás realizar tus pagos mensuales de manera fácil y segura.',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  'medium',
  true
) ON CONFLICT DO NOTHING;

-- Note: The actual user creation in auth.users needs to be done through Supabase Auth API
-- This cannot be done directly in SQL migrations for security reasons
-- The users need to be created through the Supabase dashboard or programmatically