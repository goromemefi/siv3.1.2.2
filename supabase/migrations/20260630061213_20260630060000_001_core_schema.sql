CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  full_name text NOT NULL DEFAULT '',
  email text NOT NULL DEFAULT '',
  role text NOT NULL DEFAULT 'sales_executive'
    CHECK (role IN ('super_admin','manager','sales_executive','inventory_manager','accountant','delivery_staff','customer_portal','store_customer')),
  avatar_url text,
  phone text,
  department text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "profiles_select" ON profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "profiles_insert" ON profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_update" ON profiles FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_delete" ON profiles FOR DELETE TO authenticated USING (auth.uid() = id);

CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  name text NOT NULL,
  slug text NOT NULL,
  description text,
  parent_id uuid REFERENCES categories(id) ON DELETE SET NULL,
  image_url text,
  sort_order integer NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS categories_tenant_slug ON categories(tenant_id, slug);
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "cats_select" ON categories FOR SELECT TO authenticated USING (true);
CREATE POLICY "cats_insert" ON categories FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "cats_update" ON categories FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "cats_delete" ON categories FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS brands (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  name text NOT NULL,
  slug text NOT NULL,
  logo_url text,
  description text,
  country_of_origin text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS brands_tenant_slug ON brands(tenant_id, slug);
ALTER TABLE brands ENABLE ROW LEVEL SECURITY;
CREATE POLICY "brands_select" ON brands FOR SELECT TO authenticated USING (true);
CREATE POLICY "brands_insert" ON brands FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "brands_update" ON brands FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "brands_delete" ON brands FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  sku text NOT NULL,
  barcode text,
  name text NOT NULL,
  description text,
  category_id uuid REFERENCES categories(id) ON DELETE SET NULL,
  brand_id uuid REFERENCES brands(id) ON DELETE SET NULL,
  unit text NOT NULL DEFAULT 'pcs',
  cost_price decimal(15,2) NOT NULL DEFAULT 0,
  sale_price decimal(15,2) NOT NULL DEFAULT 0,
  mrp decimal(15,2),
  tax_rate decimal(5,2) NOT NULL DEFAULT 0,
  min_stock_level integer NOT NULL DEFAULT 0,
  max_stock_level integer,
  image_url text,
  images jsonb DEFAULT '[]',
  specifications jsonb DEFAULT '{}',
  is_active boolean NOT NULL DEFAULT true,
  is_online boolean NOT NULL DEFAULT false,
  weight decimal(10,3),
  dimensions jsonb,
  warranty_months integer DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS products_tenant_sku ON products(tenant_id, sku);
CREATE INDEX IF NOT EXISTS products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS products_brand ON products(brand_id);
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "products_select" ON products FOR SELECT TO authenticated USING (true);
CREATE POLICY "products_insert" ON products FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "products_update" ON products FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "products_delete" ON products FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS product_units (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  unit_name text NOT NULL,
  unit_short text,
  conversion_factor decimal(10,4) NOT NULL DEFAULT 1,
  is_base_unit boolean NOT NULL DEFAULT false,
  is_sale_unit boolean NOT NULL DEFAULT false,
  price decimal(15,2),
  cost_price decimal(15,2),
  is_active boolean NOT NULL DEFAULT true,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS product_units_product ON product_units(product_id);
ALTER TABLE product_units ENABLE ROW LEVEL SECURITY;
CREATE POLICY "pu_select" ON product_units FOR SELECT TO authenticated USING (true);
CREATE POLICY "pu_insert" ON product_units FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "pu_update" ON product_units FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "pu_delete" ON product_units FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS warehouses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  name text NOT NULL,
  code text NOT NULL,
  address text,
  city text,
  contact_person text,
  contact_phone text,
  is_default boolean NOT NULL DEFAULT false,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE warehouses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "wh_select" ON warehouses FOR SELECT TO authenticated USING (true);
CREATE POLICY "wh_insert" ON warehouses FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "wh_update" ON warehouses FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "wh_delete" ON warehouses FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS inventory_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  warehouse_id uuid NOT NULL REFERENCES warehouses(id) ON DELETE CASCADE,
  quantity_on_hand decimal(15,3) NOT NULL DEFAULT 0,
  quantity_reserved decimal(15,3) NOT NULL DEFAULT 0,
  quantity_incoming decimal(15,3) NOT NULL DEFAULT 0,
  last_counted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS inv_items_product_warehouse ON inventory_items(product_id, warehouse_id);
CREATE INDEX IF NOT EXISTS inv_items_product ON inventory_items(product_id);
CREATE INDEX IF NOT EXISTS inv_items_warehouse ON inventory_items(warehouse_id);
ALTER TABLE inventory_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "inv_select" ON inventory_items FOR SELECT TO authenticated USING (true);
CREATE POLICY "inv_insert" ON inventory_items FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "inv_update" ON inventory_items FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "inv_delete" ON inventory_items FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS stock_movements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  product_id uuid NOT NULL REFERENCES products(id),
  warehouse_id uuid NOT NULL REFERENCES warehouses(id),
  movement_type text NOT NULL
    CHECK (movement_type IN ('purchase','sale','adjustment','transfer_in','transfer_out','return_in','return_out','damage','opening')),
  quantity decimal(15,3) NOT NULL,
  unit_cost decimal(15,2),
  reference_type text,
  reference_id uuid,
  reference_number text,
  notes text,
  created_by uuid REFERENCES profiles(id),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS movements_product ON stock_movements(product_id);
CREATE INDEX IF NOT EXISTS movements_created ON stock_movements(created_at DESC);
ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "movements_select" ON stock_movements FOR SELECT TO authenticated USING (true);
CREATE POLICY "movements_insert" ON stock_movements FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "movements_update" ON stock_movements FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "movements_delete" ON stock_movements FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS suppliers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  code text NOT NULL,
  name text NOT NULL,
  company_name text,
  email text,
  phone text,
  mobile text,
  address text,
  city text,
  country text DEFAULT 'Bangladesh',
  tax_id text,
  credit_limit decimal(15,2) NOT NULL DEFAULT 0,
  credit_days integer NOT NULL DEFAULT 0,
  payment_terms text,
  bank_details jsonb DEFAULT '{}',
  outstanding_balance decimal(15,2) NOT NULL DEFAULT 0,
  total_purchases decimal(15,2) NOT NULL DEFAULT 0,
  notes text,
  rating integer CHECK (rating BETWEEN 1 AND 5),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS suppliers_tenant_code ON suppliers(tenant_id, code);
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sup_select" ON suppliers FOR SELECT TO authenticated USING (true);
CREATE POLICY "sup_insert" ON suppliers FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "sup_update" ON suppliers FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "sup_delete" ON suppliers FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS customers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  code text NOT NULL,
  name text NOT NULL,
  type text NOT NULL DEFAULT 'retail'
    CHECK (type IN ('retail','contractor','builder','architect','interior_designer','corporate','government')),
  company_name text,
  email text,
  phone text,
  mobile text,
  address text,
  city text,
  country text DEFAULT 'Bangladesh',
  tax_id text,
  credit_limit decimal(15,2) NOT NULL DEFAULT 0,
  credit_days integer NOT NULL DEFAULT 0,
  outstanding_balance decimal(15,2) NOT NULL DEFAULT 0,
  total_purchases decimal(15,2) NOT NULL DEFAULT 0,
  loyalty_points integer NOT NULL DEFAULT 0,
  discount_percent decimal(5,2) NOT NULL DEFAULT 0,
  assigned_to uuid REFERENCES profiles(id),
  notes text,
  tags text[],
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS customers_tenant_code ON customers(tenant_id, code);
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "cust_select" ON customers FOR SELECT TO authenticated USING (true);
CREATE POLICY "cust_insert" ON customers FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "cust_update" ON customers FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "cust_delete" ON customers FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS customer_notes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  note text NOT NULL,
  note_type text DEFAULT 'general' CHECK (note_type IN ('general','call','meeting','follow_up','complaint')),
  created_by uuid REFERENCES profiles(id),
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE customer_notes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "cn_select" ON customer_notes FOR SELECT TO authenticated USING (true);
CREATE POLICY "cn_insert" ON customer_notes FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "cn_update" ON customer_notes FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "cn_delete" ON customer_notes FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS purchase_orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  order_number text NOT NULL,
  supplier_id uuid NOT NULL REFERENCES suppliers(id),
  order_date date NOT NULL DEFAULT now(),
  expected_date date,
  subtotal decimal(15,2) NOT NULL DEFAULT 0,
  discount_amount decimal(15,2) NOT NULL DEFAULT 0,
  tax_amount decimal(15,2) NOT NULL DEFAULT 0,
  shipping_amount decimal(15,2) NOT NULL DEFAULT 0,
  total_amount decimal(15,2) NOT NULL DEFAULT 0,
  amount_paid decimal(15,2) NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft','sent','confirmed','partial','received','closed','cancelled')),
  payment_status text NOT NULL DEFAULT 'unpaid'
    CHECK (payment_status IN ('unpaid','partial','paid')),
  payment_type text NOT NULL DEFAULT 'credit',
  notes text,
  created_by uuid REFERENCES profiles(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS po_tenant_number ON purchase_orders(tenant_id, order_number);
ALTER TABLE purchase_orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "po_select" ON purchase_orders FOR SELECT TO authenticated USING (true);
CREATE POLICY "po_insert" ON purchase_orders FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "po_update" ON purchase_orders FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "po_delete" ON purchase_orders FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS purchase_order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_order_id uuid NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
  product_id uuid NOT NULL REFERENCES products(id),
  quantity decimal(15,3) NOT NULL DEFAULT 0,
  received_quantity decimal(15,3) NOT NULL DEFAULT 0,
  unit_price decimal(15,2) NOT NULL DEFAULT 0,
  discount_percent decimal(5,2) NOT NULL DEFAULT 0,
  tax_rate decimal(5,2) NOT NULL DEFAULT 0,
  subtotal decimal(15,2) NOT NULL DEFAULT 0,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE purchase_order_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "poi_select" ON purchase_order_items FOR SELECT TO authenticated USING (true);
CREATE POLICY "poi_insert" ON purchase_order_items FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "poi_update" ON purchase_order_items FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "poi_delete" ON purchase_order_items FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS invoices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  invoice_number text NOT NULL,
  customer_id uuid NOT NULL REFERENCES customers(id),
  invoice_date date NOT NULL DEFAULT now(),
  due_date date,
  subtotal decimal(15,2) NOT NULL DEFAULT 0,
  discount_amount decimal(15,2) NOT NULL DEFAULT 0,
  tax_amount decimal(15,2) NOT NULL DEFAULT 0,
  shipping_amount decimal(15,2) NOT NULL DEFAULT 0,
  total_amount decimal(15,2) NOT NULL DEFAULT 0,
  amount_paid decimal(15,2) NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft','sent','paid','partial','overdue','cancelled')),
  is_pos boolean NOT NULL DEFAULT false,
  notes text,
  created_by uuid REFERENCES profiles(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS inv_tenant_number ON invoices(tenant_id, invoice_number);
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
CREATE POLICY "inv_select" ON invoices FOR SELECT TO authenticated USING (true);
CREATE POLICY "inv_insert" ON invoices FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "inv_update" ON invoices FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "inv_delete" ON invoices FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS invoice_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id uuid NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  product_id uuid NOT NULL REFERENCES products(id),
  quantity decimal(15,3) NOT NULL DEFAULT 0,
  unit_price decimal(15,2) NOT NULL DEFAULT 0,
  discount_percent decimal(5,2) NOT NULL DEFAULT 0,
  tax_rate decimal(5,2) NOT NULL DEFAULT 0,
  subtotal decimal(15,2) NOT NULL DEFAULT 0,
  unit_name text,
  unit_conversion_factor decimal(10,4),
  base_quantity decimal(15,3),
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE invoice_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ii_select" ON invoice_items FOR SELECT TO authenticated USING (true);
CREATE POLICY "ii_insert" ON invoice_items FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "ii_update" ON invoice_items FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "ii_delete" ON invoice_items FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  payment_number text NOT NULL,
  payment_type text NOT NULL DEFAULT 'received'
    CHECK (payment_type IN ('received','paid','refund')),
  reference_type text,
  reference_id uuid,
  customer_id uuid REFERENCES customers(id),
  supplier_id uuid REFERENCES suppliers(id),
  amount decimal(15,2) NOT NULL DEFAULT 0,
  payment_method text NOT NULL DEFAULT 'cash',
  payment_date date NOT NULL DEFAULT now(),
  reference_number text,
  notes text,
  created_by uuid REFERENCES profiles(id),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS payments_tenant_number ON payments(tenant_id, payment_number);
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "pay_select" ON payments FOR SELECT TO authenticated USING (true);
CREATE POLICY "pay_insert" ON payments FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "pay_update" ON payments FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "pay_delete" ON payments FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  code text NOT NULL,
  name text NOT NULL,
  account_type text NOT NULL
    CHECK (account_type IN ('asset','liability','equity','revenue','expense')),
  parent_id uuid REFERENCES accounts(id) ON DELETE SET NULL,
  is_cash boolean NOT NULL DEFAULT false,
  is_bank boolean NOT NULL DEFAULT false,
  bank_name text,
  account_number text,
  branch text,
  balance decimal(15,2) NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS accounts_tenant_code ON accounts(tenant_id, code);
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "acc_select" ON accounts FOR SELECT TO authenticated USING (true);
CREATE POLICY "acc_insert" ON accounts FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "acc_update" ON accounts FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "acc_delete" ON accounts FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS journal_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  entry_number text NOT NULL,
  entry_date date NOT NULL DEFAULT now(),
  description text,
  reference_type text,
  reference_id uuid,
  total_debit decimal(15,2) NOT NULL DEFAULT 0,
  total_credit decimal(15,2) NOT NULL DEFAULT 0,
  is_posted boolean NOT NULL DEFAULT false,
  created_by uuid REFERENCES profiles(id),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS je_tenant_number ON journal_entries(tenant_id, entry_number);
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
CREATE POLICY "je_select" ON journal_entries FOR SELECT TO authenticated USING (true);
CREATE POLICY "je_insert" ON journal_entries FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "je_update" ON journal_entries FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "je_delete" ON journal_entries FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS journal_lines (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  journal_entry_id uuid NOT NULL REFERENCES journal_entries(id) ON DELETE CASCADE,
  account_id uuid NOT NULL REFERENCES accounts(id),
  description text,
  debit decimal(15,2) NOT NULL DEFAULT 0,
  credit decimal(15,2) NOT NULL DEFAULT 0,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE journal_lines ENABLE ROW LEVEL SECURITY;
CREATE POLICY "jl_select" ON journal_lines FOR SELECT TO authenticated USING (true);
CREATE POLICY "jl_insert" ON journal_lines FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "jl_update" ON journal_lines FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "jl_delete" ON journal_lines FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  key text NOT NULL,
  value text,
  type text NOT NULL DEFAULT 'text',
  category text NOT NULL DEFAULT 'general',
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS settings_tenant_key ON settings(tenant_id, key);
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "settings_select" ON settings FOR SELECT TO authenticated USING (true);
CREATE POLICY "settings_insert" ON settings FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "settings_update" ON settings FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "settings_delete" ON settings FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS payment_methods (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  code text NOT NULL,
  description text,
  is_active boolean NOT NULL DEFAULT true,
  is_cash boolean NOT NULL DEFAULT false,
  is_bank boolean NOT NULL DEFAULT false,
  sort_order integer NOT NULL DEFAULT 0,
  icon_name text,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS payment_methods_code ON payment_methods(code);
ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;
CREATE POLICY "pm_select" ON payment_methods FOR SELECT TO authenticated USING (true);
CREATE POLICY "pm_insert" ON payment_methods FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "pm_update" ON payment_methods FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "pm_delete" ON payment_methods FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS quotations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
  quotation_number text NOT NULL,
  customer_id uuid NOT NULL REFERENCES customers(id),
  quotation_date date NOT NULL DEFAULT now(),
  valid_until date,
  subtotal decimal(15,2) NOT NULL DEFAULT 0,
  discount_amount decimal(15,2) NOT NULL DEFAULT 0,
  tax_amount decimal(15,2) NOT NULL DEFAULT 0,
  total_amount decimal(15,2) NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft','sent','accepted','rejected','expired')),
  notes text,
  created_by uuid REFERENCES profiles(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS q_tenant_number ON quotations(tenant_id, quotation_number);
ALTER TABLE quotations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "q_select" ON quotations FOR SELECT TO authenticated USING (true);
CREATE POLICY "q_insert" ON quotations FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "q_update" ON quotations FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "q_delete" ON quotations FOR DELETE TO authenticated USING (true);

CREATE TABLE IF NOT EXISTS quotation_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quotation_id uuid NOT NULL REFERENCES quotations(id) ON DELETE CASCADE,
  product_id uuid NOT NULL REFERENCES products(id),
  quantity decimal(15,3) NOT NULL DEFAULT 0,
  unit_price decimal(15,2) NOT NULL DEFAULT 0,
  discount_percent decimal(5,2) NOT NULL DEFAULT 0,
  tax_rate decimal(5,2) NOT NULL DEFAULT 0,
  subtotal decimal(15,2) NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE quotation_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "qi_select" ON quotation_items FOR SELECT TO authenticated USING (true);
CREATE POLICY "qi_insert" ON quotation_items FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "qi_update" ON quotation_items FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "qi_delete" ON quotation_items FOR DELETE TO authenticated USING (true);
