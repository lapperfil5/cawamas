/*
  # Esquema inicial del sistema de gestión de pagos

  1. Nuevas Tablas
    - `privates` - Privadas del fraccionamiento
    - `residents` - Residentes del fraccionamiento  
    - `payments` - Pagos registrados
    - `notifications` - Notificaciones del sistema
    - `payment_files` - Archivos de comprobantes

  2. Seguridad
    - Habilitar RLS en todas las tablas
    - Políticas para residentes (solo sus datos)
    - Políticas para administradores (acceso completo)

  3. Funciones
    - Generación automática de códigos de residente
    - Generación de números de ticket
    - Cálculo de pagos atrasados
*/

-- Crear tabla de privadas
CREATE TABLE IF NOT EXISTS privates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  code text UNIQUE NOT NULL,
  monthly_amount decimal(10,2) NOT NULL DEFAULT 0,
  description text,
  total_residents integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Crear tabla de residentes
CREATE TABLE IF NOT EXISTS residents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  name text NOT NULL,
  resident_code text UNIQUE NOT NULL,
  address text NOT NULL,
  unit text NOT NULL,
  phone text,
  clabe_account text,
  monthly_amount decimal(10,2),
  due_date integer DEFAULT 15,
  private_id uuid REFERENCES privates(id) ON DELETE CASCADE,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Crear tabla de pagos
CREATE TABLE IF NOT EXISTS payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_number text UNIQUE NOT NULL,
  qr_code text UNIQUE NOT NULL,
  resident_id uuid REFERENCES residents(id) ON DELETE CASCADE,
  private_id uuid REFERENCES privates(id) ON DELETE CASCADE,
  amount decimal(10,2) NOT NULL,
  month integer NOT NULL CHECK (month >= 1 AND month <= 12),
  year integer NOT NULL,
  bank_code text NOT NULL,
  bank_name text NOT NULL,
  origin_clabe text NOT NULL,
  tracking_code text,
  phone text,
  notes text,
  admin_notes text,
  status text NOT NULL DEFAULT 'processing' CHECK (status IN ('processing', 'approved', 'rejected', 'deleted')),
  submitted_date timestamptz DEFAULT now(),
  processed_date timestamptz,
  deleted_date timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Crear tabla de archivos de comprobantes
CREATE TABLE IF NOT EXISTS payment_files (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id uuid REFERENCES payments(id) ON DELETE CASCADE,
  file_name text NOT NULL,
  file_path text NOT NULL,
  file_size bigint,
  mime_type text,
  uploaded_at timestamptz DEFAULT now()
);

-- Crear tabla de notificaciones
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  message text NOT NULL,
  private_id uuid REFERENCES privates(id) ON DELETE CASCADE,
  priority text DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE privates ENABLE ROW LEVEL SECURITY;
ALTER TABLE residents ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Políticas para administradores (acceso completo)
CREATE POLICY "Admins can manage privates"
  ON privates
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE auth.users.id = auth.uid() 
      AND auth.users.email LIKE '%admin%'
    )
  );

CREATE POLICY "Admins can manage residents"
  ON residents
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE auth.users.id = auth.uid() 
      AND auth.users.email LIKE '%admin%'
    )
  );

CREATE POLICY "Admins can manage payments"
  ON payments
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE auth.users.id = auth.uid() 
      AND auth.users.email LIKE '%admin%'
    )
  );

CREATE POLICY "Admins can manage payment files"
  ON payment_files
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE auth.users.id = auth.uid() 
      AND auth.users.email LIKE '%admin%'
    )
  );

CREATE POLICY "Admins can manage notifications"
  ON notifications
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE auth.users.id = auth.uid() 
      AND auth.users.email LIKE '%admin%'
    )
  );

-- Políticas para residentes (solo sus datos)
CREATE POLICY "Residents can read their private info"
  ON privates
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM residents 
      WHERE residents.private_id = privates.id 
      AND residents.email = auth.jwt() ->> 'email'
    )
  );

CREATE POLICY "Residents can read their own data"
  ON residents
  FOR SELECT
  TO authenticated
  USING (email = auth.jwt() ->> 'email');

