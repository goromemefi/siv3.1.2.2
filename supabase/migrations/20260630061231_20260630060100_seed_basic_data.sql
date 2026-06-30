-- Seed basic data for SI Building Solutions ERP

-- Default warehouse
INSERT INTO warehouses (tenant_id, name, code, is_default, is_active) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Main Warehouse', 'WH-001', true, true)
ON CONFLICT DO NOTHING;

-- Walk-in customer
INSERT INTO customers (id, tenant_id, code, name, type, country, is_active, credit_limit, credit_days, outstanding_balance, total_purchases, loyalty_points, discount_percent) VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'WALK-IN', 'Walk-in Customer', 'retail', 'Bangladesh', true, 0, 0, 0, 0, 0, 0)
ON CONFLICT DO NOTHING;

-- Default payment methods
INSERT INTO payment_methods (name, code, is_active, is_cash, is_bank, sort_order, icon_name, description) VALUES
  ('Cash', 'cash', true, true, false, 1, 'banknote', 'Cash on hand'),
  ('Bank Transfer', 'bank_transfer', true, false, true, 2, 'building-2', 'Bank transfer / Wire transfer'),
  ('Card', 'card', true, false, false, 3, 'credit-card', 'Credit/Debit card payment'),
  ('Cheque', 'cheque', true, false, false, 4, 'file-text', 'Cheque payment'),
  ('bKash', 'bkash', true, false, false, 5, 'smartphone', 'bKash mobile payment'),
  ('Nagad', 'nagad', true, false, false, 6, 'smartphone', 'Nagad mobile payment')
ON CONFLICT DO NOTHING;
