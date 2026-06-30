-- Default Chart of Accounts for SI Building Solutions ERP
-- Standard accounts that a typical business needs

CREATE OR REPLACE FUNCTION deploy_default_accounts()
RETURNS TABLE (code text, name text, account_type text, is_cash boolean, is_bank boolean) AS $$
BEGIN
  -- Only insert if table is empty
  IF EXISTS (SELECT 1 FROM accounts LIMIT 1) THEN
    RETURN;
  END IF;

  RETURN QUERY
  WITH inserted AS (
    INSERT INTO accounts (tenant_id, code, name, account_type, is_cash, is_bank, bank_name, account_number, balance, is_active)
    VALUES
      -- ASSETS (1000-1999)
      ('00000000-0000-0000-0000-000000000001', '1000', 'Cash on Hand', 'asset', true, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '1010', 'Bank Account', 'asset', false, true, 'Default Bank', NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '1020', 'Accounts Receivable', 'asset', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '1030', 'Inventory', 'asset', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '1040', 'Office Equipment', 'asset', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '1050', 'Furniture & Fixtures', 'asset', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '1060', 'Deposits & Advances', 'asset', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '1070', 'Prepaid Expenses', 'asset', false, false, NULL, NULL, 0, true),

      -- LIABILITIES (2000-2999)
      ('00000000-0000-0000-0000-000000000001', '2000', 'Accounts Payable', 'liability', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '2010', 'Bank Loan', 'liability', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '2020', 'Salaries Payable', 'liability', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '2030', 'Tax Payable', 'liability', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '2040', 'Customer Advances', 'liability', false, false, NULL, NULL, 0, true),

      -- EQUITY (3000-3999)
      ('00000000-0000-0000-0000-000000000001', '3000', 'Owner Capital', 'equity', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '3010', 'Retained Earnings', 'equity', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '3020', 'Owner Drawings', 'equity', false, false, NULL, NULL, 0, true),

      -- REVENUE (4000-4999)
      ('00000000-0000-0000-0000-000000000001', '4000', 'Sales Revenue', 'revenue', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '4010', 'Service Revenue', 'revenue', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '4020', 'Discount Received', 'revenue', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '4030', 'Other Income', 'revenue', false, false, NULL, NULL, 0, true),

      -- EXPENSES (5000-5999)
      ('00000000-0000-0000-0000-000000000001', '5000', 'Cost of Goods Sold', 'expense', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '5010', 'Salaries & Wages', 'expense', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '5020', 'Rent Expense', 'expense', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '5030', 'Utilities Expense', 'expense', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '5040', 'Transportation', 'expense', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '5050', 'Marketing & Advertising', 'expense', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '5060', 'Office Supplies', 'expense', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '5070', 'Depreciation', 'expense', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '5080', 'Bank Charges', 'expense', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '5090', 'Interest Expense', 'expense', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '5100', 'Professional Fees', 'expense', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '5110', 'Maintenance', 'expense', false, false, NULL, NULL, 0, true),
      ('00000000-0000-0000-0000-000000000001', '5120', 'Miscellaneous', 'expense', false, false, NULL, NULL, 0, true)
    ON CONFLICT (tenant_id, code) DO NOTHING
    RETURNING code, name, account_type, is_cash, is_bank
  )
  SELECT * FROM inserted;
END;
$$ LANGUAGE plpgsql;
