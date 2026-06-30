CREATE OR REPLACE FUNCTION deploy_default_payment_methods()
RETURNS TABLE (code text, name text, is_cash boolean, is_bank boolean) AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM payment_methods LIMIT 1) THEN RETURN; END IF;
  RETURN QUERY
  WITH inserted AS (
    INSERT INTO payment_methods (name, code, is_active, is_cash, is_bank, sort_order, icon_name, description)
    VALUES
      ('Cash', 'cash', true, true, false, 1, 'banknote', 'Cash on hand'),
      ('Bank Transfer', 'bank_transfer', true, false, true, 2, 'building-2', 'Bank transfer / Wire transfer'),
      ('Card', 'card', true, false, false, 3, 'credit-card', 'Credit/Debit card payment'),
      ('Cheque', 'cheque', true, false, false, 4, 'file-text', 'Cheque payment'),
      ('bKash', 'bkash', true, false, false, 5, 'smartphone', 'bKash mobile payment'),
      ('Nagad', 'nagad', true, false, false, 6, 'smartphone', 'Nagad mobile payment')
    ON CONFLICT DO NOTHING
    RETURNING code, name, is_cash, is_bank
  )
  SELECT * FROM inserted;
END;
$$ LANGUAGE plpgsql;
