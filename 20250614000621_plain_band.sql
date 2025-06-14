/*
  # Crear usuarios demo y datos iniciales

  1. Datos de ejemplo
    - Privadas del fraccionamiento
    - Residentes de ejemplo
    - Notificaciones iniciales

  2. Nota importante
    - Los usuarios de autenticación deben crearse manualmente
    - Este archivo solo prepara los datos relacionados
*/

-- Limpiar datos existentes si existen
DELETE FROM notifications WHERE id IN ('550e8400-e29b-41d4-a716-446655440031', '550e8400-e29b-41d4-a716-446655440032');
DELETE FROM payments WHERE id IN ('550e8400-e29b-41d4-a716-446655440021', '550e8400-e29b-41d4-a716-446655440022');
DELETE FROM residents WHERE id IN ('550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440013');
DELETE FROM privates WHERE id IN ('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440003');

-- Insertar privadas de ejemplo
INSERT INTO privates (id, name, code, monthly_amount, description, total_residents) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'Privada Álamos', 'PA', 2500.00, 'Privada principal del fraccionamiento', 15),
  ('550e8400-e29b-41d4-a716-446655440002', 'Privada Robles', 'PR', 3000.00, 'Privada premium con amenidades adicionales', 12),
  ('550e8400-e29b-41d4-a716-446655440003', 'Privada Cedros', 'PC', 2800.00, 'Privada familiar con áreas verdes', 18);

-- Insertar residentes de ejemplo
INSERT INTO residents (id, email, name, resident_code, address, unit, phone, clabe_account, monthly_amount, due_date, private_id) VALUES
  ('550e8400-e29b-41d4-a716-446655440011', 'juan.perez@email.com', 'Juan Pérez', 'PA-001', 'Calle Principal 123', 'Casa 1', '5551234567', '123456789112345678', 2500.00, 5, '550e8400-e29b-41d4-a716-446655440001'),
  ('550e8400-e29b-41d4-a716-446655440012', 'maria.garcia@email.com', 'María García', 'PR-001', 'Avenida Central 456', 'Casa 2', '5559876543', '987654321098765432', 3000.00, 10, '550e8400-e29b-41d4-a716-446655440002'),
  ('550e8400-e29b-41d4-a716-446655440013', 'carlos.lopez@email.com', 'Carlos López', 'PC-001', 'Privada Norte 789', 'Casa 3', '5555555555', '456789123456789012', 2800.00, 15, '550e8400-e29b-41d4-a716-446655440003');

-- Insertar pagos de ejemplo
INSERT INTO payments (id, ticket_number, qr_code, resident_id, private_id, amount, month, year, bank_code, bank_name, origin_clabe, tracking_code, phone, notes, status, submitted_date, processed_date) VALUES
  ('550e8400-e29b-41d4-a716-446655440021', 'PA-2024-001', 'QR-PA-2024-001', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440001', 2500.00, 11, 2024, '40002', 'BANAMEX', '123456789112345678', '11FEF28A36F', '5551234567', 'Pago realizado a tiempo', 'approved', '2024-11-03 10:00:00', '2024-11-04 14:30:00'),
  ('550e8400-e29b-41d4-a716-446655440022', 'PR-2024-001', 'QR-PR-2024-001', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440002', 3000.00, 11, 2024, '40072', 'BANORTE', '987654321098765432', '22ABC45D78E', '5559876543', 'Transferencia realizada el viernes', 'processing', '2024-11-08 16:20:00', NULL);

-- Insertar notificaciones de ejemplo
INSERT INTO notifications (id, title, message, private_id, priority, is_active) VALUES
  ('550e8400-e29b-41d4-a716-446655440031', 'Mantenimiento Programado', 'Se realizará mantenimiento a las áreas comunes el próximo sábado de 8:00 AM a 2:00 PM.', '550e8400-e29b-41d4-a716-446655440001', 'medium', true),
  ('550e8400-e29b-41d4-a716-446655440032', 'Recordatorio de Pago', 'Recuerden que los pagos deben realizarse con 24-48 horas de anticipación para su verificación.', NULL, 'high', true);