CREATE POLICY "Residents can update their own data"
  ON residents
  FOR UPDATE
  TO authenticated
  USING (email = auth.jwt() ->> 'email');

CREATE POLICY "Residents can read their payments"
  ON payments
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM residents 
      WHERE residents.id = payments.resident_id 
      AND residents.email = auth.jwt() ->> 'email'
    )
  );

CREATE POLICY "Residents can create payments"
  ON payments
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM residents 
      WHERE residents.id = payments.resident_id 
      AND residents.email = auth.jwt() ->> 'email'
    )
  );

CREATE POLICY "Residents can update their processing payments"
  ON payments
  FOR UPDATE
  TO authenticated
  USING (
    status = 'processing' AND
    EXISTS (
      SELECT 1 FROM residents 
      WHERE residents.id = payments.resident_id 
      AND residents.email = auth.jwt() ->> 'email'
    )
  );

CREATE POLICY "Residents can read their payment files"
  ON payment_files
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM payments p
      JOIN residents r ON r.id = p.resident_id
      WHERE p.id = payment_files.payment_id 
      AND r.email = auth.jwt() ->> 'email'
    )
  );

CREATE POLICY "Residents can upload payment files"
  ON payment_files
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM payments p
      JOIN residents r ON r.id = p.resident_id
      WHERE p.id = payment_files.payment_id 
      AND r.email = auth.jwt() ->> 'email'
    )
  );

CREATE POLICY "Residents can read notifications for their private"
  ON notifications
  FOR SELECT
  TO authenticated
  USING (
    is_active = true AND (
      private_id IS NULL OR
      EXISTS (
        SELECT 1 FROM residents 
        WHERE residents.private_id = notifications.private_id 
        AND residents.email = auth.jwt() ->> 'email'
      )
    )
  );

-- Función para generar código de residente
CREATE OR REPLACE FUNCTION generate_resident_code(private_code text)
RETURNS text AS $$
DECLARE
  next_number integer;
  new_code text;
BEGIN
  -- Obtener el siguiente número para esta privada
  SELECT COALESCE(MAX(CAST(SUBSTRING(resident_code FROM '[0-9]+$') AS integer)), 0) + 1
  INTO next_number
  FROM residents 
  WHERE resident_code LIKE private_code || '-%';
  
  -- Generar el código con formato XXX-001
  new_code := private_code || '-' || LPAD(next_number::text, 3, '0');
  
  RETURN new_code;
END;
$$ LANGUAGE plpgsql;

-- Función para generar número de ticket
CREATE OR REPLACE FUNCTION generate_ticket_number(private_code text, payment_year integer)
RETURNS text AS $$
DECLARE
  next_number integer;
  new_ticket text;
BEGIN
  -- Obtener el siguiente número para esta privada y año
  SELECT COALESCE(MAX(CAST(SUBSTRING(ticket_number FROM '[0-9]+$') AS integer)), 0) + 1
  INTO next_number
  FROM payments 
  WHERE ticket_number LIKE private_code || '-' || payment_year || '-%';
  
  -- Generar el ticket con formato XXX-2024-001
  new_ticket := private_code || '-' || payment_year || '-' || LPAD(next_number::text, 3, '0');
  
  RETURN new_ticket;
END;
$$ LANGUAGE plpgsql;

-- Trigger para generar código QR automáticamente
CREATE OR REPLACE FUNCTION generate_qr_code()
RETURNS trigger AS $$
BEGIN
  NEW.qr_code := 'QR-' || NEW.ticket_number;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_qr_code
  BEFORE INSERT ON payments
  FOR EACH ROW
  EXECUTE FUNCTION generate_qr_code();

-- Función para actualizar timestamps
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para actualizar timestamps
CREATE TRIGGER update_privates_updated_at
  BEFORE UPDATE ON privates
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_residents_updated_at
  BEFORE UPDATE ON residents
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_payments_updated_at
  BEFORE UPDATE ON payments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_notifications_updated_at
  BEFORE UPDATE ON notifications
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();